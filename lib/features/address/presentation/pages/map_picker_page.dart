import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/delivery_location.dart';
import '../cubit/map_picker_cubit.dart';
import '../cubit/map_picker_state.dart';
import '../widgets/address_panel.dart';
import '../widgets/map_canvas.dart';
import '../widgets/map_pin.dart';
import '../widgets/place_search_bar.dart';
import '../widgets/suggestion_list.dart';

/// Pick a place on the map: search at the top, the pin fixed at the centre,
/// the pin's address and the confirm button at the bottom. Confirming calls
/// [onConfirmed] with the place; the page does not decide what happens next.
class MapPickerPage extends StatefulWidget {
  const MapPickerPage({
    super.key,
    required this.onConfirmed,
    this.mapBuilder = googleMapCanvas,
    this.focusSearch = false,
  });

  final ValueChanged<DeliveryLocation> onConfirmed;
  final MapCanvasBuilder mapBuilder;

  /// Opens with the keyboard on the search field.
  final bool focusSearch;

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  final TextEditingController _search = TextEditingController();
  final FocusNode _focus = FocusNode();
  String? _languageCode;

  @override
  void initState() {
    super.initState();
    if (widget.focusSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focus.requestFocus();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final code = context.locale.languageCode;
    final cubit = context.read<MapPickerCubit>();
    if (_languageCode == null) {
      _languageCode = code;
      cubit.start(code);
    } else if (code != _languageCode) {
      _languageCode = code;
      cubit.changeLanguage(code);
    }
  }

  @override
  void dispose() {
    _search.dispose();
    _focus.dispose();
    super.dispose();
  }

  String _t(String key) => 'address.$key'.tr(context: context);

  void _back() {
    final cubit = context.read<MapPickerCubit>();
    if (cubit.state.showSuggestions) {
      _focus.unfocus();
      cubit.closeSuggestions();
    } else {
      Navigator.maybePop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MapPickerCubit>();
    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<MapPickerCubit, MapPickerState>(
          builder: (context, state) => Stack(
            children: [
              Column(
                children: [
                  PlaceSearchBar(
                    controller: _search,
                    focusNode: _focus,
                    hint: _t('search_hint'),
                    clearLabel: _t('clear_search'),
                    onBack: _back,
                    onChanged: cubit.onQueryChanged,
                    onClear: () {
                      _search.clear();
                      cubit.onQueryChanged('');
                      // keep typing: the clear button must not close the keyboard
                      _focus.requestFocus();
                    },
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, box) => Stack(
                        children: [
                          Positioned.fill(
                            child: widget.mapBuilder(
                              context,
                              MapCanvasConfig(
                                initial: cubit.state.point,
                                onMoved: cubit.onCameraMove,
                                onIdle: cubit.onCameraIdle,
                                moveRequests: cubit.moveRequests,
                              ),
                            ),
                          ),
                          // The pin's top is 11pt above the centre, as designed.
                          Positioned(
                            top: box.maxHeight / 2 - 11.h,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: MapPin(
                                showUnavailable: state.outsideDeliveryArea,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AddressPanel(
                    status: state.placeStatus,
                    place: state.place,
                    failedText: _t('address_not_found'),
                    confirmLabel: _t('confirm_location'),
                    onConfirm: state.canConfirm
                        ? () => widget.onConfirmed(state.location!)
                        : null,
                  ),
                ],
              ),
              if (state.showSuggestions)
                PositionedDirectional(
                  top: 58.h,
                  start: 0,
                  end: 0,
                  child: SuggestionList(
                    status: state.suggestionsStatus,
                    suggestions: state.suggestions,
                    emptyText: _t('no_results'),
                    errorText: _t('search_error'),
                    onSelected: (suggestion) {
                      _focus.unfocus();
                      _search.text = suggestion.description;
                      cubit.selectSuggestion(suggestion);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
