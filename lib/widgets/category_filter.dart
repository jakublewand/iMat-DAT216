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
        ProductCategory.MELONS,
      ],
      'Mejeri': [ProductCategory.DAIRIES],
      'Dricka': [ProductCategory.COLD_DRINKS, ProductCategory.HOT_DRINKS],
      'Grönsaker': [
        ProductCategory.VEGETABLE_FRUIT,
        ProductCategory.ROOT_VEGETABLE,
        ProductCategory.CABBAGE,
        ProductCategory.POD,
      ],
      'Kött & fisk': [ProductCategory.MEAT, ProductCategory.FISH],
      'Skafferi': [
        ProductCategory.BREAD,
        ProductCategory.PASTA,
        ProductCategory.POTATO_RICE,
        ProductCategory.NUTS_AND_SEEDS,
        ProductCategory.FLOUR_SUGAR_SALT
      ],
      'Örter': [ProductCategory.HERB],
      'Sötsaker': [ProductCategory.SWEET],
    };

    final iMatDataHandler = context.watch<ImatDataHandler>();
    final isSearchActive = iMatDataHandler.isSearchActive;

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
            children:
                categoryBuckets.entries.map((bucket) {
                  final isSelected =
                      isSearchActive
                          ? bucket.key ==
                              'Alla kategorier' // When search is active, only "Alla kategorier" appears selected
                          : bucket.value.contains(null)
                          ? iMatDataHandler
                              .activeCategories
                              .isEmpty // "Alla kategorier" is selected when no categories are active
                          : iMatDataHandler.areCategoriesActive(
                            bucket.value.whereType<ProductCategory>().toList(),
                          );

                  return FilterChip(
                    label: Text(bucket.key),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      if (selected) {
                        if (bucket.value.contains(null)) {
                          context.read<ImatDataHandler>().selectAllProducts();
                        } else {
                          // Select all categories in the bucket
                          final categories =
                              bucket.value
                                  .whereType<ProductCategory>()
                                  .toList();
                          context.read<ImatDataHandler>().selectCategories(
                            categories,
                          );
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
