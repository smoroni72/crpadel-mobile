import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../domain/performance_details.dart';

/// The same visual hierarchy as the web card, with native PDF assets.
pw.Page playerCardCover(
  Map<String, dynamic> data, {
  required pw.ThemeData theme,
  required pw.Font heading,
  required pw.Font mono,
  required pw.Widget Function(pw.Context) footer,
  Uint8List? logo,
  Uint8List? photo,
  Uint8List? animal,
}) {
  Map<String, dynamic> map(dynamic v) =>
      v is Map ? Map<String, dynamic>.from(v) : {};
  num n(dynamic v) => v is num ? v : num.tryParse('$v') ?? 0;
  String number(dynamic v, [int digits = 0]) => v == null
      ? '-'
      : NumberFormat(
          digits == 0 ? '0' : '0.${'0' * digits}',
          'it_IT',
        ).format(n(v));
  String date(dynamic v) {
    final d = DateTime.tryParse('$v');
    return d == null ? 'Non indicata' : DateFormat('dd/MM/yyyy').format(d);
  }

  final card = map(data['card']);
  final p = map(card['player']);
  final r = map(card['ranking']);
  final t = map(data['period'] ?? data['totals']);
  final h = map(data['highlights']);
  final name = '${p['name']}';
  final navy = PdfColor.fromHex('#111d32'),
      muted = PdfColor.fromHex('#6b778b'),
      green = PdfColor.fromHex('#239b65'),
      red = PdfColor.fromHex('#cd302c'),
      cream = PdfColor.fromHex('#fff7e4');
  final bg = PdfColor.fromHex('#f5f6f9'), line = PdfColor.fromHex('#e2e5ec');
  final band = RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch('${r['band_color']}')
      ? PdfColor.fromHex(r['band_color'] as String)
      : line;
  final bandInk = band.red * .299 + band.green * .587 + band.blue * .114 > .55
      ? navy
      : PdfColors.white;
  final expired = countTimeExpired(data['matches'] as List? ?? []);
  final undecided = n(t['undecided'] ?? t['unfinished_matches']);
  final decided = n(t['wins']) + n(t['losses']);
  final rate = decided > 0 ? n(t['wins']) / decided : 0.0;
  final completed =
      (data['matches'] as List? ?? [])
          .map(map)
          .where((m) => m['status'] == 'completed')
          .toList()
        ..sort(
          (a, b) => '${b['date']} ${b['time_slot']} ${b['id']}'.compareTo(
            '${a['date']} ${a['time_slot']} ${a['id']}',
          ),
        );
  bool eligible(Map m) =>
      m['result_outcome'] != 'unfinished' &&
      (m['winner_team'] != null || m['result_outcome'] == 'time_expired');
  bool won(Map m) =>
      m['result_outcome'] != 'time_expired' &&
      m['winner_team'] ==
          ((m['position'] as num? ?? 0) < 2 ? 'team1' : 'team2');
  final recent = completed.where(eligible).take(5).toList().reversed.toList();
  var best = 0;
  var streak = 0;
  for (final m in completed.where(eligible).toList().reversed) {
    streak = won(m) ? streak + 1 : 0;
    if (streak > best) best = streak;
  }
  final current = map(h['current_streak']);
  final currentCount = n(current['count']).toInt();
  final streakLabel = current['type'] == 'win'
      ? (currentCount == 1 ? 'vittoria consecutiva' : 'vittorie consecutive')
      : (currentCount == 1 ? 'sconfitta consecutiva' : 'sconfitte consecutive');
  final challenge = t['challenge_index'] is num
      ? (t['challenge_index'] as num).toDouble()
      : null;
  const descriptions = {
    'Leone': 'Sfide prevalentemente alla pari o da sfavorito',
    'Tigre': 'Vantaggio medio molto contenuto',
    'Lupo': 'Vantaggio medio contenuto',
    'Volpe': 'Vantaggio medio moderato',
    'Gatto': 'Vantaggio medio più marcato',
    'Coniglio': 'Vantaggio medio elevato',
  };
  pw.Widget text(
    dynamic v,
    double size, {
    PdfColor? color,
    pw.Font? font,
    bool bold = false,
  }) => pw.Text(
    '$v',
    style: pw.TextStyle(
      fontSize: size,
      color: color ?? navy,
      font: font,
      fontWeight: bold ? pw.FontWeight.bold : null,
    ),
  );
  pw.Widget at(
    double x,
    double y,
    double width,
    double height,
    pw.Widget child,
  ) => pw.Positioned(
    left: x,
    top: y,
    child: pw.SizedBox(width: width, height: height, child: child),
  );
  pw.Widget fitted(
    dynamic v,
    double size, {
    PdfColor? color,
    pw.Font? font,
    bool bold = false,
  }) => pw.FittedBox(
    fit: pw.BoxFit.scaleDown,
    alignment: pw.Alignment.centerLeft,
    child: text(v, size, color: color, font: font, bold: bold),
  );
  pw.Widget box(
    double x,
    double y,
    double width,
    double height, {
    PdfColor? color,
    PdfColor? border,
  }) => at(
    x,
    y,
    width,
    height,
    pw.Container(
      decoration: pw.BoxDecoration(
        color: color ?? PdfColors.white,
        border: pw.Border.all(color: border ?? line),
        borderRadius: pw.BorderRadius.circular(14),
      ),
    ),
  );
  return pw.Page(
    pageFormat: PdfPageFormat.a4,
    margin: pw.EdgeInsets.zero,
    theme: theme,
    build: (context) => pw.Stack(
      children: [
        at(0, 0, 595.28, 841.89, pw.Container(color: bg)),
        at(0, 0, 595.28, 208, pw.Container(color: navy)),
        if (logo != null)
          at(
            32,
            24,
            27,
            38,
            pw.Image(pw.MemoryImage(logo), fit: pw.BoxFit.contain),
          ),
        at(
          70,
          25,
          300,
          21,
          fitted(
            '${map(card['club'])['name'] ?? 'CRPADEL'}'.toUpperCase(),
            14,
            color: PdfColors.white,
            font: heading,
          ),
        ),
        at(
          70,
          47,
          320,
          12,
          text(
            "CARTA D'IDENTITÀ SPORTIVA",
            7.5,
            color: PdfColor.fromHex('#bcc7d9'),
          ),
        ),
        at(
          470,
          27,
          93,
          14,
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: text(
              date(card['as_of']),
              8,
              color: PdfColor.fromHex('#ffd46a'),
              bold: true,
            ),
          ),
        ),
        at(
          32,
          82,
          391,
          67,
          pw.FittedBox(
            fit: pw.BoxFit.scaleDown,
            alignment: pw.Alignment.topLeft,
            child: pw.SizedBox(
              width: 391,
              child: text(
                name.toUpperCase(),
                30,
                color: PdfColors.white,
                font: heading,
              ),
            ),
          ),
        ),
        at(
          32,
          158,
          365,
          26,
          pw.Align(
            alignment: pw.Alignment.centerLeft,
            child: pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: pw.BoxDecoration(
                color: band,
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: text(
                r['band_name'] == null
                    ? 'FASCIA NON ASSEGNATA'
                    : 'FASCIA ${r['band_name']}'.toUpperCase(),
                8.3,
                color: bandInk,
                bold: true,
              ),
            ),
          ),
        ),
        at(
          454,
          82,
          96,
          96,
          pw.Container(
            decoration: pw.BoxDecoration(
              color: cream,
              shape: pw.BoxShape.circle,
              border: pw.Border.all(color: band, width: 2.4),
            ),
            child: pw.ClipOval(
              child: photo != null
                  ? pw.Image(pw.MemoryImage(photo), fit: pw.BoxFit.cover)
                  : pw.Center(
                      child: text(
                        name
                            .trim()
                            .split(RegExp(r'\s+'))
                            .take(2)
                            .map((s) => s.isEmpty ? '' : s[0])
                            .join()
                            .toUpperCase(),
                        30,
                        color: navy,
                        font: heading,
                      ),
                    ),
            ),
          ),
        ),
        at(
          439,
          188,
          124,
          12,
          pw.Center(
            child: text(
              photo == null ? 'Foto non disponibile' : 'Foto profilo',
              7,
              color: PdfColor.fromHex('#ccd5e3'),
            ),
          ),
        ),
        box(32, 224, 531.28, 78),
        for (final (i, item) in [
          (
            r['position'] == null ? 'Fuori classifica' : '${r['position']}°',
            'POSIZIONE',
          ),
          (r.isEmpty ? '-' : number(r['points'], 2), 'PUNTI CLASSIFICA'),
          (r.isEmpty ? '-' : number(r['coefficient'], 2), 'COEFFICIENTE'),
        ].indexed) ...[
          at(50 + i * 177, 240, 158, 30, fitted(item.$1, 23, font: mono)),
          at(
            50 + i * 177,
            276,
            158,
            13,
            text(item.$2, 7.2, color: muted, bold: true),
          ),
        ],
        for (final (i, item) in [
          (
            'NASCITA DA VERIFICARE',
            p['personal_data_visible'] == true
                ? date(p['birth_date'])
                : 'Non pubblicata',
          ),
          ('ETÀ', 'Non calcolata'),
          (
            'SESSO',
            p['personal_data_visible'] == true
                ? ({
                        'male': 'Maschile',
                        'female': 'Femminile',
                        'other': 'Altro',
                      }[p['gender']] ??
                      'Non indicato')
                : 'Non pubblicato',
          ),
          (
            'LATO DI GIOCO',
            {'DX': 'Destra', 'SX': 'Sinistra'}[p['preferred_side']] ??
                'Non indicato',
          ),
        ].indexed) ...[
          at(
            32 + i * 132.8,
            316,
            128,
            12,
            text(item.$1, 6.5, color: muted, bold: true),
          ),
          at(32 + i * 132.8, 336, 128, 16, fitted(item.$2, 9, bold: true)),
        ],
        at(
          32,
          358,
          531,
          15,
          text(
            'Dati anagrafici da confermare. Livello registrato: ${r['level'] ?? 'non indicato'}',
            7.2,
            color: muted,
          ),
        ),
        box(32, 383, 531.28, 119),
        at(48, 397, 320, 15, text('IL BILANCIO', 8, color: muted, bold: true)),
        for (final (i, item) in [
          (n(t['matches_played']), 'Partite', navy),
          (n(t['wins']), 'Vittorie', green),
          (n(t['losses']), 'Sconfitte', red),
          (undecided + expired, 'Non concluse', muted),
        ].indexed) ...[
          at(
            48 + i * 85.75,
            425,
            80,
            30,
            fitted(number(item.$1), 24, color: item.$3, font: mono),
          ),
          at(48 + i * 85.75, 458, 82, 14, text(item.$2, 7.4, color: muted)),
        ],
        at(
          48,
          480,
          343,
          17,
          pw.FittedBox(
            fit: pw.BoxFit.scaleDown,
            alignment: pw.Alignment.centerLeft,
            child: text(
              '${number(t['ranking_matches'])} Ranking / ${number(t['friendly_matches'])} amichevoli / ${number(t['tournament_matches'])} tornei. Non concluse: $undecided senza esito / $expired tempo scaduto.',
              7.1,
              color: muted,
            ),
          ),
        ),
        at(
          463,
          406,
          70,
          70,
          pw.Stack(
            children: [
              pw.Positioned.fill(
                child: pw.CircularProgressIndicator(
                  value: rate,
                  color: green,
                  backgroundColor: PdfColor.fromHex('#e6ebe9'),
                  strokeWidth: 6,
                ),
              ),
              pw.Positioned.fill(
                child: pw.Center(
                  child: text(
                    decided == 0 ? '-' : '${number(rate * 100)}%',
                    17,
                    font: mono,
                  ),
                ),
              ),
            ],
          ),
        ),
        at(
          423,
          484,
          140,
          13,
          pw.Center(
            child: text(
              '${number(t['wins'])} vittorie su $decided con esito',
              6.8,
              color: muted,
            ),
          ),
        ),
        box(
          32,
          518,
          531.28,
          137,
          color: cream,
          border: PdfColor.fromHex('#f6dc9c'),
        ),
        if (animal != null)
          at(
            41,
            536,
            104,
            104,
            pw.Image(pw.MemoryImage(animal), fit: pw.BoxFit.contain),
          ),
        at(
          158,
          535,
          360,
          14,
          text(
            'INDICE DI SFIDA',
            7.6,
            color: PdfColor.fromHex('#8e690b'),
            bold: true,
          ),
        ),
        at(
          158,
          551,
          175,
          29,
          fitted(
            challenge == null
                ? 'Da definire'
                : (t['challenge_animal'] ?? 'Da definire'),
            22,
            font: heading,
          ),
        ),
        at(
          341,
          552,
          205,
          29,
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: text(
              challenge == null ? '-' : '${number(challenge, 2)}/100',
              23,
              font: mono,
            ),
          ),
        ),
        at(
          158,
          584,
          388,
          15,
          fitted(
            challenge == null
                ? 'Nessuna partita con coefficienti documentati'
                : descriptions[t['challenge_animal']] ?? '',
            8.3,
            bold: true,
          ),
        ),
        at(
          158,
          603,
          386,
          5,
          pw.Container(
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#f0e2bd'),
              borderRadius: pw.BorderRadius.circular(2),
            ),
          ),
        ),
        if (challenge != null && challenge > 0)
          at(
            158,
            603,
            386 * challenge.clamp(0, 100) / 100,
            5,
            pw.Container(color: PdfColor.fromHex('#f2a807')),
          ),
        at(
          158,
          619,
          386,
          29,
          pw.FittedBox(
            fit: pw.BoxFit.scaleDown,
            alignment: pw.Alignment.topLeft,
            child: pw.SizedBox(
              width: 386,
              child: text(
                challenge == null
                    ? 'Media coefficiente di difficoltà non disponibile.'
                    : 'Media coefficiente di difficoltà calcolata su ${number(t['challenge_matches'])} ${t['challenge_matches'] == 1 ? 'partita' : 'partite'}.',
                7.3,
              ),
            ),
          ),
        ),
        box(32, 671, 531.28, 104),
        at(
          48,
          686,
          300,
          15,
          text('FORMA RECENTE', 8, color: muted, bold: true),
        ),
        for (final (i, m) in recent.indexed)
          at(
            49 + i * 36,
            709,
            24,
            24,
            pw.Container(
              alignment: pw.Alignment.center,
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex(won(m) ? '#e8f5ee' : '#faedec'),
                shape: pw.BoxShape.circle,
                border: pw.Border.all(color: won(m) ? green : red, width: .6),
              ),
              child: text(
                won(m) ? 'V' : 'S',
                10,
                color: won(m) ? green : red,
                bold: true,
              ),
            ),
          ),
        at(
          48,
          747,
          210,
          15,
          text(
            recent.isEmpty
                ? 'Nessun risultato disponibile'
                : 'Dalla meno recente alla più recente',
            6.6,
            color: muted,
          ),
        ),
        at(
          260,
          706,
          287,
          20,
          fitted(
            currentCount == 0
                ? 'Nessuna serie disponibile'
                : '$currentCount $streakLabel',
            10,
            bold: true,
          ),
        ),
        at(
          260,
          731,
          287,
          15,
          text('Serie migliore registrata: $best vittorie', 8.2, color: muted),
        ),
        at(
          260,
          750,
          287,
          14,
          text(
            'Prima partita: ${completed.isEmpty ? 'Non indicata' : date(completed.last['date'])}',
            7,
            color: muted,
          ),
        ),
        at(
          32,
          779,
          531,
          11,
          fitted(
            (h['badges'] as List? ?? []).isEmpty
                ? 'Statistiche calcolate sui risultati registrati.'
                : 'Riconoscimenti: ${(h['badges'] as List).join(' / ')}',
            6.8,
            color: muted,
          ),
        ),
        at(32, 798, 531, 30, footer(context)),
      ],
    ),
  );
}
