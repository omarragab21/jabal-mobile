import '../../../../core/utils/json_reader.dart';
import '../../domain/entities/tax_invoice.dart';

/// Parses the API's tax invoice JSON into the domain [TaxInvoice].
abstract final class TaxInvoiceModel {
  static TaxInvoice fromJson(Map<String, dynamic> json) => TaxInvoice(
    merchantName: JsonReader.string(json['merchant_name']),
    merchantAddress: JsonReader.string(json['merchant_address']),
    currencyCode: JsonReader.string(json['currency'], 'JOD'),
    lines: [
      for (final line in JsonReader.mapList(json['lines']))
        InvoiceLine(
          label: JsonReader.string(line['label']),
          amount: JsonReader.decimal(line['amount']),
          rateLabel: JsonReader.stringOrNull(line['rate']),
        ),
    ],
    total: JsonReader.decimal(json['total']),
    registeredAddress: JsonReader.string(json['registered_address']),
    companyDetails: [
      for (final line in (json['company_details'] as List? ?? const []))
        JsonReader.string(line),
    ],
    salesTaxNumber: JsonReader.string(json['sales_tax_number']),
    issueDate:
        DateTime.tryParse(JsonReader.string(json['issue_date'])) ??
        DateTime.fromMillisecondsSinceEpoch(0),
    invoiceNumber: JsonReader.string(json['invoice_number']),
    orderNumber: JsonReader.string(json['order_number']),
  );
}
