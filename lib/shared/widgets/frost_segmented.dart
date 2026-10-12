import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:foggygram/core/theme/foggy_theme.dart';

/// Frosted glass segmented control with a sliding active indicator pill
/// and hover brightening for inactive tabs.
class FrostSegmented extends StatefulWidget {
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const FrostSegmented({
    super.key,
    List<String>? items,
    List<String>? segments,
    required this.selectedIndex,
    required this.onChanged,
  }) : items = items ?? segments ?? const [];

  @override
  State<FrostSegmented> createState() => _FrostSegmentedState();
}

class _FrostSegmentedState extends State<FrostSegmented> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    const double outerPadding = 4.0;
    const double borderRadius = 16.0;
    const double segmentRadius = 12.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : (widget.items.length * 110.0 + outerPadding * 2);
        final double contentWidth = availableWidth - (outerPadding * 2);
        final double segmentWidth = contentWidth / widget.items.length;
        const double segmentHeight = 40.0;
        final double totalHeight = segmentHeight + (outerPadding * 2);

        return Container(
          width: availableWidth,
          height: totalHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: Colors.white.withOpacity(0.04),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 1.0,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Stack(
                children: [
                  // Sliding active indicator
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    left: outerPadding + (widget.selectedIndex * segmentWidth),
                    top: outerPadding,
                    width: segmentWidth,
                    height: segmentHeight,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(segmentRadius),
                        color: Colors.white.withOpacity(0.88),
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(0, 3),
                            blurRadius: 10,
                            color: Colors.black.withOpacity(0.20),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Segment buttons row
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(outerPadding),
                      child: Row(
                        children: List.generate(widget.items.length, (index) {
                          final isSelected = widget.selectedIndex == index;
                          final isHovered = _hoveredIndex == index;

                          Color textColor;
                          if (isSelected) {
                            textColor = const Color(0xFF0D0D0D);
                          } else if (isHovered) {
                            textColor = FoggyColors.text;
                          } else {
                            textColor = FoggyColors.muted;
                          }

                          return Expanded(
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              onEnter: (_) => setState(() => _hoveredIndex = index),
                              onExit: (_) => setState(() {
                                if (_hoveredIndex == index) {
                                  _hoveredIndex = null;
                                }
                              }),
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => widget.onChanged(index),
                                child: Container(
                                  height: segmentHeight,
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                  child: AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 200),
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.2,
                                      color: textColor,
                                    ),
                                    child: Text(
                                      widget.items[index],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
