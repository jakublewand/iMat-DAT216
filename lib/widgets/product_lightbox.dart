import 'package:imat/app_theme.dart';
import 'package:imat/model/imat/product.dart';
import 'package:imat/model/imat/product_detail.dart';
import 'package:imat/model/imat_data_handler.dart';
import 'package:flutter/material.dart';
import 'package:imat/widgets/product_grid.dart';
import 'package:provider/provider.dart';

class ProductLightbox extends StatelessWidget {
  const ProductLightbox({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    var iMat = Provider.of<ImatDataHandler>(context, listen: false);
    ProductDetail? detail = iMat.getDetail(product);

    return Container(
      padding: EdgeInsets.all(AppTheme.paddingHuge).copyWith(bottom: 0),
      width: 1000,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _header(context),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: AppTheme.paddingHuge),
              child: Column(
                children: [
                  // Product info section
                  _productInfoSection(context, detail),
                  SizedBox(height: AppTheme.paddingHuge),

                  // Similar products section
                  _similarProductsSection(context, iMat),
                  SizedBox(height: AppTheme.paddingHuge),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Spacer(),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _productInfoSection(BuildContext context, ProductDetail? detail) {
    var iMat = Provider.of<ImatDataHandler>(context, listen: true);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Product image on the left
          SizedBox(
            width: 440,
            height: 320,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: iMat.getImage(product),
            ),
          ),
          SizedBox(width: AppTheme.paddingHuge),
          // Product information on the right
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product price and unit
                Row(
                  children: [
                    Text(product.name, style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold)),
                    SizedBox(width: AppTheme.paddingSmall),
                    ProductBadges(product: product),
                  ],
                ),
                SizedBox(height: AppTheme.paddingSmall),
                Text(
                  '${product.price.toStringAsFixed(2)} ${product.unit}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: AppTheme.paddingSmall),
      
                // Product details if available
                if (detail != null) ...[
                  if (detail.description.isNotEmpty) ...[
                    Text(
                      detail.description,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: AppTheme.paddingSmall),
                  Text(
                    "Märke: ${detail.brand}",
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  SizedBox(height: AppTheme.paddingSmall),
                  Text(
                    "Innehåll: ${detail.contents}",
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  SizedBox(height: AppTheme.paddingSmall),
                  Text(
                    "Ursprung: ${detail.origin}",
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  Spacer(),
                  SizedBox(height: AppTheme.paddingSmall),
                  Row(
                    children: [
                      AddToCartButton(product: product),
                      SizedBox(width: AppTheme.paddingMedium),
                      OutlinedButton.icon(
                        onPressed: () {
                          iMat.toggleFavorite(product);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                        ),
                        icon: iMat.isFavorite(product)
                            ? Icon(Icons.star, color: Colors.amber[800])
                            : Icon(Icons.star_border, color: Colors.grey[600]),
                        label: iMat.isFavorite(product)
                            ? Text('Ta bort favorit')
                            : Text('Lägg till favorit'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _similarProductsSection(BuildContext context, ImatDataHandler iMat) {
    // Get 3 random products or first 3 products (excluding current product)
    final allProducts =
        iMat.products.where((p) => p.productId != product.productId).toList();
    final similarProducts = allProducts.take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Liknande produkter',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: AppTheme.paddingMedium),

        // Grid of similar products
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 3,
          mainAxisSpacing: AppTheme.paddingMedium,
          crossAxisSpacing: AppTheme.paddingMedium,
          children:
              similarProducts
                  .map((similarProduct) => ProductCard(product: similarProduct))
                  .toList(),
        ),
      ],
    );
  }

  // Static method to show the lightbox
  static void show(BuildContext context, Product product) {
    // Hide any open lightboxes
    Navigator.popUntil(context, (route) => route.isFirst);
    showModalBottomSheet(
      anchorPoint: Offset(0, 0),
      context: context,
      constraints: BoxConstraints(maxWidth: 1000),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return ProductLightbox(product: product);
      },
    );
  }
}
