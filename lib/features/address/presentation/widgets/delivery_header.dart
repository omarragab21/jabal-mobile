import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubit/delivery_location_cubit.dart';
import '../cubit/delivery_location_state.dart';
import 'delivery_address_bar.dart';
import 'hint_tooltip.dart';

/// Top of the home page: the delivery address line, with [below] (the
/// search field) under it. While no place is chosen, or the chosen one is
/// not saved, a hint bubble hangs from the address line over [below].
class DeliveryHeader extends StatefulWidget {
  const DeliveryHeader({super.key, required this.below, required this.onTap});

  final Widget below;

  /// The address line was tapped: open the delivery sheet.
  final VoidCallback onTap;

  @override
  State<DeliveryHeader> createState() => _DeliveryHeaderState();
}

class _DeliveryHeaderState extends State<DeliveryHeader> {
  // The bubble overlaps the search field, so it lives in the overlay: a child
  // that sticks out of its parent's box cannot be tapped.
  final OverlayPortalController _portal = OverlayPortalController();
  final LayerLink _link = LayerLink();

  String _t(String key) => 'address.$key'.tr(context: context);

  void _syncBubble(DeliveryHint? hint) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (hint != null && !_portal.isShowing) _portal.show();
      if (hint == null && _portal.isShowing) _portal.hide();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeliveryLocationCubit, DeliveryLocationState>(
      builder: (context, state) {
        final selection = state.selection;
        final hint = state.hint;
        _syncBubble(hint);
        final rtl = Directionality.of(context) == TextDirection.rtl;
        final place = selection == null
            ? null
            : selection.isSaved
            ? selection.label
            : _t('unsaved_location');
        return OverlayPortal(
          controller: _portal,
          overlayChildBuilder: (_) => hint == null
              ? const SizedBox.shrink()
              : Positioned(
                  left: 0,
                  top: 0,
                  child: CompositedTransformFollower(
                    link: _link,
                    showWhenUnlinked: false,
                    targetAnchor: rtl
                        ? Alignment.bottomRight
                        : Alignment.bottomLeft,
                    followerAnchor: rtl
                        ? Alignment.topRight
                        : Alignment.topLeft,
                    child: HintTooltip(
                      key: ValueKey(hint),
                      width: 160,
                      arrowInset: 12,
                      text: _t(
                        hint == DeliveryHint.chooseAddress
                            ? 'hint_choose_address'
                            : 'hint_unsaved_location',
                      ),
                      onTap: context.read<DeliveryLocationCubit>().dismissHint,
                    ),
                  ),
                ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CompositedTransformTarget(
                link: _link,
                child: DeliveryAddressBar(
                  prefix: _t('deliver_to'),
                  question: _t('where_to_deliver'),
                  place: place,
                  onTap: widget.onTap,
                ),
              ),
              SizedBox(height: 8.h),
              widget.below,
            ],
          ),
        );
      },
    );
  }
}
