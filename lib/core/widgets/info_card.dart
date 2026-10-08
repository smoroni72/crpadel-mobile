import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Card delle liste in Home: riquadro a sinistra, titolo e sottotitolo,
/// elemento facoltativo a destra.
class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.subtitleColor,
    this.trailing,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final Color? subtitleColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 13,
                        color: subtitleColor ?? colors.textSecondary,
                        fontWeight: subtitleColor == null
                            ? FontWeight.w400
                            : FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 10), trailing!],
          ],
        ),
      ),
    );
  }
}

/// Riquadro 48×52 a sinistra delle card (data o orario).
class LeadingBox extends StatelessWidget {
  const LeadingBox({super.key, required this.background, required this.child});

  final Color background;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: 48,
    height: 52,
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(AppTheme.controlRadius),
    ),
    alignment: Alignment.center,
    child: child,
  );
}
