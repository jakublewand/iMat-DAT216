import 'package:flutter/material.dart';
import 'package:imat/app_theme.dart';
import 'package:imat/model/imat/product.dart';
import 'package:imat/model/imat_data_handler.dart';
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
              children: [
                Expanded(
                  child: Column(
                    children: [
                      CategoryFilter(),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(AppTheme.paddingMedium),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Text(
                              //   'Erbjudanden',
                              //   style: Theme.of(context).textTheme.headlineMedium,
                              // ),
                              // SizedBox(height: AppTheme.paddingMedium),
                              // ProductGrid(
                              //   products: products.take(8).toList(),
                              // ),
                              // SizedBox(height: AppTheme.paddingLarge),
                              Text(
                                'Produkter',
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                              SizedBox(height: AppTheme.paddingMedium),
                              ProductGrid(
                                products: products.toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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
