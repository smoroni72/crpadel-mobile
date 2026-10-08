import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class AppTab {
  const AppTab(this.label, this.icon, this.selectedIcon);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const appTabs = [
  AppTab('Home', Icons.home_outlined, Icons.home_rounded),
  AppTab('Prenota', Icons.calendar_month_outlined, Icons.calendar_month),
  AppTab('Partite', Icons.sports_tennis_outlined, Icons.sports_tennis),
  AppTab('Profilo', Icons.person_outline, Icons.person_rounded),
];

/// Barra in basso "a incavo" (template B): la tab attiva sale in un cerchio
/// che galleggia sopra un incavo ritagliato nella barra.
class AppBottomBar extends StatelessWidget {
  const AppBottomBar({
    super.key,
    required this.currentIndex,
    required this.onSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onSelected;

  /// Spazio sopra la barra occupato da metà cerchio.
  static const _overlap = 28.0;
  static const _barHeight = 64.0;
  static const _circle = 52.0;
  static const _sidePadding = 28.0;
  static const _duration = Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return SizedBox(
      height: _overlap + _barHeight + bottomInset,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth =
              (constraints.maxWidth - 2 * _sidePadding) / appTabs.length;
          double centerOf(double index) =>
              _sidePadding + itemWidth * (index + 0.5);
          return TweenAnimationBuilder<double>(
            tween: Tween(end: currentIndex.toDouble()),
            duration: _duration,
            curve: Curves.easeOutCubic,
            builder: (context, position, _) {
              final notchX = centerOf(position);
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _NotchedBarPainter(
                        notchX: notchX,
                        top: _overlap,
                        fill: colors.surface,
                        border: colors.border,
                      ),
                    ),
                  ),
                  for (var i = 0; i < appTabs.length; i++)
                    Positioned(
                      left: _sidePadding + itemWidth * i,
                      top: _overlap,
                      width: itemWidth,
                      height: _barHeight,
                      child: _TabButton(
                        tab: appTabs[i],
                        selected: i == currentIndex,
                        onTap: () => onSelected(i),
                      ),
                    ),
                  Positioned(
                    left: notchX - _circle / 2,
                    top: _overlap - _circle / 2,
                    width: _circle,
                    height: _circle,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: AnimatedSwitcher(
                          duration: _duration,
                          child: Icon(
                            appTabs[currentIndex].selectedIcon,
                            key: ValueKey(currentIndex),
                            color: colors.onPrimary,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final AppTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      label: tab.label,
      onTap: onTap,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 32,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AnimatedOpacity(
                opacity: selected ? 0 : 1,
                duration: AppBottomBar._duration,
                child: Icon(tab.icon, color: colors.textSecondary, size: 24),
              ),
              const SizedBox(height: 2),
              Text(
                tab.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? colors.primaryText : colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Disegna la barra con l'incavo centrato in [notchX].
class _NotchedBarPainter extends CustomPainter {
  _NotchedBarPainter({
    required this.notchX,
    required this.top,
    required this.fill,
    required this.border,
  });

  final double notchX;
  final double top;
  final Color fill;
  final Color border;

  static const _radius = 20.0;
  static const _halfWidth = 50.0;
  static const _depth = 32.0;

  @override
  void paint(Canvas canvas, Size size) {
    // L'incavo non deve entrare negli angoli arrotondati.
    final x = notchX.clamp(
      _radius + _halfWidth,
      size.width - _radius - _halfWidth,
    );
    final outline = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, top + _radius)
      ..quadraticBezierTo(0, top, _radius, top)
      ..lineTo(x - _halfWidth, top)
      ..cubicTo(x - 30, top, x - 34, top + _depth, x, top + _depth)
      ..cubicTo(x + 34, top + _depth, x + 30, top, x + _halfWidth, top)
      ..lineTo(size.width - _radius, top)
      ..quadraticBezierTo(size.width, top, size.width, top + _radius)
      ..lineTo(size.width, size.height);
    canvas
      ..drawPath(Path.from(outline)..close(), Paint()..color = fill)
      ..drawPath(
        outline,
        Paint()
          ..color = border
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
  }

  @override
  bool shouldRepaint(_NotchedBarPainter old) =>
      old.notchX != notchX || old.fill != fill || old.border != border;
}
