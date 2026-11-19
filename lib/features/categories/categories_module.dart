import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../home/domain/entities/product_category.dart';
import '../home/domain/repositories/home_repository.dart';
import 'domain/usecases/get_sections.dart';
import 'presentation/cubit/sections_cubit.dart';
import 'presentation/pages/categories_page.dart';

/// Wires the sections tab. It reads the catalogue through the same
/// [HomeRepository] as the home page, so both show the same data.
class CategoriesModule {
  const CategoriesModule({required this.repository});

  final HomeRepository repository;

  Widget page({
    required ValueChanged<ProductCategory> onOpenSection,
    VoidCallback? onOpenSearch,
    VoidCallback? onBack,
  }) => BlocProvider(
    create: (_) => SectionsCubit(GetSections(repository)),
    child: SectionsPage(
      onOpenSection: onOpenSection,
      onOpenSearch: onOpenSearch,
      onBack: onBack,
    ),
  );
}
