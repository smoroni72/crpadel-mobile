import 'package:flutter/material.dart';

/// Two aligned columns whose rows can grow to fit captions and larger text.
class AdaptiveMetricsGrid extends StatelessWidget {
  const AdaptiveMetricsGrid({
    super.key,
    required this.children,
    this.aspectRatio = 1.35,
    this.spacing = 8,
  });
  final List<Widget> children;
  final double aspectRatio;
  final double spacing;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, size) {
      final minimumHeight = (size.maxWidth - spacing) / 2 / aspectRatio;
      return Column(
        children: [
          for (var i = 0; i < children.length; i += 2)
            Padding(
              padding: EdgeInsets.only(
                bottom: i + 2 < children.length ? spacing : 0,
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: minimumHeight),
                        child: children[i],
                      ),
                    ),
                    SizedBox(width: spacing),
                    Expanded(
                      child: i + 1 < children.length
                          ? ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: minimumHeight,
                              ),
                              child: children[i + 1],
                            )
                          : const SizedBox(),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    },
  );
}
