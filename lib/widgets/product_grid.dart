import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    if (products.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Text(
            'Inga produkter hittades',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium),
      sliver: SliverGrid.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 300,
          mainAxisExtent: 280,
          crossAxisSpacing: AppTheme.paddingMedium,
          mainAxisSpacing: AppTheme.paddingMedium,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(product: product);
        },
      ),
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
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(AppTheme.paddingSmall),
                child: ProductText(product: product),
              ),
            ),
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
              ),
              ProductBadges(product: product),
            ],
          ),
          SizedBox(height: AppTheme.paddingSmall),
          Row(
            children: [
              Text(
                product.priceString,
                style: Theme.of(context).textTheme.bodyLarge,
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
  const AddToCartButton({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    var iMat = Provider.of<ImatDataHandler>(context, listen: true);

    if (iMat.getShoppingCart().items.any(
      (item) => item.product.productId == product.productId,
    )) {
      return SegmentedButton(
        style: ButtonStyle(
          visualDensity: VisualDensity(horizontal: -4),
          // Higher than normal height
          fixedSize: WidgetStateProperty.all(Size(double.infinity, 100)),
        ),
        segments: [
          ButtonSegment(value: "decrease", icon: Icon(Icons.remove)),
          ButtonSegment(
            value: "amount",
            label: Text(
              iMat
                  .getShoppingCart()
                  .items
                  .firstWhere(
                    (item) => item.product.productId == product.productId,
                  )
                  .amount
                  .toString(),
            ),
          ),
          ButtonSegment(value: "increase", icon: Icon(Icons.add)),
        ],
        selected: {},
        emptySelectionAllowed: true,
        onSelectionChanged: (value) {
          if (value.first == "decrease") {
            iMat.shoppingCartUpdate(
              iMat.getShoppingCart().items.firstWhere(
                (item) => item.product.productId == product.productId,
              ),
              delta: -1,
            );
          } else if (value.first == "increase") {
            iMat.shoppingCartUpdate(
              iMat.getShoppingCart().items.firstWhere(
                (item) => item.product.productId == product.productId,
              ),
              delta: 1,
            );
          } else if (value.first == "amount") {
            showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: Text('Antal'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Stäng'),
                      ),
                    ],
                    content: TextField(
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      maxLength: 2,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      onChanged:
                          (value) => iMat.shoppingCartUpdate(
                            iMat.getShoppingCart().items.firstWhere(
                              (item) =>
                                  item.product.productId == product.productId,
                            ),
                            delta: double.parse(value),
                            absolute: true,
                          ),
                    ),
                  ),
            );
          }
        },
      );
    }

    return ElevatedButton.icon(
      onPressed: () {
        iMat.shoppingCartAdd(ShoppingItem(product, amount: 1));
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

class ProductBadges extends StatelessWidget {
  const ProductBadges({super.key, required this.product});

  final Product product;
  @override
  Widget build(BuildContext context) {
    var iMat = Provider.of<ImatDataHandler>(context, listen: true);
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 100),
      child: Row(
        spacing: 8,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (product.isEcological) EcoIcon(),
          if (iMat.isFavorite(product)) FavoriteIcon(),
        ],
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

class FavoriteIcon extends StatelessWidget {
  const FavoriteIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Favorit',
      child: Container(
        padding: EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.deepOrangeAccent,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Icon(Icons.star, color: Colors.white, size: 14),
      ),
    );
  }
}
