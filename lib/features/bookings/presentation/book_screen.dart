import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../matches/presentation/day_matches_provider.dart';
import '../data/bookings_repository.dart';
import '../domain/booking.dart';
import '../domain/booking_request.dart';
import '../domain/schedule.dart';
import 'book_providers.dart';
import 'cancel_booking.dart';
import 'complete_booking_controller.dart';

/// Prenota: griglia del giorno, un campo alla volta.
class BookScreen extends ConsumerWidget {
  const BookScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final day = ref.watch(bookDayProvider);
    final schedule = ref.watch(scheduleProvider(day));
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _Header(),
            const _FreeCourtsChip(),
            Expanded(
              child: AsyncValueView(
                value: schedule,
                errorText: 'Non riesco a caricare i campi',
                onRetry: () => ref.invalidate(scheduleProvider(day)),
                data: (grid) => grid.courts.isEmpty
                    ? const Center(child: Text('Nessun campo disponibile'))
                    : _CourtGrid(grid: grid, day: day),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final day = ref.watch(bookDayProvider);
    final controller = ref.read(bookDayProvider.notifier);
    final colors = context.colors;
    final style = IconButton.styleFrom(
      backgroundColor: colors.surface,
      side: BorderSide(color: colors.border),
      fixedSize: const Size.square(44),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.controlRadius),
      ),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Prenota',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          IconButton.outlined(
            onPressed: controller.canGoBack ? controller.previous : null,
            tooltip: 'Giorno precedente',
            style: style,
            icon: const Icon(Icons.chevron_left),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              Dates.shortDay(day),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          IconButton.outlined(
            onPressed: controller.next,
            tooltip: 'Giorno successivo',
            style: style,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

class _FreeCourtsChip extends ConsumerWidget {
  const _FreeCourtsChip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferred = ref.watch(preferredTimeProvider).value;
    final colors = context.colors;
    final label = preferred == null
        ? 'Solo campi liberi'
        : 'Solo campi liberi alle ${hhmm(preferred.startMinutes)}';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ActionChip(
          onPressed: () => context.pushNamed(AppRoutes.freeCourts),
          avatar: Icon(Icons.filter_list, size: 18, color: colors.text),
          label: Text(label),
          labelStyle: TextStyle(
            color: colors.text,
            fontWeight: FontWeight.w600,
          ),
          backgroundColor: colors.surface,
          side: BorderSide(color: colors.border),
          shape: const StadiumBorder(),
        ),
      ),
    );
  }
}

class _CourtGrid extends ConsumerStatefulWidget {
  const _CourtGrid({required this.grid, required this.day});

  final DaySchedule grid;
  final DateTime day;

  @override
  ConsumerState<_CourtGrid> createState() => _CourtGridState();
}

class _CourtGridState extends ConsumerState<_CourtGrid> {
  static const rowHeight = 40.0;
  late final ScrollController _scroll = ScrollController(
    initialScrollOffset: _offsetForNow(),
  );

  /// All'apertura di oggi la griglia parte poco prima dell'ora corrente.
  double _offsetForNow() {
    final now = ref.read(clockProvider)();
    if (dateOnly(now) != widget.day) return 0;
    final minutes = now.hour * 60 - openingMinutes - 30;
    return minutes <= 0 ? 0 : minutes / 30 * rowHeight;
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _select(int index) {
    final count = widget.grid.courts.length;
    ref.read(selectedCourtProvider.notifier).select(index.clamp(0, count - 1));
  }

  Future<void> _onFreeTap(CourtRef court, int start) async {
    final free = widget.grid.freeMinutesFrom(court.id, start, closingMinutes);
    if (free < BookingType.lesson.minutes) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Qui ci sono solo $free minuti liberi: una lezione dura '
              "60', una partita 90'.",
            ),
          ),
        );
      return;
    }
    await context.pushNamed(
      AppRoutes.completeBooking,
      extra: BookingSlot(
        court: court,
        date: widget.day,
        startMinutes: start,
        freeMinutes: free,
      ),
    );
  }

  Future<void> _onEventTap(ScheduleEvent event, CourtRef court) async {
    final now = ref.read(clockProvider)();
    final bookingId = event.bookingId;
    if (!event.canUse ||
        bookingId == null ||
        !isBookableStart(widget.day, event.startMinutes, now)) {
      return;
    }
    await confirmAndCancelBooking(
      context,
      ref,
      bookingId: bookingId,
      date: widget.day,
      description:
          '${court.name} · ${Dates.shortDay(widget.day)} · '
          '${hhmm(event.startMinutes)}–${hhmm(event.endMinutes)}',
      hasOpenMatch: event.kind == ScheduleKind.match,
    );
  }

  @override
  Widget build(BuildContext context) {
    final courts = widget.grid.courts;
    final index = ref.watch(selectedCourtProvider).clamp(0, courts.length - 1);
    final court = courts[index];
    return Column(
      children: [
        _CourtTabs(courts: courts, selected: index, onSelected: _select),
        _CourtStepper(courts: courts, selected: index, onSelected: _select),
        Expanded(
          child: GestureDetector(
            // Lo swipe orizzontale cambia campo.
            onHorizontalDragEnd: (details) {
              final velocity = details.primaryVelocity ?? 0;
              if (velocity < -300) _select(index + 1);
              if (velocity > 300) _select(index - 1);
            },
            child: SingleChildScrollView(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: _DayColumn(
                court: court,
                events: widget.grid.eventsFor(court.id),
                day: widget.day,
                rowHeight: rowHeight,
                onFreeTap: (start) => _onFreeTap(court, start),
                onEventTap: (event) => _onEventTap(event, court),
              ),
            ),
          ),
        ),
        const _Legend(),
      ],
    );
  }
}

class _CourtTabs extends StatelessWidget {
  const _CourtTabs({
    required this.courts,
    required this.selected,
    required this.onSelected,
  });

  final List<CourtRef> courts;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        itemCount: courts.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final on = i == selected;
          return Semantics(
            selected: on,
            button: true,
            child: Material(
              color: on ? colors.navy : colors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.controlRadius),
                side: on ? BorderSide.none : BorderSide(color: colors.border),
              ),
              child: InkWell(
                onTap: () => onSelected(i),
                borderRadius: BorderRadius.circular(AppTheme.controlRadius),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Center(
                    child: Text(
                      courts[i].name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: on ? colors.onNavy : colors.text,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CourtStepper extends StatelessWidget {
  const _CourtStepper({
    required this.courts,
    required this.selected,
    required this.onSelected,
  });

  final List<CourtRef> courts;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasPrevious = selected > 0;
    final hasNext = selected < courts.length - 1;
    final buttonStyle = TextButton.styleFrom(
      foregroundColor: colors.textSecondary,
      textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: hasPrevious
                ? TextButton(
                    style: buttonStyle,
                    onPressed: () => onSelected(selected - 1),
                    child: Text(
                      '‹ ${courts[selected - 1].name}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                : null,
          ),
          Expanded(
            child: Semantics(
              label: 'Campo ${selected + 1} di ${courts.length}',
              excludeSemantics: true,
              child: courts.length > 8
                  ? Text(
                      '${selected + 1} di ${courts.length}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.textSecondary),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < courts.length; i++)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: i == selected ? 18 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: i == selected
                                  ? colors.primary
                                  : colors.border,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                      ],
                    ),
            ),
          ),
          SizedBox(
            width: 120,
            child: hasNext
                ? TextButton(
                    style: buttonStyle,
                    onPressed: () => onSelected(selected + 1),
                    child: Text(
                      '${courts[selected + 1].name} ›',
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

/// Colonna oraria e impegni del campo scelto.
class _DayColumn extends ConsumerWidget {
  const _DayColumn({
    required this.court,
    required this.events,
    required this.day,
    required this.rowHeight,
    required this.onFreeTap,
    required this.onEventTap,
  });

  final CourtRef court;
  final List<ScheduleEvent> events;
  final DateTime day;
  final double rowHeight;
  final ValueChanged<int> onFreeTap;
  final ValueChanged<ScheduleEvent> onEventTap;

  double _top(int minutes) => (minutes - openingMinutes) / 30 * rowHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final now = ref.watch(clockProvider)();
    final rows = (closingMinutes - openingMinutes) ~/ 30;
    final mono = context.fonts.monoStyle(fontSize: 11);
    return SizedBox(
      height: rows * rowHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 44,
            child: Column(
              children: [
                for (var r = 0; r < rows; r++)
                  SizedBox(
                    height: rowHeight,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        hhmm(openingMinutes + r * 30),
                        style: mono.copyWith(color: colors.textSecondary),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.controlRadius),
              child: ColoredBox(
                color: colors.slotFree,
                child: Stack(
                  children: [
                    for (var r = 0; r < rows; r++)
                      _FreeRow(
                        top: r * rowHeight,
                        height: rowHeight,
                        start: openingMinutes + r * 30,
                        bookable: isBookableStart(
                          day,
                          openingMinutes + r * 30,
                          now,
                        ),
                        onTap: onFreeTap,
                      ),
                    for (final e in events)
                      Positioned(
                        top: _top(e.startMinutes) + 2,
                        height:
                            (e.endMinutes - e.startMinutes) / 30 * rowHeight -
                            4,
                        left: 4,
                        right: 4,
                        child: _EventBlock(
                          event: e,
                          onTap: () => onEventTap(e),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FreeRow extends StatelessWidget {
  const _FreeRow({
    required this.top,
    required this.height,
    required this.start,
    required this.bookable,
    required this.onTap,
  });

  final double top;
  final double height;
  final int start;
  final bool bookable;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Positioned(
      top: top,
      height: height,
      left: 0,
      right: 0,
      child: Semantics(
        button: bookable,
        label: bookable ? 'Libero alle ${hhmm(start)}, prenota' : null,
        child: InkWell(
          onTap: bookable ? () => onTap(start) : null,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: bookable ? null : colors.divider.withValues(alpha: 0.7),
              border: Border(
                bottom: BorderSide(color: colors.border.withValues(alpha: 0.5)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EventBlock extends StatelessWidget {
  const _EventBlock({required this.event, required this.onTap});

  final ScheduleEvent event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final mine = event.isOwner;
    final (background, title) = switch (event.kind) {
      _ when mine => (
        colors.navy,
        switch (event.kind) {
          ScheduleKind.match => 'La tua partita',
          ScheduleKind.lesson => 'La tua lezione',
          ScheduleKind.training => 'Il tuo allenamento',
          _ => 'La tua prenotazione',
        },
      ),
      ScheduleKind.match => (colors.slotMatch, 'Partita'),
      ScheduleKind.lesson => (colors.slotLesson, 'Lezione'),
      ScheduleKind.training => (colors.slotTraining, 'Allenamento'),
      _ => (colors.slotBooked, 'Prenotato'),
    };
    final foreground = mine ? colors.onNavy : colors.text;
    final range = '${hhmm(event.startMinutes)}–${hhmm(event.endMinutes)}';
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: foreground,
                  ),
                ),
              ),
              Text(
                range,
                style: TextStyle(
                  fontSize: 12,
                  color: foreground.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Widget item(Color color, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: colors.border),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: colors.textSecondary),
        ),
      ],
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(68, 4, 16, 8),
      child: Wrap(
        spacing: 12,
        runSpacing: 4,
        children: [
          item(colors.slotFree, 'Libero'),
          item(colors.navy, 'Tuo'),
          item(colors.slotMatch, 'Partita'),
          item(colors.slotBooked, 'Prenotato'),
          item(colors.slotLesson, 'Lezione'),
          item(colors.slotTraining, 'Allenamento'),
        ],
      ),
    );
  }
}
