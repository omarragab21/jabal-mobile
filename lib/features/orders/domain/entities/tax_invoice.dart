import 'package:equatable/equatable.dart';

/// One charge line of the invoice, with the label in both languages as the
/// tax authority requires.
class InvoiceLine extends Equatable {
  const InvoiceLine({
    required this.label,
    required this.amount,
    this.rateLabel,
  });

  final String label;
  final double amount;

  /// `16%` for a tax line.
  final String? rateLabel;

  @override
  List<Object?> get props => [label, amount, rateLabel];
}

class TaxInvoice extends Equatable {
  const TaxInvoice({
    required this.merchantName,
    required this.merchantAddress,
    required this.currencyCode,
    required this.lines,
    required this.total,
    required this.registeredAddress,
    required this.companyDetails,
    required this.salesTaxNumber,
    required this.issueDate,
    required this.invoiceNumber,
    required this.orderNumber,
  });

  final String merchantName;
  final String merchantAddress;
  final String currencyCode;
  final List<InvoiceLine> lines;
  final double total;
  final String registeredAddress;

  /// Extra legal lines (capital, trade registration...).
  final List<String> companyDetails;
  final String salesTaxNumber;
  final DateTime issueDate;
  final String invoiceNumber;
  final String orderNumber;

  @override
  List<Object?> get props => [
    merchantName,
    merchantAddress,
    currencyCode,
    lines,
    total,
    registeredAddress,
    companyDetails,
    salesTaxNumber,
    issueDate,
    invoiceNumber,
    orderNumber,
  ];
}
