import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/info_card.dart';
import '../data/bookings_repository.dart';
import '../data/preferred_time_repository.dart';
import '../domain/booking.dart';
import '../domain/booking_request.dart';
import '../domain/schedule.dart';
import 'book_providers.dart';
import 'complete_booking_controller.dart';
import 'widgets/preferred_time_sheet.dart';

/// Solo campi liberi: a che ora si può giocare una partita da 90'.
class FreeCourtsScreen extends ConsumerStatefulWidget {
  const FreeCourtsScreen({super.key});

  @override
  ConsumerState<FreeCourtsScreen> createState() => _FreeCourtsScreenState();
}

class _FreeCourtsScreenState extends ConsumerState<FreeCourtsScreen> {
  static final _duration = BookingType.court.minutes;
  int? _selected;

  /// Orario proposto: il primo nella fascia preferita, altrimenti l'ora
  /// intera successiva.
  int _defaultStart(List<AvailabilitySlot> slots, PreferredTime? preferred) {
    if (preferred != null) {
      for (final s in slots) {
        if (preferred.includes(s.startMinutes)) return s.startMinutes;
      }
    }
    final now = ref.read(clockProvider)();
    final next = (now.hour + 1) * 60;
    for (final s in slots) {
      if (s.startMinutes >= next) return s.startMinutes;
    }
    return slots.first.startMinutes;
  }

  void _book(DateTime day, CourtRef court, int start) {
    final grid = ref.read(scheduleProvider(day)).value;
    final free =
        grid?.freeMinutesFrom(court.id, start, closingMinutes) ?? _duration;
    context.pushNamed(
      AppRoutes.completeBooking,
      extra: BookingSlot(
        court: court,
        date: day,
        startMinutes: start,
        freeMinutes: free,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final day = ref.watch(bookDayProvider);
    final now = ref.watch(clockProvider)();
    final preferred = ref.watch(preferredTimeProvider).value;
    final availability = ref.watch(availabilityProvider((day, _duration)));
    final details = ref.watch(courtDetailsProvider).value ?? const {};
    // Serve per sapere quanto spazio c'è dopo i 90' (passato alla conferma).
    ref.watch(scheduleProvider(day));
    final colors = context.colors;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Campi liberi'),
            Text(
              "${Dates.longDay(day)} · partita 90'",
              style: TextStyle(fontSize: 13, color: colors.textSecondary),
            ),
          ],
        ),
      ),
      body: AsyncValueView(
        value: availability,
        errorText: 'Non riesco a caricare i campi liberi',
        onRetry: () => ref.invalidate(availabilityProvider((day, _duration))),
        data: (all) {
          final slots = [
            for (final s in all)
              if (s.availableCourts.isNotEmpty &&
                  isBookableStart(day, s.startMinutes, now))
                s,
          ];
          if (slots.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "Nessun campo libero per una partita da 90' in questo giorno.",
              ),
            );
          }
          final start = slots.any((s) => s.startMinutes == _selected)
              ? _selected!
              : _defaultStart(slots, preferred);
          final current = slots.firstWhere((s) => s.startMinutes == start);
          final currentIds = {for (final c in current.availableCourts) c.id};
          AvailabilitySlot? later;
          CourtRef? laterCourt;
          for (final s in slots) {
            if (s.startMinutes <= start || s.startMinutes > start + 60) {
              continue;
            }
            final candidate = s.availableCourts
                .where((c) => !currentIds.contains(c.id))
                .firstOrNull;
            if (candidate != null) {
              later = s;
              laterCourt = candidate;
              break;
            }
          }
          final count = current.availableCourts.length;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Text(
                'Inizio partita',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              _StartChips(
                slots: slots,
                selected: start,
                preferred: preferred,
                onSelected: (m) => setState(() => _selected = m),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      preferred == null
                          ? 'Nessun orario preferito'
                          : '★ Il tuo orario preferito: ${preferred.label}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => showPreferredTimeSheet(context),
                    child: Text(preferred == null ? 'Imposta' : 'Modifica'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                count == 1
                    ? '1 campo libero alle ${hhmm(start)}'
                    : '$count campi liberi alle ${hhmm(start)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              for (final court in current.availableCourts) ...[
                _CourtCard(
                  court: court,
                  details: details[court.id],
                  start: start,
                  buttonLabel: 'Prenota',
                  primary: true,
                  onPressed: () => _book(day, court, start),
                ),
                const SizedBox(height: 10),
              ],
              if (later != null && laterCourt != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Oppure, poco dopo',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 10),
                _CourtCard(
                  court: laterCourt,
                  details: details[laterCourt.id],
                  start: later.startMinutes,
                  buttonLabel: hhmm(later.startMinutes),
                  primary: false,
                  onPressed: () => _book(day, laterCourt!, later!.startMinutes),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _StartChips extends StatefulWidget {
  const _StartChips({
    required this.slots,
    required this.selected,
    required this.preferred,
    required this.onSelected,
  });

  final List<AvailabilitySlot> slots;
  final int selected;
  final PreferredTime? preferred;
  final ValueChanged<int> onSelected;

  @override
  State<_StartChips> createState() => _StartChipsState();
}

class _StartChipsState extends State<_StartChips> {
  final _selectedKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _revealSelected();
  }

  @override
  void didUpdateWidget(_StartChips old) {
    super.didUpdateWidget(old);
    if (old.selected != widget.selected) _revealSelected();
  }

  /// L'orario scelto (es. quello preferito) deve essere visibile.
  void _revealSelected() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _selectedKey.currentContext;
      if (target != null && mounted) {
        Scrollable.ensureVisible(
          target,
          alignment: 0.3,
          duration: const Duration(milliseconds: 200),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final mono = context.fonts.monoStyle(fontSize: 13);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final slot in widget.slots) ...[
            Builder(
              builder: (context) {
                final m = slot.startMinutes;
                final on = m == widget.selected;
                final star = widget.preferred?.includes(m) ?? false;
                return Semantics(
                  key: on ? _selectedKey : null,
                  selected: on,
                  button: true,
                  child: Material(
                    color: on
                        ? colors.primary
                        : star
                        ? colors.primaryTint
                        : colors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppTheme.controlRadius,
                      ),
                      side: on
                          ? BorderSide.none
                          : BorderSide(color: colors.border),
                    ),
                    child: InkWell(
                      onTap: () => widget.onSelected(m),
                      borderRadius: BorderRadius.circular(
                        AppTheme.controlRadius,
                      ),
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        alignment: Alignment.center,
                        child: Text.rich(
                          TextSpan(
                            text: hhmm(m),
                            children: [
                              // La stella non c'è nel font mono.
                              if (star)
                                TextSpan(
                                  text: ' ★',
                                  style: TextStyle(
                                    fontFamily: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.fontFamily,
                                  ),
                                ),
                            ],
                          ),
                          semanticsLabel: star
                              ? '${hhmm(m)}, orario preferito'
                              : hhmm(m),
                          style: mono.copyWith(
                            color: on ? colors.onPrimary : colors.text,
                            fontWeight: on ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _CourtCard extends StatelessWidget {
  const _CourtCard({
    required this.court,
    required this.details,
    required this.start,
    required this.buttonLabel,
    required this.primary,
    required this.onPressed,
  });

  final CourtRef court;
  final Court? details;
  final int start;
  final String buttonLabel;
  final bool primary;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final extra = details?.details ?? '';
    final range = '${hhmm(start)}–${hhmm(start + BookingType.court.minutes)}';
    return InfoCard(
      leading: const SizedBox.shrink(),
      title: court.name,
      subtitle: extra.isEmpty ? range : '$range · $extra',
      trailing: primary
          ? ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Text(buttonLabel),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Text(buttonLabel),
            ),
    );
  }
}
