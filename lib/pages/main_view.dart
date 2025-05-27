import 'package:flutter/material.dart';
import 'package:imat/app_theme.dart';
import 'package:imat/model/imat/product.dart';
import 'package:imat/model/imat_data_handler.dart';
import 'package:imat/model/product_filter.dart';
import 'package:provider/provider.dart';
import 'package:imat/model/imat/shopping_item.dart';
import 'dart:math';
import 'package:imat/pages/checkout_view.dart';
import 'package:imat/widgets/page_scaffold.dart';

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
          _buildWelcomeHeader(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildCategories(context),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(AppTheme.paddingMedium),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Erbjudanden',
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                              SizedBox(height: AppTheme.paddingMedium),
                              _buildProductGrid(
                                context,
                                products.take(8).toList(),
                              ),
                              SizedBox(height: AppTheme.paddingLarge),
                              Text(
                                'Produkter',
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                              SizedBox(height: AppTheme.paddingMedium),
                              _buildProductGrid(
                                context,
                                products.skip(8).take(8).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildCart(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      padding: EdgeInsets.all(AppTheme.paddingLarge),
      color: AppTheme.colorScheme.primary,
      child: Text(
        'Välkommen Kerstin!',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    final categories = [
      MapEntry('Alla kategorier', null),
      MapEntry('Exotiska Frukter', ProductCategory.EXOTIC_FRUIT),
      MapEntry('Citrusfrukter', ProductCategory.CITRUS_FRUIT),
      MapEntry('Bär', ProductCategory.BERRY),
      MapEntry('Bröd', ProductCategory.BREAD),
      MapEntry('Kål', ProductCategory.CABBAGE),
      MapEntry('Kalla Drycker', ProductCategory.COLD_DRINKS),
      MapEntry('Mejeri', ProductCategory.DAIRIES),
      MapEntry('Frukter', ProductCategory.FRUIT),
    ];

    final iMatDataHandler = context.watch<ImatDataHandler>();
    final currentCategory = iMatDataHandler.currentCategoryFilter?.category;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: AppTheme.paddingMedium,
        horizontal: AppTheme.paddingLarge,
      ),
      child: Wrap(
        spacing: AppTheme.paddingSmall,
        runSpacing: AppTheme.paddingSmall,
        children:
            categories.map((category) {
              return FilterChip(
                label: Text(category.key),
                selected: currentCategory == category.value,
                onSelected: (bool selected) {
                  if (selected) {
                    if (category.value == null) {
                      context.read<ImatDataHandler>().selectAllProducts();
                    } else {
                      context.read<ImatDataHandler>().selectCategory(category.value!);
                    }
                  }
                },
              );
            }).toList(),
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context, List<Product> products) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.8,
        crossAxisSpacing: AppTheme.paddingMedium,
        mainAxisSpacing: AppTheme.paddingMedium,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    context.read<ImatDataHandler>().getImage(product),
                    if (product.isEcological)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(Icons.eco, color: Colors.white, size: 16),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(AppTheme.paddingSmall),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
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
                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<ImatDataHandler>().shoppingCartAdd(
                              ShoppingItem(product, amount: 1),
                            );
                          },
                          icon: Icon(Icons.add),
                          label: Text('Köp'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.colorScheme.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCart(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final minWidth = max(350.0, screenWidth * 0.25);

    return Container(
      width: minWidth,
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Colors.grey[300]!, width: 1)),
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
            child: Text(
              'Varukorg',
              style: Theme.of(context).textTheme.titleLarge,
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
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(
                                    '${item.total.toStringAsFixed(2)} kr',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red[300],
                                  ),
                                  onPressed:
                                      () => iMat.shoppingCartRemove(item),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.remove),
                                        onPressed:
                                            () => iMat.shoppingCartUpdate(
                                              item,
                                              delta: -1,
                                            ),
                                      ),
                                      Container(
                                        width: 40,
                                        height: 40,
                                        alignment: Alignment.center,
                                        child: Text(
                                          item.amount.toString(),
                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.titleMedium,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.add),
                                        onPressed:
                                            () => iMat.shoppingCartUpdate(
                                              item,
                                              delta: 1,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
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
                Text('Total:', style: Theme.of(context).textTheme.titleMedium),
                Consumer<ImatDataHandler>(
                  builder: (context, iMat, child) {
                    return Text(
                      '${iMat.shoppingCartTotal().toStringAsFixed(2)} kr',
                      style: Theme.of(context).textTheme.titleMedium,
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppTheme.paddingMedium),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CheckoutView()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: AppTheme.paddingMedium),
              ),
              child: Text('Till kassan'),
            ),
          ),
        ],
      ),
    );
  }
}
