import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_sub_page.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/auth_messages.dart';
import '../cubit/edit_text_cubit.dart';

/// One-field edit page (name, e-mail): the field, an optional [helper] under
/// it and a Save button. Pops with `true` once the change is saved.
class EditTextPage<T> extends StatefulWidget {
  const EditTextPage({
    super.key,
    required this.title,
    required this.label,
    required this.hint,
    required this.field,
    required this.initial,
    this.helper,
    this.keyboardType,
    this.ltr = false,
    this.inputFormatters,
  });

  final String title;
  final String label;
  final String hint;

  /// Validation message group: `name`, `email`.
  final String field;
  final String initial;
  final String? helper;
  final TextInputType? keyboardType;

  /// Type left to right (an e-mail) whatever the app language is.
  final bool ltr;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<EditTextPage<T>> createState() => _EditTextPageState<T>();
}

class _EditTextPageState<T> extends State<EditTextPage<T>> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EditTextCubit<T>>();
    return BlocConsumer<EditTextCubit<T>, EditTextState>(
      listenWhen: (p, c) => !p.saved && c.saved,
      listener: (context, _) => Navigator.of(context).pop(true),
      builder: (context, state) => AppSubPage(
        title: widget.title,
        loading: state.saving,
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: widget.label,
                hint: widget.hint,
                controller: _controller,
                keyboardType: widget.keyboardType,
                inputFormatters: widget.inputFormatters,
                textDirection: widget.ltr ? TextDirection.ltr : null,
                textInputAction: TextInputAction.done,
                errorText: AuthMessages.validation(
                  context,
                  widget.field,
                  state.error,
                ),
                onChanged: cubit.changedTo,
                onSubmitted: (_) => cubit.submit(),
              ),
              if (widget.helper != null && state.error == null) ...[
                SizedBox(height: 8.h),
                Text(
                  widget.helper!,
                  style: AppTextStyles.textSmRegular.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              if (state.failure != null) ...[
                SizedBox(height: 8.h),
                Text(
                  'profile.save_failed'.tr(context: context),
                  key: const ValueKey('save-failed'),
                  style: AppTextStyles.textSmRegular.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
            ],
          ),
        ),
        bottom: AppButton(
          label: 'profile.save'.tr(context: context),
          onPressed: state.saving ? null : cubit.submit,
        ),
      ),
    );
  }
}
