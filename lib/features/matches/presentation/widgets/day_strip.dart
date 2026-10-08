import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/dates.dart';

/// Selettore del giorno: frecce ‹ › e 5 giorni con quello scelto al centro.
class DayStrip extends StatelessWidget {
  const DayStrip({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime selected;
  final ValueChanged<DateTime> onSelected;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final days = [
      for (var offset = -2; offset <= 2; offset++)
        DateTime(selected.year, selected.month, selected.day + offset),
    ];
    return Row(
      children: [
        IconButton(
          onPressed: onPrevious,
          tooltip: 'Giorno precedente',
          icon: Icon(Icons.chevron_left, color: colors.textSecondary),
        ),
        for (final day in days)
          Expanded(
            child: _DayChip(
              day: day,
              selected: day == selected,
              onTap: () => onSelected(day),
            ),
          ),
        IconButton(
          onPressed: onNext,
          tooltip: 'Giorno successivo',
          icon: Icon(Icons.chevron_right, color: colors.textSecondary),
        ),
      ],
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.day,
    required this.selected,
    required this.onTap,
  });

  final DateTime day;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fg = selected ? colors.onPrimary : colors.textSecondary;
    return Semantics(
      button: true,
      selected: selected,
      label: Dates.longDay(day),
      excludeSemantics: true,
      onTap: onTap,
      child: Center(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.controlRadius),
          child: Container(
            width: 46,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: selected ? colors.primary : null,
              borderRadius: BorderRadius.circular(AppTheme.controlRadius),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  Dates.weekdayBadge(day),
                  style: TextStyle(fontSize: 12, color: fg),
                ),
                Text(
                  '${day.day}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: selected ? colors.onPrimary : colors.text,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
