import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../bookings/data/bookings_repository.dart';
import '../../bookings/domain/booking.dart';
import '../../bookings/domain/booking_request.dart';
import '../../bookings/domain/schedule.dart';
import '../../bookings/presentation/complete_booking_controller.dart';
import 'admin_menu_button.dart';

final _adminMatchCourtsProvider = FutureProvider.autoDispose<List<CourtRef>>(
  (ref) async => [
    for (final court in await ref.read(bookingsRepositoryProvider).courts())
      CourtRef(id: court.id, name: court.name),
  ],
);

/// Registrazione amministrativa diretta: non crea e non richiede una
/// prenotazione, così si possono inserire anche partite già disputate.
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
      firstDate: DateTime(2020),
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

  void _continue(List<CourtRef> courts) {
    final courtId = _courtId;
    final start = _startMinutes;
    if (courtId == null || start == null) return;
    final court = courts.where((item) => item.id == courtId).firstOrNull;
    if (court == null) return;

    context.pushNamed(
      AppRoutes.adminCompleteMatch,
      extra: BookingSlot(
        court: court,
        date: _day,
        startMinutes: start,
        freeMinutes: BookingType.court.minutes,
        initialType: BookingType.court,
        initialMatchType: 'ranking',
        initialMatchLevel: 'qualsiasi',
        directMatch: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final courts = ref.watch(_adminMatchCourtsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crea partita'),
        actions: const [AdminMenuButton()],
      ),
      body: AsyncValueView(
        value: courts,
        errorText: 'Non riesco a caricare i campi',
        onRetry: () => ref.invalidate(_adminMatchCourtsProvider),
        data: (items) => _buildForm(context, items),
      ),
    );
  }

  Widget _buildForm(BuildContext context, List<CourtRef> courts) {
    if (_courtId != null && !courts.any((court) => court.id == _courtId)) {
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
              Icon(Icons.history_outlined, size: 22),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Registrazione diretta: non crea una prenotazione. Puoi '
                  'inserire anche una partita già disputata; la fine viene '
                  'calcolata automaticamente dopo 1 ora e 30 minuti.',
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
            for (final court in courts)
              DropdownMenuItem(value: court.id, child: Text(court.name)),
          ],
          onChanged: courts.isEmpty
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
                child: Text(
                  '${hhmm(start)} – '
                  '${hhmm(start + BookingType.court.minutes)}',
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
              : 'Orari dalle 08:00; ultimo inizio alle 22:00. La partita '
                    'non è vincolata a una prenotazione.',
          style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _courtId != null && _startMinutes != null
              ? () => _continue(courts)
              : null,
          icon: const Icon(Icons.arrow_forward),
          label: const Text('Continua con giocatori e dettagli'),
        ),
      ],
    );
  }
}
