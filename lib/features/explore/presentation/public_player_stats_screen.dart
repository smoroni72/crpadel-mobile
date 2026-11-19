import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/colors.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../profile/domain/profile_models.dart';
import '../../profile/presentation/widgets/player_avatar.dart';
import 'explore_providers.dart';

class PublicPlayerStatsScreen extends ConsumerStatefulWidget {
  const PublicPlayerStatsScreen({super.key, required this.player});
  final PlayerRanking player;

  @override
  ConsumerState<PublicPlayerStatsScreen> createState() =>
      _PublicPlayerStatsScreenState();
}

class _PublicPlayerStatsScreenState
    extends ConsumerState<PublicPlayerStatsScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(publicPlayerStatsProvider(widget.player));
    }
  }

  @override
  Widget build(BuildContext context) {
    final player = widget.player;
    final showRankingDetails =
        ref.watch(authControllerProvider).value?.isAdmin ?? false;
    return Scaffold(
      appBar: AppBar(title: const Text('Statistiche giocatore')),
      body: AsyncValueView(
        value: ref.watch(publicPlayerStatsProvider(player)),
        errorText: 'Non riesco a caricare le statistiche del giocatore',
        onRetry: () => ref.invalidate(publicPlayerStatsProvider(player)),
        data: (stats) => RefreshIndicator(
          onRefresh: () =>
              ref.refresh(publicPlayerStatsProvider(player).future),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
            children: [
              _PlayerHero(player: player, stats: stats),
              const SizedBox(height: 16),
              _Section(
                icon: Icons.insights_rounded,
                title: 'Rendimento',
                subtitle:
                    'Dati sulle ${stats.matchesPlayed} partite registrate nel sistema',
                child: _MetricsGrid(
                  children: [
                    _Metric(
                      icon: Icons.sports_tennis_rounded,
                      label: 'Partite',
                      value: '${stats.matchesPlayed}',
                    ),
                    _Metric(
                      icon: Icons.emoji_events_outlined,
                      label: 'Vittorie',
                      value: '${stats.matchesWon}',
                      color: const Color(0xff16a34a),
                    ),
                    _Metric(
                      icon: Icons.close_rounded,
                      label: 'Sconfitte',
                      value: '${stats.matchesLost}',
                      color: const Color(0xffef4444),
                    ),
                    _Metric(
                      icon: Icons.trending_up_rounded,
                      label: 'Win rate',
                      value: '${stats.winRate}%',
                    ),
                    if (stats.undecided > 0) ...[
                      _Metric(
                        icon: Icons.timelapse_rounded,
                        label: 'Non terminate',
                        value: '${stats.undecided}',
                      ),
                      _Metric(
                        icon: Icons.check_circle_outline,
                        label: 'Con esito',
                        value: '${stats.decidedMatches}',
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _Section(
                icon: Icons.show_chart_rounded,
                title: stats.recentHistory.isEmpty
                    ? 'Andamento recente'
                    : 'Andamento ultime ${stats.recentHistory.length}',
                subtitle: 'Progressivo di vittorie e sconfitte',
                child: stats.recentHistory.isEmpty
                    ? const _EmptyState(label: 'Nessun risultato disponibile')
                    : _TrendChart(matches: stats.recentHistory),
              ),
              if (_hasHighlights(stats)) ...[
                const SizedBox(height: 16),
                _Section(
                  icon: Icons.auto_awesome_rounded,
                  title: 'Identità sportiva',
                  subtitle: 'Serie, intese e sfide della stagione',
                  child: _PlayerHighlights(stats: stats),
                ),
              ],
              const SizedBox(height: 16),
              _Section(
                icon: Icons.speed_rounded,
                title: 'Forma e gioco',
                child: Column(
                  children: [
                    _ProgressMetric(
                      label: 'Forma recente',
                      value: stats.recentFormRate,
                      detail: '${stats.recentWins} V su ${stats.recentMatches}',
                      color: const Color(0xff16a34a),
                    ),
                    const SizedBox(height: 16),
                    _ProgressMetric(
                      label: 'Set vinti',
                      value: stats.setWinRate,
                      detail:
                          '${stats.setsWon} vinti · ${stats.setsLost} persi',
                    ),
                    const SizedBox(height: 16),
                    _ProgressMetric(
                      label: 'Tie-break',
                      value: stats.tiebreaksPlayed == 0
                          ? 0
                          : (stats.tiebreaksWon * 100 / stats.tiebreaksPlayed)
                                .round(),
                      detail:
                          '${stats.tiebreaksPlayed} giocati · ${stats.tiebreaksWon} vinti',
                    ),
                    const SizedBox(height: 16),
                    _ProgressMetric(
                      label: 'Game vinti',
                      value: stats.gameWinRate,
                      detail:
                          '${stats.gamesWon} vinti · ${stats.gamesLost} persi',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _Section(
                icon: Icons.workspace_premium_outlined,
                title: 'Analisi ranking',
                child: _MetricsGrid(
                  ratio: 1.3,
                  children: [
                    _Metric(
                      icon: Icons.arrow_downward_rounded,
                      label: 'Da sfavorito',
                      value: '${stats.underdogMatches}',
                      detail: '${stats.underdogWins} vittorie',
                    ),
                    _Metric(
                      icon: Icons.arrow_upward_rounded,
                      label: 'Da favorito',
                      value: '${stats.favoriteMatches}',
                      detail: '${stats.favoriteWins} vittorie',
                    ),
                    if (showRankingDetails) ...[
                      _Metric(
                        icon: Icons.add_chart_rounded,
                        label: stats.recentHistory.isEmpty
                            ? 'Punti classifica recenti'
                            : 'Punti classifica ultime ${stats.recentHistory.length}',
                        value: _signed(stats.rankingScoreEarned),
                        color: stats.rankingScoreEarned >= 0
                            ? const Color(0xff16a34a)
                            : const Color(0xffef4444),
                      ),
                      _Metric(
                        icon: Icons.functions_rounded,
                        label: stats.recentHistory.isEmpty
                            ? 'Media classifica recente'
                            : 'Media classifica ultime ${stats.recentHistory.length}',
                        value: _signed(stats.rankingScoreAverage),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _Section(
                icon: Icons.history_rounded,
                title: stats.recentHistory.isEmpty
                    ? 'Partite recenti'
                    : 'Ultime ${stats.recentHistory.length} partite',
                subtitle: showRankingDetails
                    ? 'Avversari, risultato e punti classifica'
                    : 'Avversari e risultato',
                child: stats.recentHistory.isEmpty
                    ? const _EmptyState(label: 'Nessuna partita disponibile')
                    : Column(
                        children: [
                          for (
                            var i = 0;
                            i < stats.recentHistory.length;
                            i++
                          ) ...[
                            _RecentMatchCard(
                              match: stats.recentHistory[i],
                              playerName: player.playerName,
                              showRankingDetails: showRankingDetails,
                            ),
                            if (i < stats.recentHistory.length - 1)
                              const SizedBox(height: 10),
                          ],
                        ],
                      ),
              ),
              const SizedBox(height: 16),
              Text(
                'Sono mostrate esclusivamente statistiche sportive. Dati personali, pagamenti e informazioni amministrative restano privati.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _signed(double value) =>
    '${value > 0 ? '+' : ''}${value.toStringAsFixed(2).replaceAll('.', ',')}';

bool _hasHighlights(ProfileStats stats) =>
    stats.currentStreakCount > 0 ||
    stats.bestPartner != null ||
    stats.mostFacedOpponent != null ||
    stats.badges.isNotEmpty;

class _PlayerHighlights extends StatelessWidget {
  const _PlayerHighlights({required this.stats});
  final ProfileStats stats;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (stats.badges.isNotEmpty) ...[
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final badge in stats.badges)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xfff59e0b).withValues(alpha: .13),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: const Color(0xfff59e0b).withValues(alpha: .5),
                  ),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Color(0xffd97706),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
      ],
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          if (stats.currentStreakCount > 0)
            _HighlightCard(
              icon: stats.currentStreakType == 'win'
                  ? Icons.local_fire_department_rounded
                  : Icons.refresh_rounded,
              title: 'Serie attuale',
              value:
                  '${stats.currentStreakCount} ${stats.currentStreakType == 'win' ? 'vittorie' : 'sconfitte'}',
              detail: stats.currentStreakType == 'win'
                  ? 'Momento positivo'
                  : 'Pronto a ripartire',
            ),
          if (stats.bestPartner != null)
            _HighlightCard(
              icon: Icons.handshake_outlined,
              title: 'Miglior compagno',
              value: stats.bestPartner!.name,
              detail:
                  '${stats.bestPartner!.matches} partite · ${stats.bestPartner!.winRate.toStringAsFixed(0)}% vittorie',
            ),
          if (stats.mostFacedOpponent != null)
            _HighlightCard(
              icon: Icons.sports_martial_arts_outlined,
              title: 'Avversario più affrontato',
              value: stats.mostFacedOpponent!.name,
              detail:
                  '${stats.mostFacedOpponent!.matches} sfide · ${stats.mostFacedOpponent!.wins} V / ${stats.mostFacedOpponent!.losses} S',
            ),
        ],
      ),
    ],
  );
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.detail,
  });
  final IconData icon;
  final String title;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) => Container(
    width: 240,
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: context.colors.background,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: context.colors.border),
    ),
    child: Row(
      children: [
        Icon(icon, color: context.colors.primaryText, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              Text(
                detail,
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _PlayerHero extends StatelessWidget {
  const _PlayerHero({required this.player, required this.stats});
  final PlayerRanking player;
  final ProfileStats stats;

  @override
  Widget build(BuildContext context) {
    final band = parseHexColor(stats.bandColor) ?? context.colors.primary;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: band.withValues(alpha: .55)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            band.withValues(alpha: .27),
            context.colors.surface,
            context.colors.surface,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: band.withValues(alpha: .12),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: band, width: 3),
                ),
                child: PlayerAvatar(
                  name: player.playerName,
                  photoUrl: player.playerPhotoUrl,
                  size: 76,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.playerName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: band.withValues(alpha: .18),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(color: band.withValues(alpha: .55)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: band,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            'Fascia ${stats.bandName ?? 'non assegnata'}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _HeroValue(
                label: 'POSIZIONE',
                value: stats.position == null ? '—' : '${stats.position}ª',
              ),
              _HeroDivider(color: band),
              _HeroValue(
                label: 'PUNTI',
                value: player.eloScore.toStringAsFixed(2),
              ),
              _HeroDivider(color: band),
              _HeroValue(label: 'WIN RATE', value: '${stats.winRate}%'),
            ],
          ),
          if (stats.recentHistory.isNotEmpty) ...[
            const SizedBox(height: 18),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FORMA RECENTE · ULTIME ${stats.recentHistory.length}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 9),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final match in stats.recentHistory)
                      _FormDot(result: match.won ? 'V' : 'S'),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _HeroValue extends StatelessWidget {
  const _HeroValue({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          value,
          style: context.fonts.monoStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: context.colors.textSecondary,
          ),
        ),
      ],
    ),
  );
}

class _HeroDivider extends StatelessWidget {
  const _HeroDivider({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 38, color: color.withValues(alpha: .35));
}

class _FormDot extends StatelessWidget {
  const _FormDot({required this.result});
  final String result;
  @override
  Widget build(BuildContext context) {
    final won = result.toUpperCase() == 'V';
    final color = won ? const Color(0xff16a34a) : const Color(0xffef4444);
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: .15),
        border: Border.all(color: color.withValues(alpha: .7)),
      ),
      child: Text(
        won ? 'V' : 'S',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.child,
    this.subtitle,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: context.colors.border),
      color: context.colors.surface,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .035),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: context.colors.primaryText, size: 21),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 11,
                          color: context.colors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    ),
  );
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.children, this.ratio = 1.45});
  final List<Widget> children;
  final double ratio;
  @override
  Widget build(BuildContext context) => GridView.count(
    crossAxisCount: 2,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    childAspectRatio: ratio,
    mainAxisSpacing: 10,
    crossAxisSpacing: 10,
    children: children,
  );
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.label,
    required this.value,
    this.detail,
    this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final String? detail;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final accent = color ?? context.colors.primaryText;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: .24)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: accent),
              const Spacer(),
              Container(
                width: 24,
                height: 3,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: .65),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: context.fonts
                .monoStyle(fontSize: 20, fontWeight: FontWeight.w900)
                .copyWith(color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: context.colors.textSecondary),
          ),
          if (detail != null)
            Text(
              detail!,
              style: TextStyle(
                fontSize: 10,
                color: context.colors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

class _ProgressMetric extends StatelessWidget {
  const _ProgressMetric({
    required this.label,
    required this.value,
    required this.detail,
    this.color,
  });
  final String label;
  final int value;
  final String detail;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final accent = color ?? context.colors.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            Text(
              '$value%',
              style: context.fonts.monoStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: value.clamp(0, 100) / 100,
            color: accent,
            backgroundColor: accent.withValues(alpha: .14),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          detail,
          style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
        ),
      ],
    );
  }
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.matches});
  final List<RecentPlayerMatch> matches;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      SizedBox(
        height: 180,
        width: double.infinity,
        child: CustomPaint(
          painter: _TrendPainter(
            matches: matches.reversed.toList(),
            gridColor: context.colors.divider,
            textColor: context.colors.textSecondary,
          ),
        ),
      ),
      const SizedBox(height: 8),
      const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _LegendDot(color: Color(0xff16a34a), label: 'Vittorie'),
          SizedBox(width: 18),
          _LegendDot(color: Color(0xffef4444), label: 'Sconfitte'),
        ],
      ),
    ],
  );
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 11)),
    ],
  );
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({
    required this.matches,
    required this.gridColor,
    required this.textColor,
  });
  final List<RecentPlayerMatch> matches;
  final Color gridColor;
  final Color textColor;

  @override
  void paint(Canvas canvas, Size size) {
    final chart = Rect.fromLTRB(26, 12, size.width - 10, size.height - 28);
    final maxValue = math.max(matches.length, 1).toDouble();
    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var row = 0; row <= matches.length; row++) {
      final y = chart.bottom - chart.height * row / maxValue;
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), grid);
    }
    final wins = <Offset>[];
    final losses = <Offset>[];
    var win = 0;
    var loss = 0;
    for (var i = 0; i < matches.length; i++) {
      matches[i].won ? win++ : loss++;
      final x = matches.length == 1
          ? chart.center.dx
          : chart.left + chart.width * i / (matches.length - 1);
      wins.add(Offset(x, chart.bottom - chart.height * win / maxValue));
      losses.add(Offset(x, chart.bottom - chart.height * loss / maxValue));
      final label = _shortDate(matches[i].date);
      final text = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(fontSize: 9, color: textColor),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(canvas, Offset(x - text.width / 2, chart.bottom + 8));
    }
    _drawLine(canvas, wins, const Color(0xff16a34a));
    _drawLine(canvas, losses, const Color(0xffef4444));
  }

  void _drawLine(Canvas canvas, List<Offset> points, Color color) {
    if (points.isEmpty) return;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    for (final point in points) {
      canvas.drawCircle(point, 4, Paint()..color = color);
      canvas.drawCircle(point, 2, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) =>
      oldDelegate.matches != matches ||
      oldDelegate.gridColor != gridColor ||
      oldDelegate.textColor != textColor;
}

class _RecentMatchCard extends StatelessWidget {
  const _RecentMatchCard({
    required this.match,
    required this.playerName,
    required this.showRankingDetails,
  });
  final RecentPlayerMatch match;
  final String playerName;
  final bool showRankingDetails;
  @override
  Widget build(BuildContext context) {
    final color = match.won ? const Color(0xff16a34a) : const Color(0xffef4444);
    final opponents = match.opponents.isEmpty
        ? const ['Avversari non indicati']
        : match.opponents;
    final team = <String>[
      playerName,
      ...match.teamMates.where((name) => name.trim().isNotEmpty),
    ];
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: .3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 11),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .09),
              border: Border(
                bottom: BorderSide(color: color.withValues(alpha: .2)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: .16),
                    border: Border.all(color: color.withValues(alpha: .45)),
                  ),
                  child: Text(
                    match.won ? 'V' : 'S',
                    style: TextStyle(color: color, fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_longDate(match.date)}${match.timeSlot.isEmpty ? '' : ' · ${match.timeSlot}'}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        match.courtName.isEmpty
                            ? 'Campo non indicato'
                            : match.courtName,
                        style: TextStyle(
                          fontSize: 11,
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _OutcomeBadge(label: match.resultLabel, color: color),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 15),
            child: Column(
              children: [
                _TeamPanel(
                  label: 'LA SUA COPPIA',
                  names: team,
                  accent: color,
                  highlighted: match.won,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Row(
                    children: [
                      Expanded(child: Divider(color: context.colors.divider)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'VS',
                          style: TextStyle(
                            color: context.colors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: context.colors.divider)),
                    ],
                  ),
                ),
                _TeamPanel(
                  label: 'AVVERSARI',
                  names: opponents,
                  accent: const Color(0xff16a34a),
                  highlighted: !match.won && match.resultLabel == 'Sconfitta',
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .09),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: color.withValues(alpha: .25)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'RISULTATO · SUA COPPIA PRIMA',
                        style: TextStyle(
                          fontSize: 9,
                          color: context.colors.textSecondary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        match.score.isEmpty ? '—' : match.score,
                        textAlign: TextAlign.center,
                        style: context.fonts.monoStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (showRankingDetails &&
                          match.rankingScoreDelta != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${_signed(match.rankingScoreDelta!)} classifica',
                          style: TextStyle(
                            fontSize: 10,
                            color: match.rankingScoreDelta! >= 0
                                ? const Color(0xff16a34a)
                                : const Color(0xffef4444),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OutcomeBadge extends StatelessWidget {
  const _OutcomeBadge({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .13),
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: color.withValues(alpha: .3)),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w900),
    ),
  );
}

class _TeamPanel extends StatelessWidget {
  const _TeamPanel({
    required this.label,
    required this.names,
    required this.accent,
    this.highlighted = false,
  });
  final String label;
  final List<String> names;
  final Color accent;
  final bool highlighted;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(13, 11, 13, 12),
    decoration: BoxDecoration(
      color: highlighted
          ? accent.withValues(alpha: .07)
          : context.colors.background,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: highlighted
            ? accent.withValues(alpha: .28)
            : context.colors.border,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
            color: highlighted ? accent : context.colors.textSecondary,
          ),
        ),
        const SizedBox(height: 7),
        for (var index = 0; index < names.length; index++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  color: highlighted
                      ? accent
                      : context.colors.textSecondary.withValues(alpha: .55),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  names[index],
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.25,
                    fontWeight: highlighted && index == 0
                        ? FontWeight.w900
                        : FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (index < names.length - 1) const SizedBox(height: 5),
        ],
      ],
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 28),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: context.colors.background,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: context.colors.border),
    ),
    child: Text(label, style: TextStyle(color: context.colors.textSecondary)),
  );
}

String _shortDate(String value) {
  final date = DateTime.tryParse(value);
  return date == null ? value : intl.DateFormat('dd/MM').format(date);
}

String _longDate(String value) {
  final date = DateTime.tryParse(value);
  return date == null ? value : intl.DateFormat('dd MMM', 'it_IT').format(date);
}
