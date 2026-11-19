import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/localization/locale_service.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_button.dart';
import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';
import '../widgets/onboarding_header.dart';
import '../widgets/onboarding_page_view.dart';
import '../widgets/step_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OnboardingCubit>();

    return MultiBlocListener(
      listeners: [
        BlocListener<OnboardingCubit, OnboardingState>(
          listenWhen: (p, c) => !p.isCompleted && c.isCompleted,
          listener: (context, _) =>
              Navigator.of(context).pushReplacementNamed(AppRoutes.gate),
        ),
        // Keeps the PageView in sync when "next" is pressed.
        BlocListener<OnboardingCubit, OnboardingState>(
          listenWhen: (p, c) => p.currentIndex != c.currentIndex,
          listener: (context, state) {
            if (_controller.hasClients &&
                _controller.page?.round() != state.currentIndex) {
              _controller.animateToPage(
                state.currentIndex,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.backgroundBody,
        body: SafeArea(
          child: BlocBuilder<OnboardingCubit, OnboardingState>(
            builder: (context, state) => Column(
              children: [
                SizedBox(height: 16.h),
                OnboardingHeader(
                  onSkip: cubit.skip,
                  onLanguageTap: () =>
                      context.read<LocaleService>().toggle(context),
                ),
                SizedBox(height: 64.h),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: state.pages.length,
                    onPageChanged: cubit.pageChanged,
                    itemBuilder: (_, i) => LayoutBuilder(
                      builder: (_, box) => SingleChildScrollView(
                        child: OnboardingPageView(
                          page: state.pages[i],
                          // Figma: 320 tall image, shrinks only when the
                          // screen can't fit image + 58 gap + text block.
                          imageHeight: (box.maxHeight - 58.h - 100.h).clamp(
                            200.h,
                            320.h,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                StepIndicator(
                  count: state.pages.length,
                  index: state.currentIndex,
                ),
                SizedBox(height: 24.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.5.w),
                  child: AppButton(
                    label: state.currentPage.buttonKey.tr(context: context),
                    variant: state.isLastPage
                        ? AppButtonVariant.primary
                        : AppButtonVariant.secondary,
                    onPressed: cubit.next,
                  ),
                ),
                SizedBox(height: 52.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
