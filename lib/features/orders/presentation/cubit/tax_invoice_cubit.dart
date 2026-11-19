import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/tax_invoice.dart';
import '../../domain/usecases/orders_use_cases.dart';

enum TaxInvoiceStatus { loading, ready, failed }

class TaxInvoiceState extends Equatable {
  const TaxInvoiceState({this.status = TaxInvoiceStatus.loading, this.invoice});

  final TaxInvoiceStatus status;
  final TaxInvoice? invoice;

  @override
  List<Object?> get props => [status, invoice];
}

class TaxInvoiceCubit extends Cubit<TaxInvoiceState> {
  TaxInvoiceCubit({required this.orderId, required GetTaxInvoice getInvoice})
    : _getInvoice = getInvoice,
      super(const TaxInvoiceState());

  final String orderId;
  final GetTaxInvoice _getInvoice;

  Future<void> load() async {
    emit(const TaxInvoiceState());
    final result = await _getInvoice(orderId);
    if (isClosed) return;
    result.when(
      success: (invoice) => emit(
        TaxInvoiceState(status: TaxInvoiceStatus.ready, invoice: invoice),
      ),
      failure: (_) =>
          emit(const TaxInvoiceState(status: TaxInvoiceStatus.failed)),
    );
  }
}
