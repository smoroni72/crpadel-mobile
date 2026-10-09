import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/info_card.dart';
import '../../domain/padel_match.dart';
import '../match_labels.dart';

/// Card di una partita in "Partite del giorno".
class MatchCard extends StatelessWidget {
  const MatchCard({
    super.key,
    required this.match,
    required this.myUserId,
    this.onJoin,
    this.onTap,
  });

  final PadelMatch match;
  final String myUserId;

  /// Mostra "Partecipa" sulle partite aperte altrui con posto libero.
  final VoidCallback? onJoin;

  /// Apre il dettaglio.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final mine = match.involves(myUserId);
    final open = match.hasFreeSpots;
    final completed = match.status == MatchStatus.completed;

    final (boxColor, timeColor) = mine
        ? (colors.navy, colors.onNavy)
        : open
        ? (
            Color.alphaBlend(
              colors.matchOpen.withValues(alpha: 0.12),
              colors.surface,
            ),
            colors.matchOpen,
          )
        : (colors.divider, colors.textSecondary);

    final title =
        '${match.courtName} · ${completed ? 'conclusa' : match.matchType.label}';
    final subtitle = completed && match.teamsLabel.isNotEmpty
        ? match.teamsLabel
        : [if (mine) 'Tua', match.statusLabel].join(' · ');

    Widget? trailing;
    if (completed && (match.scoreTeam1?.isNotEmpty ?? false)) {
      trailing = Text(
        match.scoreTeam1!,
        style: context.fonts.monoStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      );
    } else if (open && !mine && onJoin != null) {
      trailing = SizedBox(
        height: 44,
        child: ElevatedButton(
          onPressed: onJoin,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(0, 40),
            padding: const EdgeInsets.symmetric(horizontal: 14),
          ),
          child: const Text('Partecipa'),
        ),
      );
    }

    return InfoCard(
      onTap: onTap,
      leading: LeadingBox(
        background: boxColor,
        child: Text(
          match.slot?.startLabel ?? '--:--',
          style: context.fonts
              .monoStyle(fontSize: 14, fontWeight: FontWeight.w600)
              .copyWith(color: timeColor),
        ),
      ),
      title: title,
      subtitle: subtitle,
      subtitleColor: open && !completed ? colors.matchOpen : null,
      trailing: trailing,
    );
  }
}
