import 'package:imat/app_theme.dart';
import 'package:imat/model/imat/product.dart';
import 'package:imat/model/imat/product_detail.dart';
import 'package:imat/model/imat/shopping_item.dart';
import 'package:imat/model/imat_data_handler.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductLightbox extends StatelessWidget {
  const ProductLightbox({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    var iMat = Provider.of<ImatDataHandler>(context, listen: false);
    ProductDetail? detail = iMat.getDetail(product);

    return Container(
      padding: EdgeInsets.all(AppTheme.paddingMedium),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _header(context),
          SizedBox(height: AppTheme.paddingMedium),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Product image
                  SizedBox(
                    width: double.infinity,
                    height: 300,
                    child: iMat.getImage(product),
                  ),
                  SizedBox(height: AppTheme.paddingMedium),

                  // Product name
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppTheme.paddingSmall),

                  // Product price
                  Text(
                    '${product.price} ${product.unit}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),

                  // Product brand and description
                  if (detail != null) ...[
                    SizedBox(height: AppTheme.paddingSmall),
                    Text(
                      detail.brand,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppTheme.paddingSmall),
                    Text(
                      detail.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  SizedBox(height: AppTheme.paddingLarge),
                  _flowButtons(context, iMat),
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
        Text(
          'Produktdetaljer',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _flowButtons(BuildContext context, ImatDataHandler iMat) {
    bool isFavorite = iMat.isFavorite(product);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            iMat.toggleFavorite(product);
            Navigator.pop(context);
          },
          icon: Icon(
            isFavorite ? Icons.star : Icons.star_border,
            color: Colors.orange,
          ),
          label: Text(isFavorite ? 'Ta bort favorit' : 'Lägg till favorit'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            iMat.shoppingCartAdd(ShoppingItem(product));
            Navigator.pop(context);
          },
          icon: Icon(Icons.shopping_cart),
          label: Text('Lägg i kundvagn'),
        ),
      ],
    );
  }

  // Static method to show the lightbox
  static void show(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return ProductLightbox(product: product);
      },
    );
  }
}
