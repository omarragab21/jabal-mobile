import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../home/domain/entities/product_category.dart';
import '../../domain/usecases/get_sections.dart';

enum SectionsStatus { loading, ready, failed }

class SectionsState extends Equatable {
  const SectionsState({
    this.status = SectionsStatus.loading,
    this.sections = const [],
    this.failure,
  });

  final SectionsStatus status;
  final List<ProductCategory> sections;
  final Failure? failure;

  @override
  List<Object?> get props => [status, sections, failure];
}

/// View model of the sections tab.
class SectionsCubit extends Cubit<SectionsState> {
  SectionsCubit(this._getSections) : super(const SectionsState());

  final GetSections _getSections;

  /// Loads the sections in [languageCode]; called on start and when the app
  /// language changes.
  Future<void> load(String languageCode) async {
    emit(const SectionsState());
    final result = await _getSections(languageCode);
    if (isClosed) return;
    result.when(
      success: (sections) =>
          emit(SectionsState(status: SectionsStatus.ready, sections: sections)),
      failure: (failure) =>
          emit(SectionsState(status: SectionsStatus.failed, failure: failure)),
    );
  }
}
