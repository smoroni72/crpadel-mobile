Map<String, dynamic>? performanceDetails(Map<String, dynamic>? detail) {
  final value = (detail?['performance_expectation'] as Map?)?['period'] as Map?;
  if (value == null) return null;
  final excluded = (value['excluded_matches'] as num?)?.toInt() ?? 0;
  final rows = <Map<String, dynamic>>[];
  if (excluded > 0) {
    for (final raw in (detail?['matches'] as List? ?? [])) {
      final m = raw as Map;
      if (m['status'] != 'completed' || m['match_type'] != 'ranking') continue;
      String? reason;
      if (m['result_outcome'] == 'unfinished') {
        reason = 'Partita non terminata';
      } else if (m['result_outcome'] == 'time_expired') {
        reason = 'Tempo scaduto, senza vincitore';
      } else if (m['winner_team'] == null) {
        reason = 'Vincitore non disponibile';
      } else if ((value['calibration_since'] != null &&
              '${m['date']}'.compareTo('${value['calibration_since']}') < 0) ||
          (value['calibration_through'] != null &&
              '${m['date']}'.compareTo('${value['calibration_through']}') >
                  0)) {
        reason = 'Fuori dal periodo di calcolo';
      } else {
        final coefficients = m['team_coefficients'] as Map? ?? {};
        bool valid(dynamic v) {
          final n = num.tryParse('$v');
          return n != null && n.isFinite && n > 0;
        }

        if (!valid(coefficients['A']) || !valid(coefficients['B'])) {
          reason = 'Coefficienti di coppia non disponibili';
        }
      }
      if (reason != null) {
        rows.add({
          'id': m['id'],
          'date': m['date'],
          'time': m['time_slot'],
          'reason': reason,
        });
      }
    }
  }
  return {
    ...Map<String, dynamic>.from(value),
    'excluded_details': rows.take(excluded).toList(),
  };
}

int countTimeExpired(List<dynamic> matches, {bool rankingOnly = false}) {
  final ids = <Object>{};
  for (final (i, row) in matches.indexed) {
    if (row is! Map ||
        row['status'] != 'completed' ||
        row['result_outcome'] != 'time_expired') {
      continue;
    }
    if (rankingOnly && row['match_type'] != 'ranking') continue;
    ids.add(row['id'] ?? i);
  }
  return ids.length;
}
