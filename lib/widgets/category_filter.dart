import 'package:flutter/material.dart';
import 'package:imat/app_theme.dart';
import 'package:imat/model/imat/product.dart';
import 'package:imat/model/imat_data_handler.dart';
import 'package:imat/model/product_filter.dart';
import 'package:provider/provider.dart';

final categoryBuckets = {
  'Alla kategorier': <ProductCategory?>[null],
  'Favoriter': [ProductCategory.FAVORITE],
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
    ProductCategory.FLOUR_SUGAR_SALT,
  ],
  'Örter': [ProductCategory.HERB],
  'Sötsaker': [ProductCategory.SWEET],
};

class CategoryFilterBar extends StatelessWidget {
  const CategoryFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Mapping from display names to lists of ProductCategory enum values

    final iMatDataHandler = context.watch<ImatDataHandler>();
    final isSearchActive = iMatDataHandler.isSearchActive;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: AppTheme.paddingMedium,
        horizontal: AppTheme.paddingLarge,
      ),
      child: Wrap(
        spacing: AppTheme.paddingSmall,
        runSpacing: AppTheme.paddingSmall,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('Filtrera på:'),
          ...categoryBuckets.entries.map((bucket) {
            var isSelected = iMatDataHandler.areCategoriesActive(
              bucket.value.whereType<ProductCategory>().toList(),
            );
            // Super ugly but works
            if (bucket.key == 'Favoriter') {
              isSelected = iMatDataHandler.activeFilters.any(
                (filter) => filter is FavoritesFilter,
              );
            } else if (bucket.key == 'Alla kategorier') {
              if (!iMatDataHandler.activeFilters.any(
                    (filter) => filter is FavoritesFilter,
                  ) &&
                  !isSearchActive) {
                isSelected = iMatDataHandler.activeCategories.isEmpty;
              }
            }

            return FilterChip(
              label: Text(bucket.key),
              selected: isSelected,
              onSelected: (bool selected) {
                if (selected) {
                  if (bucket.value.contains(null)) {
                    context.read<ImatDataHandler>().selectAllProducts();
                  } else if (bucket.value.contains(ProductCategory.FAVORITE)) {
                    context.read<ImatDataHandler>().selectFavorites();
                  } else {
                    // Select all categories in the bucket
                    final categories =
                        bucket.value.whereType<ProductCategory>().toList();
                    context.read<ImatDataHandler>().selectCategories(
                      categories,
                    );
                  }
                }
              },
            );
          }),
        ],
      ),
    );
  }
}
