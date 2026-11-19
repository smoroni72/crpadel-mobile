import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/match_score.dart';

class MatchResultSubmission {
  const MatchResultSubmission({this.score, this.resultOutcome = 'normal'});

  final String? score;
  final String resultOutcome;
}

/// Pannello per inserire il risultato oppure chiudere una partita per tempo
/// scaduto, con parziale facoltativo.
Future<MatchResultSubmission?> showResultSheet(BuildContext context) =>
    showModalBottomSheet<MatchResultSubmission>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _ResultSheet(),
    );

class _ResultSheet extends StatefulWidget {
  const _ResultSheet();

  @override
  State<_ResultSheet> createState() => _ResultSheetState();
}

class _ResultSheetState extends State<_ResultSheet> {
  final _games = List.generate(6, (_) => TextEditingController());
  var _third = ThirdSet.none;
  var _timeExpired = false;
  String? _error;

  @override
  void dispose() {
    for (final c in _games) {
      c.dispose();
    }
    super.dispose();
  }

  int? _value(int i) => int.tryParse(_games[i].text);

  void _save() {
    if (_timeExpired) {
      final parts = <String>[];
      for (var i = 0; i < 6; i += 2) {
        final left = _games[i].text.trim();
        final right = _games[i + 1].text.trim();
        if ((left.isEmpty) != (right.isEmpty)) {
          setState(
            () => _error =
                'Completa entrambi i valori del parziale oppure lasciali vuoti',
          );
          return;
        }
        if (left.isNotEmpty) parts.add('$left-$right');
      }
      Navigator.pop(
        context,
        MatchResultSubmission(
          score: parts.isEmpty ? null : parts.join(' '),
          resultOutcome: 'time_expired',
        ),
      );
      return;
    }
    final score = MatchScore(
      set1: (_value(0), _value(1)),
      set2: (_value(2), _value(3)),
      thirdSet: _third,
      set3: (_value(4), _value(5)),
    );
    final error = score.error;
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.pop(context, MatchResultSubmission(score: score.value));
  }

  Widget _setRow(String label, int first) {
    final mono = context.fonts.monoStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
    );
    Widget field(int i, String team) => SizedBox(
      width: 72,
      child: TextField(
        controller: _games[i],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: mono,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(2),
        ],
        decoration: InputDecoration(labelText: team),
        onChanged: (_) => setState(() => _error = null),
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          field(first, 'Sq. A'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('–'),
          ),
          field(first + 1, 'Sq. B'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Inserisci il risultato',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: false, label: Text('Terminata')),
                ButtonSegment(value: true, label: Text('Tempo scaduto')),
              ],
              selected: {_timeExpired},
              onSelectionChanged: (selection) => setState(() {
                _timeExpired = selection.first;
                _error = null;
              }),
            ),
            const SizedBox(height: 8),
            Text(
              _timeExpired
                  ? 'Non terminata per mancanza di tempo: il parziale è facoltativo e tutti e quattro risultano sconfitti nel ranking.'
                  : 'Il punteggio determina vincitori e sconfitti.',
              style: TextStyle(fontSize: 12, color: colors.textSecondary),
            ),
            const SizedBox(height: 8),
            _setRow('1° set', 0),
            _setRow('2° set', 2),
            Text(
              'Terzo set',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<ThirdSet>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: ThirdSet.none, label: Text('Nessuno')),
                ButtonSegment(value: ThirdSet.set, label: Text('Set')),
                ButtonSegment(
                  value: ThirdSet.tiebreak,
                  label: Text('Tiebreak'),
                ),
              ],
              selected: {_third},
              onSelectionChanged: (s) => setState(() {
                _third = s.first;
                _error = null;
              }),
            ),
            if (_third != ThirdSet.none) ...[
              const SizedBox(height: 12),
              _setRow(_third == ThirdSet.tiebreak ? 'Tiebreak' : '3° set', 4),
            ],
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error!,
                  style: TextStyle(color: colors.primaryText),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Salva risultato'),
            ),
          ],
        ),
      ),
    );
  }
}
