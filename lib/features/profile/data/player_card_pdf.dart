import 'dart:ui' as ui;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart' show TextPainter, TextSpan, TextStyle;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/config/app_environment.dart';

const playerAnimals = {
  'Leone': '🦁',
  'Tigre': '🐯',
  'Lupo': '🐺',
  'Volpe': '🦊',
  'Gatto': '🐱',
  'Coniglio': '🐰',
};
String playerCardFilename(String name) =>
    'carta-giocatore-${name.toLowerCase().replaceAll(RegExp(r"[^a-z0-9]+"), '-')}.pdf';
Map<String, dynamic> _map(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : {};
String _number(dynamic v, [int decimals = 0]) => v is num
    ? NumberFormat(
        decimals == 0 ? '0' : '0.${'0' * decimals}',
        'it_IT',
      ).format(v)
    : '-';
String _date(dynamic v) {
  final d = DateTime.tryParse('$v');
  return d == null ? 'Non indicata' : DateFormat('dd/MM/yyyy').format(d);
}

Future<Uint8List> createPlayerCardPdf(Map<String, dynamic> data) async {
  final p = _map(_map(data['card'])['player']);
  Uint8List? photo;
  if (p['photo_url'] is String) {
    final uri = Uri.parse(
      AppEnvironment.apiBaseUrl,
    ).resolve(p['photo_url'] as String);
    final origin = Uri.parse(AppEnvironment.apiBaseUrl);
    if (uri.origin == origin.origin &&
        uri.path.startsWith('/api/v1/storage/files/')) {
      try {
        final r = await Dio().get<List<int>>(
          uri.toString(),
          options: Options(responseType: ResponseType.bytes),
          onReceiveProgress: (n, _) {
            if (n > 8 * 1024 * 1024) throw StateError('Immagine troppo grande');
          },
        );
        photo = Uint8List.fromList(r.data!);
      } catch (_) {
        photo = null;
      }
    }
  }
  final stats = _map(data['period'] ?? data['totals']);
  final emoji = playerAnimals[stats['challenge_animal']];
  Uint8List? animal;
  if (emoji != null) {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final painter = TextPainter(
      text: TextSpan(text: emoji, style: const TextStyle(fontSize: 180)),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      ui.Offset((256 - painter.width) / 2, (256 - painter.height) / 2),
    );
    final picture = recorder.endRecording();
    final image = await picture.toImage(256, 256);
    animal = (await image.toByteData(
      format: ui.ImageByteFormat.png,
    ))?.buffer.asUint8List();
    image.dispose();
    picture.dispose();
    painter.dispose();
  }
  return buildPlayerCardPdf(
    data,
    font: await rootBundle.load('assets/fonts/Inter-Regular.ttf'),
    bold: await rootBundle.load('assets/fonts/Inter-SemiBold.ttf'),
    logo: (await rootBundle.load(
      'assets/brand/crpadel_logo.png',
    )).buffer.asUint8List(),
    photo: photo,
    animal: animal,
  );
}

Future<Uint8List> buildPlayerCardPdf(
  Map<String, dynamic> data, {
  required ByteData font,
  required ByteData bold,
  Uint8List? logo,
  Uint8List? photo,
  Uint8List? animal,
}) async {
  final card = _map(data['card']);
  final player = _map(card['player']);
  if (player['name'] == null) {
    throw StateError('Carta giocatore non disponibile');
  }
  final ranking = _map(card['ranking']);
  final stats = _map(data['period'] ?? data['totals']);
  final h = _map(data['highlights']);
  final e = _map(_map(data['performance_expectation'])['period']);
  final navy = PdfColor.fromHex('#111d32');
  final muted = PdfColor.fromHex('#6b778b');
  final green = PdfColor.fromHex('#239b65');
  final red = PdfColor.fromHex('#cd302c');
  final doc = pw.Document(
    title: 'Carta giocatore - ${player['name']}',
    author: _map(card['club'])['name']?.toString() ?? 'CRPADEL',
  );
  final theme = pw.ThemeData.withFont(
    base: pw.Font.ttf(font),
    bold: pw.Font.ttf(bold),
  );
  pw.Widget txt(
    dynamic v, [
    double size = 10,
    PdfColor? color,
    bool strong = false,
  ]) => pw.Text(
    '$v',
    style: pw.TextStyle(
      fontSize: size,
      color: color ?? navy,
      fontWeight: strong ? pw.FontWeight.bold : null,
    ),
  );
  pw.Widget title(String s) => pw.Padding(
    padding: const pw.EdgeInsets.only(top: 10, bottom: 7),
    child: txt(s, 16, navy, true),
  );
  pw.Widget panel(List<pw.Widget> children, {PdfColor? color}) => pw.Container(
    width: double.infinity,
    margin: const pw.EdgeInsets.only(bottom: 10),
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      color: color ?? PdfColors.white,
      border: pw.Border.all(color: PdfColor.fromHex('#e2e5ec')),
      borderRadius: pw.BorderRadius.circular(12),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: children,
    ),
  );
  pw.Widget metrics(List<(String, String)> items) => pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      for (final item in items)
        pw.Expanded(
          child: pw.Padding(
            padding: const pw.EdgeInsets.only(right: 8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                txt(item.$2, 20, navy, true),
                pw.SizedBox(height: 5),
                txt(item.$1, 8, muted),
              ],
            ),
          ),
        ),
    ],
  );
  pw.Widget header(pw.Context _) => pw.Container(
    padding: const pw.EdgeInsets.only(bottom: 14),
    child: pw.Row(
      children: [
        if (logo != null) ...[
          pw.Image(pw.MemoryImage(logo), width: 23, height: 32),
          pw.SizedBox(width: 10),
        ],
        txt('CRPADEL / CARTA GIOCATORE', 10, navy, true),
        pw.Spacer(),
        pw.SizedBox(
          width: 230,
          child: pw.Text(
            '${player['name']}',
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
        ),
      ],
    ),
  );
  pw.Widget footer(pw.Context c) => pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      txt('Dati registrati al ${_date(card['as_of'])}', 7, muted),
      txt('${c.pageNumber} / ${c.pagesCount}', 7, muted),
    ],
  );
  void page(List<pw.Widget> children) => doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      theme: theme,
      header: header,
      footer: footer,
      build: (_) => children,
    ),
  );
  final name = '${player['name']}';
  page([
    panel([
      pw.Row(
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                txt(name.toUpperCase(), 27, navy, true),
                pw.SizedBox(height: 12),
                txt(
                  'Fascia ${ranking['band_name'] ?? 'non assegnata'}',
                  12,
                  muted,
                ),
              ],
            ),
          ),
          pw.SizedBox(
            width: 90,
            height: 90,
            child: photo != null
                ? pw.ClipOval(
                    child: pw.Image(
                      pw.MemoryImage(photo),
                      fit: pw.BoxFit.cover,
                    ),
                  )
                : pw.Center(
                    child: txt(
                      name
                          .split(' ')
                          .take(2)
                          .map((s) => s.isEmpty ? '' : s[0])
                          .join(),
                      28,
                      navy,
                      true,
                    ),
                  ),
          ),
        ],
      ),
      pw.SizedBox(height: 18),
      metrics([
        (
          'Posizione',
          ranking['position'] == null ? '-' : '${ranking['position']}°',
        ),
        ('Punti classifica', _number(ranking['points'], 2)),
        ('Coefficiente', _number(ranking['coefficient'], 2)),
      ]),
    ]),
    panel([
      txt('DATI DEL GIOCATORE', 9, muted, true),
      pw.SizedBox(height: 10),
      txt(
        'Nascita da verificare: ${player['personal_data_visible'] == true ? _date(player['birth_date']) : 'Non pubblicata'}',
        9,
      ),
      pw.SizedBox(height: 5),
      txt(
        'Lato di gioco: ${{'DX': 'Destra', 'SX': 'Sinistra'}[player['preferred_side']] ?? 'Non indicato'}',
        9,
      ),
    ]),
    title('Il bilancio'),
    panel([
      metrics([
        ('Partite', _number(stats['matches_played'])),
        ('Vittorie', _number(stats['wins'])),
        ('Sconfitte', _number(stats['losses'])),
        ('Non terminate', _number(stats['unfinished_matches'])),
      ]),
    ]),
    title('Indice di sfida'),
    panel([
      pw.Row(
        children: [
          if (animal != null) ...[
            pw.Image(pw.MemoryImage(animal), width: 70, height: 70),
            pw.SizedBox(width: 16),
          ],
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                txt(
                  playerAnimals.containsKey(stats['challenge_animal'])
                      ? stats['challenge_animal']
                      : 'Da definire',
                  24,
                  navy,
                  true,
                ),
                txt('${_number(stats['challenge_index'], 2)}/100', 25),
                txt(
                  '${stats['challenge_matches'] ?? 0} partite Ranking valutate',
                  9,
                  muted,
                ),
              ],
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 8),
      txt(
        'Leone 95-100 / Tigre 90-<95 / Lupo 85-<90 / Volpe 80-<85 / Gatto 70-<80 / Coniglio <70',
        8,
        muted,
      ),
    ], color: PdfColor.fromHex('#fff7e4')),
    title('Forma recente'),
    panel([
      txt(
        (_map(h['current_streak'])['count'] ?? 0) == 0
            ? 'Nessuna serie disponibile'
            : '${_map(h['current_streak'])['count']} ${_map(h['current_streak'])['type'] == 'win' ? 'vittorie' : 'sconfitte'} consecutive',
        12,
        navy,
        true,
      ),
      pw.SizedBox(height: 8),
      txt((h['badges'] as List? ?? []).join(' / '), 9, muted),
    ]),
  ]);
  final ready = e['status'] == 'ready';
  final raw = (e['extra_wins_per_10'] as num?)?.toDouble();
  final delta = raw != null && raw.abs() < .005 ? 0.0 : raw;
  String person(dynamic v) {
    final p = _map(v);
    return '${p['name']} - ${p['matches']} partite, ${p['wins']} V / ${p['losses']} S';
  }

  page([
    title('Rendimento tecnico'),
    panel([
      metrics([
        (
          'Set vinti / persi',
          '${stats['sets_won'] ?? 0} / ${stats['sets_lost'] ?? 0}',
        ),
        (
          'Game vinti / persi',
          '${stats['games_won'] ?? 0} / ${stats['games_lost'] ?? 0}',
        ),
        (
          'Tie-break giocati / vinti',
          '${stats['tiebreaks_played'] ?? 0} / ${stats['tiebreaks_won'] ?? 0}',
        ),
      ]),
    ]),
    title('Analisi Ranking'),
    panel([
      metrics([
        ('Da sfavorito', _number(stats['underdog_matches'])),
        ('Da favorito', _number(stats['favorite_matches'])),
        ('A parità', _number(stats['equal_matches'])),
        ('Non terminate', _number(stats['unfinished_ranking_matches'])),
      ]),
    ]),
    title('Rendimento rispetto alle attese'),
    panel([
      txt(
        ready && delta != null
            ? '${delta >= 0 ? '+' : '-'}${_number(delta.abs(), 2)}'
            : '-',
        32,
        delta != null && delta < 0 ? red : green,
        true,
      ),
      txt('vittorie ogni 10 partite rispetto alle attese', 10),
      pw.SizedBox(height: 15),
      metrics([
        ('Partite valutate', _number(e['matches_played'])),
        ('Vittorie ottenute', _number(e['wins'])),
        ('Vittorie attese', ready ? _number(e['expected_wins'], 1) : '-'),
      ]),
      if (!ready) ...[
        pw.SizedBox(height: 10),
        txt(
          e['status'] == 'no_matches'
              ? 'Nessuna partita valutabile.'
              : 'Dati insufficienti per una stima.',
          9,
        ),
      ],
    ], color: PdfColor.fromHex('#fff7e4')),
    title('Compagni e avversari'),
    txt(
      '${h['partners_count'] ?? 0} compagni / ${h['opponents_count'] ?? 0} avversari distinti',
      9,
      muted,
    ),
    pw.SizedBox(height: 8),
    panel([
      txt('Compagni più frequenti', 10, navy, true),
      for (final p in (h['most_frequent_partners'] as List? ?? [])) ...[
        pw.SizedBox(height: 6),
        txt(person(p), 9),
      ],
      if ((h['most_frequent_partners'] as List? ?? []).isEmpty)
        txt('Non disponibili', 9, muted),
    ]),
    panel([
      txt('Miglior compagno per rendimento', 10, navy, true),
      pw.SizedBox(height: 6),
      txt(
        h['best_partner'] == null
            ? 'Non disponibile'
            : person(h['best_partner']),
        9,
      ),
      pw.SizedBox(height: 12),
      txt('Avversario più affrontato', 10, navy, true),
      pw.SizedBox(height: 6),
      txt(
        h['most_faced_opponent'] == null
            ? 'Non disponibile'
            : person(h['most_faced_opponent']),
        9,
      ),
    ]),
  ]);
  final matches =
      (data['matches'] as List? ?? [])
          .map(_map)
          .where(
            (m) =>
                m['status'] == 'completed' &&
                m['result_outcome'] != 'unfinished' &&
                (m['winner_team'] != null ||
                    m['result_outcome'] == 'time_expired'),
          )
          .toList()
        ..sort(
          (a, b) => '${b['date']} ${b['time_slot']} ${b['id']}'.compareTo(
            '${a['date']} ${a['time_slot']} ${a['id']}',
          ),
        );
  page([
    title('Ultime cinque partite'),
    txt('Punteggi dal punto di vista della coppia del giocatore.', 9, muted),
    pw.SizedBox(height: 12),
    if (matches.isEmpty) panel([txt('Nessun risultato disponibile.')]),
    for (final m in matches.take(5)) ...[
      () {
        final pos = (m['position'] as num?)?.toInt() ?? 0;
        final own = pos < 2 ? 'A' : 'B';
        final won =
            m['result_outcome'] != 'time_expired' &&
            m['winner_team'] == (own == 'A' ? 'team1' : 'team2');
        final players = (m['players'] as List? ?? [])
            .map(_map)
            .where((p) => p['position'] != pos);
        String team(Map p) =>
            p['team']?.toString() ??
            ((p['position'] as num).toInt() < 2 ? 'A' : 'B');
        var score = '${m['score_team1'] ?? '-'}';
        if (own == 'B') {
          score = score.replaceAllMapped(
            RegExp(r'(\d+)\s*-\s*(\d+)'),
            (v) => '${v[2]}-${v[1]}',
          );
        }
        return panel([
          pw.Row(
            children: [
              txt(
                '${_date(m['date'])}  ${m['time_slot'] ?? ''}',
                10,
                navy,
                true,
              ),
              pw.Spacer(),
              txt(won ? 'Vittoria' : 'Sconfitta', 10, won ? green : red, true),
            ],
          ),
          pw.SizedBox(height: 8),
          txt(score, 12, navy, true),
          pw.SizedBox(height: 10),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    txt('IN COPPIA CON', 8, muted),
                    for (final p in players.where((p) => team(p) == own))
                      txt(p['name'] ?? 'Non registrato', 10, navy, true),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    txt('AVVERSARI', 8, muted),
                    for (final p in players.where((p) => team(p) != own))
                      txt(p['name'] ?? 'Non registrato', 10, navy, true),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          txt(
            '${m['court_name'] ?? 'Campo non indicato'}${m['statistics_only'] == true ? ' / Solo statistiche' : ''}',
            8,
            muted,
          ),
        ]);
      }(),
    ],
  ]);
  return doc.save();
}
