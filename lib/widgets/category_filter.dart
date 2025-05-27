import 'package:flutter/material.dart';
import 'package:imat/app_theme.dart';
import 'package:imat/model/imat/product.dart';
import 'package:imat/model/imat_data_handler.dart';
import 'package:provider/provider.dart';

class CategoryFilter extends StatelessWidget {
  const CategoryFilter({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      MapEntry('Alla kategorier', null),
      MapEntry('Exotiska Frukter', ProductCategory.EXOTIC_FRUIT),
      MapEntry('Citrusfrukter', ProductCategory.CITRUS_FRUIT),
      MapEntry('Bär', ProductCategory.BERRY),
      MapEntry('Bröd', ProductCategory.BREAD),
      MapEntry('Kål', ProductCategory.CABBAGE),
      MapEntry('Kalla Drycker', ProductCategory.COLD_DRINKS),
      MapEntry('Mejeri', ProductCategory.DAIRIES),
      MapEntry('Frukter', ProductCategory.FRUIT),
    ];

    final iMatDataHandler = context.watch<ImatDataHandler>();
    final currentCategory = iMatDataHandler.currentCategoryFilter?.category;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: AppTheme.paddingMedium,
        horizontal: AppTheme.paddingLarge,
      ),
      child: Wrap(
        spacing: AppTheme.paddingSmall,
        runSpacing: AppTheme.paddingSmall,
        children: categories.map((category) {
          return FilterChip(
            label: Text(category.key),
            selected: currentCategory == category.value,
            onSelected: (bool selected) {
              if (selected) {
                if (category.value == null) {
                  context.read<ImatDataHandler>().selectAllProducts();
                } else {
                  context.read<ImatDataHandler>().selectCategory(category.value!);
                }
              }
            },
          );
        }).toList(),
      ),
    );
  }
} 