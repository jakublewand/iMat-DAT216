import 'package:flutter/material.dart';
import 'package:imat/app_theme.dart';
import 'package:imat/model/imat/product.dart';
import 'package:imat/model/imat_data_handler.dart';
import 'package:imat/model/product_filter.dart';
import 'package:imat/widgets/category_filter.dart';
import 'package:imat/widgets/page_scaffold.dart';
import 'package:imat/widgets/product_grid.dart';
import 'package:imat/widgets/product_lightbox.dart';
import 'package:imat/widgets/shopping_cart.dart';
import 'package:imat/widgets/welcome_header.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:imat/routes.dart';

class MainView extends StatefulWidget {
  final int? selectedProductId;

  const MainView({super.key, this.selectedProductId});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  bool _lightboxShown = false;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    if (widget.selectedProductId != null) {
      _checkAndShowLightbox();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MainView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedProductId != widget.selectedProductId) {
      setState(() {
        _lightboxShown = false;
      });
      if (widget.selectedProductId != null) {
        _checkAndShowLightbox();
      }
    }
  }

  void _checkAndShowLightbox() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.selectedProductId == null) return;

      final iMat = Provider.of<ImatDataHandler>(context, listen: false);

      // Check if products are loaded (not empty)
      if (iMat.products.isEmpty) {
        // Products are still loading, wait for them
        return;
      }
      _showProductLightbox();
    });
  }

  void _showProductLightbox() {
    if (_lightboxShown || widget.selectedProductId == null) return;

    final iMat = Provider.of<ImatDataHandler>(context, listen: false);
    final product = iMat.getProduct(widget.selectedProductId!);

    if (product != null) {
      setState(() {
        _lightboxShown = true;
      });

      showModalBottomSheet(
        anchorPoint: const Offset(0, 0),
        context: context,
        constraints: const BoxConstraints(maxWidth: 1000),
        isScrollControlled: true,
        isDismissible: true,
        enableDrag: true,
        builder: (BuildContext modalContext) {
          return ProductLightbox(product: product);
        },
      ).then((_) {
        // När lightboxen stängs, gå tillbaka till hem
        if (mounted) {
          context.go(AppRoutes.home);
        }
      });
    } else {
      // Om produkten inte finns (efter att produkter har laddats), gå till hem
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go(AppRoutes.home);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ImatDataHandler>(
      builder: (context, iMat, child) {
        var products = iMat.selectProducts;

        // If products are still loading and we have a selected product, show loading indicator
        if (iMat.products.isEmpty && widget.selectedProductId != null) {
          return Scaffold(
            body: Stack(
              children: [
                _buildMainContent(products),
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ],
            ),
          );
        }

        // Products are loaded, check if we need to show lightbox
        if (widget.selectedProductId != null && !_lightboxShown) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showProductLightbox();
          });
        }

        return _buildMainContent(products);
      },
    );
  }

  Widget _buildMainContent(List<Product> products) {
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
