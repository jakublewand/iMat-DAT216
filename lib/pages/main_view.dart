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

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ImatDataHandler>(
      builder: (context, iMat, child) {
        var products = iMat.selectProducts;
        
        return PageScaffold(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WelcomeHeader(),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MainContent(
                      products: products,
                      scrollController: _scrollController,
                    ), 
                    ShoppingCart(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class MainContent extends StatefulWidget {
  const MainContent({
    super.key, 
    required this.products,
    required this.scrollController,
  });

  final List<Product> products;
  final ScrollController scrollController;

  @override
  State<MainContent> createState() => _MainContentState();
}

class _MainContentState extends State<MainContent> 
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required when using AutomaticKeepAliveClientMixin
    
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
              key: const PageStorageKey<String>('main_scroll'),
              controller: widget.scrollController,
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
                ProductGrid(products: widget.products),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
