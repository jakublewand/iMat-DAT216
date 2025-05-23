import 'package:flutter/material.dart';
import 'package:imat/app_theme.dart';
import 'package:imat/model/imat/product.dart';
import 'package:imat/model/imat_data_handler.dart';
import 'package:provider/provider.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    var iMat = context.watch<ImatDataHandler>();
    var products = iMat.selectProducts;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildAppBar(context),
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
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                              SizedBox(height: AppTheme.paddingMedium),
                              _buildProductGrid(context, products.take(8).toList()),
                              SizedBox(height: AppTheme.paddingLarge),
                              Text(
                                'Produkter',
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                              SizedBox(height: AppTheme.paddingMedium),
                              _buildProductGrid(context, products.skip(8).take(8).toList()),
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

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            'IMat',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: AppTheme.paddingLarge),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Sök',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
                onChanged: (value) {
                  if (value.isEmpty) {
                    context.read<ImatDataHandler>().selectAllProducts();
                  } else {
                    var searchResults = context.read<ImatDataHandler>().findProducts(value);
                    context.read<ImatDataHandler>().selectSelection(searchResults);
                  }
                },
              ),
            ),
          ),
          SizedBox(width: AppTheme.paddingLarge),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {},
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

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: AppTheme.paddingMedium,
        horizontal: AppTheme.paddingLarge,
      ),
      child: Wrap(
        spacing: AppTheme.paddingSmall,
        runSpacing: AppTheme.paddingSmall,
        children: categories.map((category) {
          return FilterChip(
            label: Text(category.key),
            selected: context.watch<ImatDataHandler>().selectProducts == 
                     (category.value == null ? 
                      context.read<ImatDataHandler>().products : 
                      context.read<ImatDataHandler>().findProductsByCategory(category.value!)),
            onSelected: (bool selected) {
              if (selected) {
                if (category.value == null) {
                  context.read<ImatDataHandler>().selectAllProducts();
                } else {
                  var categoryProducts = context.read<ImatDataHandler>().findProductsByCategory(category.value!);
                  context.read<ImatDataHandler>().selectSelection(categoryProducts);
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
                          child: Icon(
                            Icons.eco,
                            color: Colors.white,
                            size: 16,
                          ),
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
                          onPressed: () {},
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
    return Container(
      width: 300,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(AppTheme.paddingMedium),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
            ),
            child: Text(
              'Varukorg',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
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
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppTheme.paddingMedium),
            child: ElevatedButton(
              onPressed: () {},
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
