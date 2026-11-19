import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../../../core/widgets/previews/preview_wrapper.dart';
import '../../../domain/entities/address.dart';
import '../../../domain/entities/address_type.dart';
import '../../../domain/entities/geo_point.dart';
import '../../../domain/entities/place_info.dart';
import '../../../domain/entities/place_suggestion.dart';
import '../../cubit/map_picker_state.dart';
import '../address_list_sheet.dart';
import '../address_panel.dart';
import '../delivery_address_bar.dart';
import '../delivery_options_sheet.dart';
import '../hint_tooltip.dart';
import '../map_pin.dart';
import '../suggestion_list.dart';

// Run with:  flutter widget-preview start

const _addresses = [
  Address(
    id: '1',
    title: 'My Home',
    details: '32, سهيل بن عمرو, طبربور',
    point: GeoPoint(31.9863, 35.9814),
    type: AddressType.apartment,
    phone: '079XXXXXXX',
  ),
  Address(
    id: '2',
    title: 'فيلا أوس',
    details: '5, شارع الحرانة, طبربور',
    point: GeoPoint(31.984, 35.975),
    type: AddressType.house,
    phone: '079XXXXXXX',
  ),
  Address(
    id: '3',
    title: 'المكتب',
    details: '3, مجمع البواب, جبل الحسين',
    point: GeoPoint(31.9632, 35.9189),
    type: AddressType.office,
    phone: '079XXXXXXX',
  ),
  Address(
    id: '4',
    title: 'الجامعة',
    details: 'جامعة الزيتونة',
    point: GeoPoint(31.8335, 35.8456),
    phone: '079XXXXXXX',
  ),
];

@Preview(
  group: 'Address / Header line',
  name: 'No address (AR)',
  size: Size(375, 70),
  wrapper: rtlWrapper,
)
Widget lineEmptyArabic() => const DeliveryAddressBar(
  prefix: 'التوصيل إلى',
  question: 'أين تريد التوصيل؟',
);

@Preview(
  group: 'Address / Header line',
  name: 'Saved address (AR)',
  size: Size(375, 70),
  wrapper: rtlWrapper,
)
Widget lineSavedArabic() => const DeliveryAddressBar(
  prefix: 'التوصيل إلى',
  question: 'أين تريد التوصيل؟',
  place: 'موقع غير محفوظ',
);

@Preview(
  group: 'Address / Header line',
  name: 'Saved address (EN)',
  size: Size(375, 70),
  wrapper: ltrWrapper,
)
Widget lineSavedEnglish() => const DeliveryAddressBar(
  prefix: 'Deliver to',
  question: 'Where do you want it delivered?',
  place: 'My Home',
);

@Preview(
  group: 'Address / Hint bubble',
  name: 'Choose an address (AR)',
  size: Size(375, 110),
  wrapper: rtlWrapper,
)
Widget hintArabic() => const Align(
  alignment: AlignmentDirectional.topStart,
  child: HintTooltip(
    width: 160,
    arrowInset: 12,
    text: 'لتجربة أفضل وعرض الصيدلية القريبة',
  ),
);

@Preview(
  group: 'Address / Hint bubble',
  name: 'Unsaved location (EN)',
  size: Size(375, 130),
  wrapper: ltrWrapper,
)
Widget hintEnglish() => const Align(
  alignment: AlignmentDirectional.topStart,
  child: HintTooltip(
    width: 160,
    arrowInset: 12,
    text:
        'The address you chose is different from your current location. Are you sure about the delivery address?',
  ),
);

@Preview(
  group: 'Address / Sheets',
  name: 'Where to deliver (AR)',
  size: Size(375, 330),
  wrapper: rtlWrapper,
)
Widget optionsArabic() => DeliveryOptionsSheet(
  locating: false,
  onSearchOnMap: () {},
  onUseCurrentLocation: () {},
  onAddNew: () {},
);

@Preview(
  group: 'Address / Sheets',
  name: 'Location denied (EN)',
  size: Size(375, 360),
  wrapper: ltrWrapper,
)
Widget optionsError() => DeliveryOptionsSheet(
  locating: false,
  errorText:
      'Location access was not allowed. Enable it in the device settings',
  onSearchOnMap: () {},
  onUseCurrentLocation: () {},
  onAddNew: () {},
);

@Preview(
  group: 'Address / Sheets',
  name: 'Delivery addresses (AR)',
  size: Size(375, 520),
  wrapper: rtlWrapper,
)
Widget listArabic() => AddressListSheet(
  addresses: _addresses,
  onSelected: (_) {},
  onAddNew: () {},
);

@Preview(
  group: 'Address / Sheets',
  name: 'Delivery addresses (EN)',
  size: Size(375, 520),
  wrapper: ltrWrapper,
)
Widget listEnglish() => AddressListSheet(
  addresses: _addresses,
  onSelected: (_) {},
  onAddNew: () {},
);

@Preview(
  group: 'Address / Map',
  name: 'Pin (deliverable)',
  size: Size(375, 120),
  wrapper: rtlWrapper,
)
Widget pinOk() => const MapPin(showUnavailable: false);

@Preview(
  group: 'Address / Map',
  name: 'Pin (not deliverable, AR)',
  size: Size(375, 150),
  wrapper: rtlWrapper,
)
Widget pinBlocked() => const MapPin(showUnavailable: true);

@Preview(
  group: 'Address / Map',
  name: 'Panel, can confirm (AR)',
  size: Size(375, 190),
  wrapper: rtlWrapper,
)
Widget panelReady() => AddressPanel(
  status: PlaceStatus.ready,
  place: const PlaceInfo(
    headline: 'شارع الدفاع',
    details: 'إربد، مدينة الحسن للشباب',
  ),
  failedText: 'تعذّر تحديد عنوان هذا الموقع',
  confirmLabel: 'تأكيد الموقع',
  onConfirm: () {},
);

@Preview(
  group: 'Address / Map',
  name: 'Panel, disabled (EN)',
  size: Size(375, 190),
  wrapper: ltrWrapper,
)
Widget panelBlocked() => const AddressPanel(
  status: PlaceStatus.ready,
  place: PlaceInfo(headline: 'Al-Difaa St', details: 'Irbid, Jordan'),
  failedText: 'Could not find an address for this spot',
  confirmLabel: 'Confirm location',
  onConfirm: null,
);

@Preview(
  group: 'Address / Map',
  name: 'Panel, loading (AR)',
  size: Size(375, 190),
  wrapper: rtlWrapper,
)
Widget panelLoading() => const AddressPanel(
  status: PlaceStatus.loading,
  place: null,
  failedText: 'تعذّر تحديد عنوان هذا الموقع',
  confirmLabel: 'تأكيد الموقع',
  onConfirm: null,
);

@Preview(
  group: 'Address / Map',
  name: 'Search suggestions (AR)',
  size: Size(375, 260),
  wrapper: rtlWrapper,
)
Widget suggestionsArabic() => SuggestionList(
  status: SuggestionsStatus.done,
  suggestions: const [
    PlaceSuggestion(placeId: '1', description: 'إربد، الأردن'),
    PlaceSuggestion(placeId: '2', description: 'شارع إربد، عمّان، الأردن'),
    PlaceSuggestion(placeId: '3', description: 'مجمع إربد، إربد، الأردن'),
  ],
  emptyText: 'لا توجد نتائج مطابقة',
  errorText: 'تعذّر البحث، حاول مرة أخرى',
  onSelected: (_) {},
);
