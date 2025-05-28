import 'package:flutter/material.dart';
import 'package:imat/app_theme.dart';
import 'package:imat/model/imat/product.dart';
import 'package:imat/model/imat_data_handler.dart';
import 'package:provider/provider.dart';

class CategoryFilter extends StatelessWidget {
  const CategoryFilter({super.key});

  @override
  Widget build(BuildContext context) {
    // Mapping from display names to lists of ProductCategory enum values
    final categoryBuckets = {
      'Alla kategorier': <ProductCategory?>[null],
      'Bär': [ProductCategory.BERRY],
      'Frukter': [
        ProductCategory.FRUIT, 
        ProductCategory.CITRUS_FRUIT, 
        ProductCategory.EXOTIC_FRUIT, 
        ProductCategory.MELONS
      ],
      'Mejeri': [ProductCategory.DAIRIES],
      'Dricka': [ProductCategory.COLD_DRINKS, ProductCategory.HOT_DRINKS],
      'Grönsaker': [
        ProductCategory.VEGETABLE_FRUIT, 
        ProductCategory.ROOT_VEGETABLE, 
        ProductCategory.CABBAGE, 
        ProductCategory.POD
      ],
      'Kött': [ProductCategory.MEAT, ProductCategory.FISH],
      'Bakning': [
        ProductCategory.BREAD, 
        ProductCategory.FLOUR_SUGAR_SALT, 
        ProductCategory.PASTA, 
        ProductCategory.POTATO_RICE
      ],
      'Örter': [ProductCategory.HERB],
      'Nötter och frön': [ProductCategory.NUTS_AND_SEEDS],
      'Övrigt': [ProductCategory.SWEET],
    };

    final iMatDataHandler = context.watch<ImatDataHandler>();
    final currentCategory = iMatDataHandler.currentCategoryFilter?.category;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: AppTheme.paddingMedium,
        horizontal: AppTheme.paddingLarge,
      ),
      child: Row(
        spacing: AppTheme.paddingMedium,
        children: [
          Text('Filtrera på:'),
          Wrap(
            spacing: AppTheme.paddingSmall,
            runSpacing: AppTheme.paddingSmall,
            children: categoryBuckets.entries.map((bucket) {
              final isSelected = bucket.value.contains(null) 
                  ? currentCategory == null
                  : bucket.value.contains(currentCategory);
              
              return FilterChip(
                label: Text(bucket.key),
                selected: isSelected,
                onSelected: (bool selected) {
                  if (selected) {
                    if (bucket.value.contains(null)) {
                      context.read<ImatDataHandler>().selectAllProducts();
                    } else {
                      // For now, select the first category in the bucket
                      // This might need to be updated based on how your data handler works
                      context.read<ImatDataHandler>().selectCategory(bucket.value.first!);
                    }
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
} 