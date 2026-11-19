import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_sub_page.dart';
import '../../domain/entities/tax_invoice.dart';
import '../cubit/tax_invoice_cubit.dart';
import '../formatters/orders_formatters.dart';

/// "فاتورة ضريبية": the invoice of a delivered order, laid out like the
/// printed one (its labels are bilingual by law, so they stay as the API
/// sends them).
class TaxInvoicePage extends StatelessWidget {
  const TaxInvoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TaxInvoiceCubit>();
    return BlocBuilder<TaxInvoiceCubit, TaxInvoiceState>(
      builder: (context, state) => AppSubPage(
        title: 'orders.invoice_title'.tr(context: context),
        backgroundColor: AppColors.backgroundBody,
        body: switch (state.status) {
          TaxInvoiceStatus.loading => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          TaxInvoiceStatus.failed => Center(
            child: TextButton(
              onPressed: cubit.load,
              child: Text('home.retry'.tr(context: context)),
            ),
          ),
          TaxInvoiceStatus.ready => SingleChildScrollView(
            padding: EdgeInsets.all(16.r),
            child: _Paper(invoice: state.invoice!),
          ),
        },
      ),
    );
  }
}

class _Paper extends StatelessWidget {
  const _Paper({required this.invoice});

  final TaxInvoice invoice;

  @override
  Widget build(BuildContext context) {
    final base = AppTextStyles.textXsRegular.copyWith(
      color: AppColors.textDefault,
    );
    final bold = AppTextStyles.textXsBold.copyWith(
      color: AppColors.textDefault,
    );
    String money(double v) =>
        '${invoice.currencyCode}  ${OrdersFormatters.amount(v, decimals: 3)}';
    Widget field(String label, String value) => Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: Text(label, style: bold)),
          Expanded(flex: 2, child: Text(value, style: base)),
        ],
      ),
    );
    return Directionality(
      // The printed invoice is laid out left to right in both languages.
      textDirection: TextDirection.ltr,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.r),
        color: AppColors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              invoice.merchantName,
              textAlign: TextAlign.center,
              style: bold,
            ),
            SizedBox(height: 12.h),
            Text(
              invoice.merchantAddress,
              textAlign: TextAlign.center,
              style: bold,
            ),
            SizedBox(height: 24.h),
            for (final line in invoice.lines)
              Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        line.rateLabel == null
                            ? line.label
                            : '${line.label}   ${line.rateLabel}',
                        style: base,
                      ),
                    ),
                    Text(money(line.amount), style: base),
                  ],
                ),
              ),
            const Divider(color: AppColors.textDefault, thickness: 1),
            Row(
              children: [
                Expanded(child: Text('Total / المجموع', style: bold)),
                Text(money(invoice.total), style: bold),
              ],
            ),
            const Divider(color: AppColors.textDefault, thickness: 1),
            SizedBox(height: 16.h),
            Text('Registered Address / العنوان المسجل', style: bold),
            SizedBox(height: 4.h),
            Text(invoice.registeredAddress, style: base),
            SizedBox(height: 8.h),
            for (final detail in invoice.companyDetails)
              Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Text(detail, style: base),
              ),
            SizedBox(height: 12.h),
            field('Sales Tax. No / رقم ضريبة المبيعات', invoice.salesTaxNumber),
            field(
              'Issue Date / تاريخ إصدار الفاتورة',
              OrdersFormatters.invoiceDate(invoice.issueDate),
            ),
            field('Invoice No / رقم الفاتورة', invoice.invoiceNumber),
            field('Order Id / رقم الطلب', invoice.orderNumber),
          ],
        ),
      ),
    );
  }
}
