import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_sub_page.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/auth_messages.dart';
import '../../../auth/presentation/widgets/country_picker_sheet.dart';
import '../../../auth/presentation/widgets/phone_field.dart';
import '../../domain/entities/address.dart';
import '../../domain/entities/address_type.dart';
import '../cubit/address_form_cubit.dart';
import '../widgets/address_type_icon.dart';

/// The details of an address: its type, name, phone, where exactly and notes
/// for the courier. [onSaved] gets the finished [Address]; [onDelete] (the
/// edit case) adds a delete button and returns true when it deleted.
class AddressDetailsPage extends StatefulWidget {
  const AddressDetailsPage({super.key, required this.onSaved, this.onDelete});

  final ValueChanged<Address> onSaved;
  final Future<bool> Function()? onDelete;

  @override
  State<AddressDetailsPage> createState() => _AddressDetailsPageState();
}

class _AddressDetailsPageState extends State<AddressDetailsPage> {
  final Map<AddressField, TextEditingController> _controllers = {};
  late final TextEditingController _phone;

  TextEditingController _controller(AddressField field) =>
      _controllers.putIfAbsent(
        field,
        () => TextEditingController(
          text: field == AddressField.title
              ? context.read<AddressFormCubit>().state.title
              : context.read<AddressFormCubit>().valueOf(field),
        ),
      );

  @override
  void initState() {
    super.initState();
    _phone = TextEditingController(
      text: context.read<AddressFormCubit>().phoneText,
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _phone.dispose();
    super.dispose();
  }

  String _t(String key) => 'address.form.$key'.tr(context: context);

  String _label(AddressField field, AddressType type) => switch (field) {
    AddressField.building =>
      type == AddressType.other ? _t('place') : _t('building'),
    AddressField.floor => _t('floor'),
    AddressField.unit => switch (type) {
      AddressType.house => _t('house_number'),
      AddressType.office => _t('office_number'),
      _ => _t('apartment_number'),
    },
    _ => '',
  };

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddressFormCubit>();
    return MultiBlocListener(
      listeners: [
        BlocListener<AddressFormCubit, AddressFormState>(
          listenWhen: (p, c) => p.saved == null && c.saved != null,
          listener: (_, state) => widget.onSaved(state.saved!),
        ),
        // The name follows the type until the customer types their own.
        BlocListener<AddressFormCubit, AddressFormState>(
          listenWhen: (p, c) => p.title != c.title,
          listener: (_, state) {
            final controller = _controller(AddressField.title);
            if (controller.text != state.title) controller.text = state.title;
          },
        ),
      ],
      child: BlocBuilder<AddressFormCubit, AddressFormState>(
        builder: (context, state) {
          String? error(AddressField field, String group) =>
              AuthMessages.validation(context, group, state.errors[field]);
          return AppSubPage(
            title: _t('title'),
            body: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      for (final type in AddressType.values) ...[
                        if (type != AddressType.values.first)
                          SizedBox(width: 8.w),
                        Expanded(
                          child: _TypeOption(
                            type: type,
                            label: _t(type.name),
                            selected: state.type == type,
                            onTap: () => cubit.typeChanged(type),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 16.h),
                  AppTextField(
                    label: _t('name'),
                    hint: _t('name_hint'),
                    controller: _controller(AddressField.title),
                    textInputAction: TextInputAction.next,
                    errorText: error(AddressField.title, 'address_title'),
                    onChanged: (v) => cubit.changed(AddressField.title, v),
                  ),
                  for (final field in AddressFormState.fieldsFor(
                    state.type,
                  )) ...[
                    SizedBox(height: 16.h),
                    AppTextField(
                      key: ValueKey('${state.type.name}-${field.name}'),
                      label: _label(field, state.type),
                      hint: _label(field, state.type),
                      controller: _controller(field),
                      textInputAction: TextInputAction.next,
                      keyboardType: field == AddressField.building
                          ? TextInputType.text
                          : TextInputType.text,
                      errorText: error(
                        field,
                        field == AddressField.building
                            ? 'address_place'
                            : 'address_number',
                      ),
                      onChanged: (v) => cubit.changed(field, v),
                    ),
                  ],
                  SizedBox(height: 16.h),
                  PhoneField(
                    label: 'auth.fields.phone'.tr(context: context),
                    hint: 'auth.fields.phone_hint'.tr(context: context),
                    country: state.country,
                    controller: _phone,
                    errorText: AuthMessages.validation(
                      context,
                      'phone',
                      state.errors[AddressField.phone],
                    ),
                    textInputAction: TextInputAction.next,
                    onChanged: (v) => cubit.changed(AddressField.phone, v),
                    onCountryTap: () => CountryPickerSheet.show(
                      context,
                      title: 'auth.country.title'.tr(context: context),
                      searchHint: 'auth.country.search'.tr(context: context),
                      emptyLabel: 'auth.country.empty'.tr(context: context),
                      languageCode: context.locale.languageCode,
                      selected: state.country,
                      onSelected: cubit.countryChanged,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  AppTextField(
                    label: _t('instructions'),
                    hint: _t('instructions_hint'),
                    controller: _controller(AddressField.instructions),
                    textInputAction: TextInputAction.done,
                    errorText: error(
                      AddressField.instructions,
                      'address_instructions',
                    ),
                    onChanged: (v) =>
                        cubit.changed(AddressField.instructions, v),
                  ),
                  if (widget.onDelete != null) ...[
                    SizedBox(height: 24.h),
                    AppButton(
                      label: _t('delete'),
                      variant: AppButtonVariant.secondary,
                      onPressed: () async {
                        final deleted = await widget.onDelete!();
                        if (deleted && context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),
            bottom: AppButton(label: _t('save'), onPressed: cubit.submit),
          );
        },
      ),
    );
  }
}

/// One of the four address types: its icon over its name; green when chosen.
class _TypeOption extends StatelessWidget {
  const _TypeOption({
    required this.type,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final AddressType type;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textDefault;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
            color: selected
                ? AppColors.primary.withValues(alpha: 0.06)
                : AppColors.white,
          ),
          child: Column(
            children: [
              SvgPicture.asset(
                AddressTypeIcon.assetOf(type),
                width: 24.r,
                height: 24.r,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
              SizedBox(height: 6.h),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.textXsRegular.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
