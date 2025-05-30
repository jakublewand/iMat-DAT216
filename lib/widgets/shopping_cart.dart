import 'package:flutter/material.dart';
import 'package:imat/app_theme.dart';
import 'package:imat/model/imat/shopping_item.dart';
import 'package:imat/model/imat_data_handler.dart';
import 'package:imat/widgets/product_grid.dart';
import 'package:imat/routes.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';

class ShoppingCart extends StatelessWidget {
  const ShoppingCart({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final minWidth = max(350.0, screenWidth * 0.25);
    var iMat = Provider.of<ImatDataHandler>(context, listen: true);
    return Container(
      width: minWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(AppTheme.paddingMedium),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
            child: Row(
              children: [
                Text('Varukorg', style: Theme.of(context).textTheme.titleLarge),
                Spacer(),
                IconButton(
                  tooltip: 'Töm varukorg',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: Text('Töm varukorg'),
                            content: Text(
                              'Är du säker på att du vill tömma varukorgen?',
                            ),
                            actions: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  context
                                      .read<ImatDataHandler>()
                                      .shoppingCartClear();
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'Ja',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'Avbryt',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                    );
                  },
                  icon: Icon(Icons.delete),
                ),
              ],
            ),
          ),
          Consumer<ImatDataHandler>(
            builder: (context, iMat, child) {
              final cart = iMat.getShoppingCart();
              if (cart.items.isEmpty) {
                return Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: AppTheme.paddingMedium),
                        Text(
                          'Inga varor i varukorgen än!',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Expanded(
                child: ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return ShoppingCartItemCard(item: item);
                  },
                ),
              );
            },
          ),
          Container(
            padding: EdgeInsets.all(AppTheme.paddingMedium),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Totalt:', style: Theme.of(context).textTheme.titleMedium),
                Text(
                  '${iMat.shoppingCartTotal().toStringAsFixed(2).replaceAll('.', ',')} kr',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppTheme.paddingMedium),
            child: Consumer<ImatDataHandler>(
              builder: (context, iMat, child) {
                return ElevatedButton(
                  onPressed: iMat.shoppingCartTotal() > 0 ? () {
                    context.push(AppRoutes.checkout);
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Till kassan'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ShoppingCartItemCard extends StatelessWidget {
  const ShoppingCartItemCard({super.key, required this.item});

  final ShoppingItem item;

  @override
  Widget build(BuildContext context) {
    var iMat = Provider.of<ImatDataHandler>(context, listen: true);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.paddingMedium),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: iMat.getImage(item.product),
              ),
            ),
            SizedBox(width: AppTheme.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    item.totalString,
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Tooltip(
                  message: 'Ta bort',
                  child: IconButton(
                    icon: Icon(Icons.delete, color: Colors.grey[600]),
                    onPressed: () => iMat.shoppingCartRemove(item),
                  ),
                ),
                SizedBox(width: AppTheme.paddingTiny),
                AddToCartButton(product: item.product),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
