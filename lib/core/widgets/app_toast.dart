import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_text_styles.dart';

const Color _toastBackground = Color(0xFFE3F6E3);
const Color _toastForeground = Color(0xFF219F21);
const Color _toastErrorBackground = Color(0xFFFFE3E3);
const Color _toastErrorForeground = Color(0xFFB81515);

OverlayEntry? _current;

/// Notification toast from the design: a soft green (or red) bar with the
/// [message] and a close button. It slides in under the status bar, stays a
/// few seconds and slides out; a newer toast replaces it. It lives in the
/// app's overlay, so it survives page changes and does not move the page.
void showAppToast(
  BuildContext context,
  String message, {
  bool error = false,
  Duration duration = const Duration(seconds: 3),
}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;
  _current?.remove();
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _Toast(
      message: message,
      error: error,
      hold: duration,
      onDone: () {
        if (_current == entry) _current = null;
        entry.remove();
      },
    ),
  );
  _current = entry;
  overlay.insert(entry);
}

class _Toast extends StatefulWidget {
  const _Toast({
    required this.message,
    required this.error,
    required this.hold,
    required this.onDone,
  });

  final String message;
  final bool error;
  final Duration hold;
  final VoidCallback onDone;

  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> with SingleTickerProviderStateMixin {
  static const Duration _slide = Duration(milliseconds: 250);

  // One controller for the whole life: in, hold, out. Driven by an animation
  // (not a timer) so tests that wait for animations wait for the toast too.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _slide + widget.hold + _slide,
  );
  late final double _inEnd =
      _slide.inMilliseconds / _controller.duration!.inMilliseconds;
  late final double _outStart =
      (_controller.duration! - _slide).inMilliseconds /
      _controller.duration!.inMilliseconds;

  late final Animation<double> _shown = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(
        begin: 0.0,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: _inEnd,
    ),
    TweenSequenceItem(tween: ConstantTween(1.0), weight: _outStart - _inEnd),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.0,
        end: 0.0,
      ).chain(CurveTween(curve: Curves.easeIn)),
      weight: 1 - _outStart,
    ),
  ]).animate(_controller);

  @override
  void initState() {
    super.initState();
    _controller.forward().whenComplete(() {
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// The X: jump to the sliding-out part.
  void _dismiss() {
    if (_controller.value < _outStart) _controller.forward(from: _outStart);
  }

  @override
  Widget build(BuildContext context) {
    final foreground = widget.error ? _toastErrorForeground : _toastForeground;
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8.h,
      left: 10.w,
      right: 10.w,
      child: AnimatedBuilder(
        animation: _shown,
        builder: (context, child) => Opacity(
          opacity: _shown.value,
          child: Transform.translate(
            offset: Offset(0, -24.h * (1 - _shown.value)),
            child: child,
          ),
        ),
        child: Material(
          color: widget.error ? _toastErrorBackground : _toastBackground,
          elevation: 4,
          shadowColor: const Color(0x33101828),
          borderRadius: BorderRadius.circular(8.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.message,
                    style: AppTextStyles.textSmRegular.copyWith(
                      color: foreground,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                InkResponse(
                  onTap: _dismiss,
                  radius: 16.r,
                  child: Icon(Icons.close, size: 20.r, color: foreground),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
