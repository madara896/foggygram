import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:foggygram/core/theme/foggy_theme.dart';

/// Pill-shaped frosted search bar with magnifying glass icon and animated clear button.
class FrostSearch extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final bool autofocus;
  final FocusNode? focusNode;

  const FrostSearch({
    super.key,
    this.controller,
    this.hintText = 'Search...',
    this.onChanged,
    this.onClear,
    this.autofocus = false,
    this.focusNode,
  });

  @override
  State<FrostSearch> createState() => _FrostSearchState();
}

class _FrostSearchState extends State<FrostSearch> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _internalController = false;
  bool _internalFocusNode = false;
  bool _isFocused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _internalController = true;
    }
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_handleTextChange);

    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _internalFocusNode = true;
    }
    _isFocused = _focusNode.hasFocus;
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant FrostSearch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (_internalController) {
        _controller.removeListener(_handleTextChange);
        _controller.dispose();
      } else {
        oldWidget.controller?.removeListener(_handleTextChange);
      }

      if (widget.controller != null) {
        _controller = widget.controller!;
        _internalController = false;
      } else {
        _controller = TextEditingController();
        _internalController = true;
      }
      _hasText = _controller.text.isNotEmpty;
      _controller.addListener(_handleTextChange);
    }

    if (widget.focusNode != oldWidget.focusNode) {
      if (_internalFocusNode) {
        _focusNode.removeListener(_handleFocusChange);
        _focusNode.dispose();
      } else {
        oldWidget.focusNode?.removeListener(_handleFocusChange);
      }

      if (widget.focusNode != null) {
        _focusNode = widget.focusNode!;
        _internalFocusNode = false;
      } else {
        _focusNode = FocusNode();
        _internalFocusNode = true;
      }
      _isFocused = _focusNode.hasFocus;
      _focusNode.addListener(_handleFocusChange);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChange);
    if (_internalController) {
      _controller.dispose();
    }
    _focusNode.removeListener(_handleFocusChange);
    if (_internalFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleTextChange() {
    final nowHasText = _controller.text.isNotEmpty;
    if (mounted && nowHasText != _hasText) {
      setState(() {
        _hasText = nowHasText;
      });
    }
  }

  void _handleFocusChange() {
    if (mounted && _isFocused != _focusNode.hasFocus) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  void _clearSearch() {
    _controller.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.all(Radius.circular(22.0));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: FoggyEasing.easeIn,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  offset: Offset.zero,
                  blurRadius: 0,
                  spreadRadius: 4,
                  color: Colors.white.withOpacity(0.06),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: FoggyEasing.easeIn,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: _isFocused
                  ? Colors.white.withOpacity(0.08)
                  : Colors.white.withOpacity(0.05),
              border: Border.all(
                color: _isFocused
                    ? Colors.white.withOpacity(0.40)
                    : Colors.white.withOpacity(0.08),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: _isFocused ? FoggyColors.text : FoggyColors.muted,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    autofocus: widget.autofocus,
                    cursorColor: Colors.white.withOpacity(0.85),
                    style: FoggyTextStyles.bodySmall.copyWith(
                      color: FoggyColors.text,
                    ),
                    onChanged: widget.onChanged,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: FoggyTextStyles.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.35),
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                  ),
                ),
                AnimatedOpacity(
                  opacity: _hasText ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  curve: FoggyEasing.easeIn,
                  child: IgnorePointer(
                    ignoring: !_hasText,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: _clearSearch,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.12),
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 12,
                            color: FoggyColors.muted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
