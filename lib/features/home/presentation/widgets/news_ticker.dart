import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Blue news bar: the [items] run in an endless loop, each after a bullet.
/// The text moves the way the language reads — to the right in Arabic, to
/// the left in English — like the website's news bar.
class NewsTicker extends StatefulWidget {
  const NewsTicker({
    super.key,
    required this.items,
    this.animate = true,
    this.speed = 40,
  });

  final List<String> items;

  /// False keeps the bar still (tests, previews).
  final bool animate;

  /// Logical pixels per second.
  final double speed;

  @override
  State<NewsTicker> createState() => _NewsTickerState();
}

class _NewsTickerState extends State<NewsTicker>
    with SingleTickerProviderStateMixin {
  final ScrollController _scroll = ScrollController();
  late final Ticker _ticker = createTicker(_onTick);
  Duration _last = Duration.zero;

  void _onTick(Duration elapsed) {
    final dt =
        (elapsed - _last).inMicroseconds / Duration.microsecondsPerSecond;
    _last = elapsed;
    if (_scroll.hasClients) _scroll.jumpTo(_scroll.offset + widget.speed * dt);
  }

  void _sync() {
    final run =
        widget.animate &&
        widget.items.isNotEmpty &&
        !MediaQuery.disableAnimationsOf(context);
    if (run && !_ticker.isActive) {
      _last = Duration.zero;
      _ticker.start();
    } else if (!run && _ticker.isActive) {
      _ticker.stop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(NewsTicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    if (items.isEmpty) return const SizedBox.shrink();
    final style = AppTextStyles.textSmRegular.copyWith(color: AppColors.white);
    return Semantics(
      label: items.join('. '),
      child: ExcludeSemantics(
        child: Container(
          height: 40.h,
          color: AppColors.newsBar,
          // The bar moves by itself; it is not something to drag.
          child: IgnorePointer(
            child: ListView.builder(
              controller: _scroll,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (_, index) => Padding(
                padding: EdgeInsetsDirectional.only(start: 16.w),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 4.r,
                      height: 4.r,
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(items[index % items.length], style: style),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
