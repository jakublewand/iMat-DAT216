import 'package:flutter/material.dart';
import 'package:imat/app_theme.dart';
import 'package:imat/model/imat/product.dart';
import 'package:imat/model/imat_data_handler.dart';
import 'package:imat/model/imat/shopping_item.dart';
import 'package:imat/widgets/product_lightbox.dart';
import 'package:provider/provider.dart';

class ProductGrid extends StatelessWidget {
  final List<Product> products;

  const ProductGrid({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        mainAxisExtent: 328,
        crossAxisSpacing: AppTheme.paddingMedium,
        mainAxisSpacing: AppTheme.paddingMedium,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(product: product);
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      child: InkWell(
        onTap: () {
          ProductLightbox.show(context, product);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 3, child: ProductImage(product: product)),
            Expanded(flex: 2, child: ProductText(product: product)),
          ],
        ),
      ),
    );
  }
}

class ProductText extends StatelessWidget {
  const ProductText({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppTheme.paddingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Spacer(),
          Row(
            spacing: 8,
            children: [
              Text(
                product.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (product.isEcological) EcoIcon(),
            ],
          ),
          SizedBox(height: AppTheme.paddingTiny),
          Text(
            '${product.price} kr per ${product.unit}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          SizedBox(height: AppTheme.paddingSmall),
          Row(
            children: [
              Text(
                '${product.price} kr',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Spacer(),
              AddToCartButton(product: product),
            ],
          ),
        ],
      ),
    );
  }
}

class AddToCartButton extends StatelessWidget {
  const AddToCartButton({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        context.read<ImatDataHandler>().shoppingCartAdd(
          ShoppingItem(product, amount: 1),
        );
      },
      icon: Icon(Icons.add),
      label: Text('Köp'),
      style: ElevatedButton.styleFrom(
        fixedSize: Size(double.infinity, 40),
        backgroundColor: AppTheme.secondaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class ProductImage extends StatelessWidget {
  const ProductImage({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Consumer<ImatDataHandler>(
        builder: (context, dataHandler, child) {
          return dataHandler.getImage(product);
        },
      ),
    );
  }
}

class EcoIcon extends StatelessWidget {
  const EcoIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Ekologisk produkt',
      child: Container(
        padding: EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Icon(Icons.eco, color: Colors.white, size: 14),
      ),
    );
  }
}
