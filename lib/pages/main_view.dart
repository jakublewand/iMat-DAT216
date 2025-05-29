import 'package:flutter/material.dart';
import 'package:imat/app_theme.dart';
import 'package:imat/model/imat/product.dart';
import 'package:imat/model/imat_data_handler.dart';
import 'package:imat/model/product_filter.dart';
import 'package:imat/widgets/category_filter.dart';
import 'package:imat/widgets/page_scaffold.dart';
import 'package:imat/widgets/product_grid.dart';
import 'package:imat/widgets/shopping_cart.dart';
import 'package:imat/widgets/welcome_header.dart';
import 'package:provider/provider.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    var iMat = context.watch<ImatDataHandler>();
    var products = iMat.selectProducts;

    return PageScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WelcomeHeader(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [MainContent(products: products), ShoppingCart()],
            ),
          ),
        ],
      ),
    );
  }
}

class MainContent extends StatelessWidget {
  const MainContent({super.key, required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    var iMat = context.watch<ImatDataHandler>();
    var selectedCategoryName =
        categoryBuckets.entries
            .firstWhere(
              (bucket) =>
                  bucket.value.contains(iMat.activeCategories.firstOrNull),
            )
            .key;

    if (selectedCategoryName == "Alla kategorier") {
      selectedCategoryName = "Produkter";
    }

    return Expanded(
      child: Column(
        children: [
          CategoryFilterBar(),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.all(AppTheme.paddingMedium),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          iMat.isSearchActive
                              ? 'Sökresultat'
                              : (iMat.activeFilters.any(
                                    (filter) => filter is FavoritesFilter,
                                  )
                                  ? 'Favoriter'
                                  : selectedCategoryName),
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        SizedBox(height: AppTheme.paddingMedium),
                      ],
                    ),
                  ),
                ),
                ProductGrid(products: products),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
