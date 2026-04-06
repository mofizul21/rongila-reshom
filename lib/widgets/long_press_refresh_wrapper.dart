import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';

/// A wrapper widget that adds long-press to refresh functionality
/// similar to Facebook and YouTube apps.
///
/// When the user long-presses on the scrollable content, it triggers
/// a refresh callback. Also supports pull-to-refresh via RefreshIndicator.
class LongPressRefreshWrapper extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Duration longPressDuration;
  final bool enableLongPress;
  final bool enablePullToRefresh;

  const LongPressRefreshWrapper({
    super.key,
    required this.child,
    required this.onRefresh,
    this.longPressDuration = const Duration(milliseconds: 800),
    this.enableLongPress = true,
    this.enablePullToRefresh = true,
  });

  @override
  State<LongPressRefreshWrapper> createState() => _LongPressRefreshWrapperState();
}

class _LongPressRefreshWrapperState extends State<LongPressRefreshWrapper> {
  bool _isRefreshing = false;
  bool _showLongPressIndicator = false;
  Timer? _longPressTimer;

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
          _showLongPressIndicator = false;
        });
      }
    }
  }

  void _handleLongPressStart() {
    if (_isRefreshing || !widget.enableLongPress) return;

    setState(() {
      _showLongPressIndicator = true;
    });

    _longPressTimer = Timer(widget.longPressDuration, () {
      if (mounted && _showLongPressIndicator) {
        HapticFeedback.mediumImpact();
        _handleRefresh();
      }
    });
  }

  void _handleLongPressEnd() {
    _longPressTimer?.cancel();
    _longPressTimer = null;

    if (mounted) {
      setState(() {
        _showLongPressIndicator = false;
      });
    }
  }

  @override
  void dispose() {
    _longPressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = Listener(
      onPointerDown: (_) {
        if (widget.enableLongPress) {
          _handleLongPressStart();
        }
      },
      onPointerUp: (_) {
        _handleLongPressEnd();
      },
      onPointerCancel: (_) {
        _handleLongPressEnd();
      },
      child: Stack(
        children: [
          widget.child,
          if (_showLongPressIndicator && !widget.enablePullToRefresh)
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Refreshing...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    if (widget.enablePullToRefresh) {
      return RefreshIndicator(
        onRefresh: _handleRefresh,
        backgroundColor: Theme.of(context).colorScheme.primary,
        color: Colors.white,
        child: content,
      );
    }

    return content;
  }
}
