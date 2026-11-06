import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../bookings/domain/booking.dart';
import '../../bookings/domain/booking_request.dart';
import '../../bookings/domain/schedule.dart';
import '../../bookings/presentation/book_providers.dart';
import '../../bookings/presentation/complete_booking_controller.dart';
import 'admin_menu_button.dart';

/// Creazione amministrativa semplificata: niente griglia dei campi, soltanto
/// data, campo e orario. Disponibilità e conflitti restano verificati dal
/// calendario e nuovamente dall'API al momento della conferma.
class AdminCreateMatchScreen extends ConsumerStatefulWidget {
  const AdminCreateMatchScreen({super.key});

  @override
  ConsumerState<AdminCreateMatchScreen> createState() =>
      _AdminCreateMatchScreenState();
}

class _AdminCreateMatchScreenState
    extends ConsumerState<AdminCreateMatchScreen> {
  static const _firstStartMinutes = 8 * 60;
  static const _lastStartMinutes = 22 * 60;
  static const _closingMinutes = 23 * 60 + 30;

  late DateTime _day;
  String? _courtId;
  int? _startMinutes;

  @override
  void initState() {
    super.initState();
    final now = ref.read(clockProvider)();
    _day = DateTime(now.year, now.month, now.day);
  }

  Future<void> _pickDay() async {
    final now = ref.read(clockProvider)();
    final today = DateTime(now.year, now.month, now.day);
    final selected = await showDatePicker(
      context: context,
      initialDate: _day,
      firstDate: today,
      lastDate: DateTime(today.year + 2, today.month, today.day),
      locale: const Locale('it', 'IT'),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _day = selected;
      _courtId = null;
      _startMinutes = null;
    });
  }

  bool _isAvailable(DaySchedule schedule, String courtId, int start) {
    final now = ref.read(clockProvider)();
    return isBookableStart(_day, start, now) &&
        schedule.isFree(courtId, start, start + BookingType.court.minutes);
  }

  void _continue(DaySchedule schedule) {
    final courtId = _courtId;
    final start = _startMinutes;
    if (courtId == null || start == null) return;
    final court = schedule.courts
        .where((item) => item.id == courtId)
        .firstOrNull;
    if (court == null || !_isAvailable(schedule, courtId, start)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Questo campo o questo orario non è più disponibile. '
            'Scegli un’altra fascia.',
          ),
        ),
      );
      ref.invalidate(scheduleProvider(_day));
      setState(() => _startMinutes = null);
      return;
    }

    final freeMinutes = schedule.freeMinutesFrom(
      court.id,
      start,
      _closingMinutes,
    );
    context.pushNamed(
      AppRoutes.adminCompleteMatch,
      extra: BookingSlot(
        court: court,
        date: _day,
        startMinutes: start,
        freeMinutes: freeMinutes,
        initialType: BookingType.court,
        initialMatchType: 'ranking',
        initialMatchLevel: 'qualsiasi',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final schedule = ref.watch(scheduleProvider(_day));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crea partita'),
        actions: const [AdminMenuButton()],
      ),
      body: AsyncValueView(
        value: schedule,
        errorText: 'Non riesco a caricare campi e disponibilità',
        onRetry: () => ref.invalidate(scheduleProvider(_day)),
        data: (grid) => _buildForm(context, grid),
      ),
    );
  }

  Widget _buildForm(BuildContext context, DaySchedule schedule) {
    if (_courtId != null &&
        !schedule.courts.any((court) => court.id == _courtId)) {
      _courtId = null;
      _startMinutes = null;
    }
    final selectedCourtId = _courtId;
    final starts = [
      for (
        var start = _firstStartMinutes;
        start <= _lastStartMinutes;
        start += 30
      )
        start,
    ];
    final availableStarts = selectedCourtId == null
        ? const <int>[]
        : starts
              .where((start) => _isAvailable(schedule, selectedCourtId, start))
              .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.colors.primaryTint,
            borderRadius: BorderRadius.circular(AppTheme.controlRadius),
            border: Border.all(
              color: context.colors.primary.withValues(alpha: .4),
            ),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.schedule_outlined, size: 22),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Le partite durano 1 ora e 30 minuti. Scegli un campo e "
                  "un orario libero: la fine viene calcolata automaticamente.",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        InkWell(
          onTap: _pickDay,
          borderRadius: BorderRadius.circular(AppTheme.controlRadius),
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Data della partita',
              suffixIcon: Icon(Icons.calendar_today_outlined),
            ),
            child: Text(Dates.numeric(_day)),
          ),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          key: ValueKey('court-${Dates.api(_day)}'),
          initialValue: _courtId,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Campo',
            prefixIcon: Icon(Icons.sports_tennis_outlined),
          ),
          items: [
            for (final court in schedule.courts)
              DropdownMenuItem(value: court.id, child: Text(court.name)),
          ],
          onChanged: schedule.courts.isEmpty
              ? null
              : (value) => setState(() {
                  _courtId = value;
                  _startMinutes = null;
                }),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<int>(
          key: ValueKey('time-${Dates.api(_day)}-$selectedCourtId'),
          initialValue: _startMinutes,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Orario',
            prefixIcon: Icon(Icons.schedule),
          ),
          items: [
            for (final start in starts)
              DropdownMenuItem(
                value: start,
                enabled:
                    selectedCourtId != null && availableStarts.contains(start),
                child: Text(
                  '${hhmm(start)} – '
                  '${hhmm(start + BookingType.court.minutes)}'
                  '${selectedCourtId != null && !availableStarts.contains(start) ? ' · non disponibile' : ''}',
                ),
              ),
          ],
          onChanged: selectedCourtId == null
              ? null
              : (value) => setState(() => _startMinutes = value),
        ),
        const SizedBox(height: 8),
        Text(
          selectedCourtId == null
              ? 'Seleziona prima il campo.'
              : availableStarts.isEmpty
              ? 'Non ci sono fasce libere da 90 minuti per questo campo.'
              : 'Orari disponibili dalle 08:00; ultimo inizio alle 22:00.',
          style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _courtId != null && _startMinutes != null
              ? () => _continue(schedule)
              : null,
          icon: const Icon(Icons.arrow_forward),
          label: const Text('Continua con giocatori e dettagli'),
        ),
      ],
    );
  }
}
