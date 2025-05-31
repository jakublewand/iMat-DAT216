import 'package:flutter/material.dart';
import 'package:imat/app_theme.dart';
import 'package:imat/model/imat_data_handler.dart';
import 'package:imat/widgets/customer_details.dart';
import 'package:imat/widgets/shopping_cart.dart';
import 'package:imat/routes.dart';
import 'package:provider/provider.dart';
import 'package:imat/widgets/page_scaffold.dart';
import 'package:go_router/go_router.dart';

class CheckoutView extends StatelessWidget {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      backgroundColor: Colors.brown[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
              Text(
                'Ordersammanfattning',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
          SizedBox(height: AppTheme.paddingLarge),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Consumer<ImatDataHandler>(
                    builder: (context, iMat, child) {
                      final cart = iMat.getShoppingCart();
                      return ListView.builder(
                        itemCount: cart.items.length,
                        itemBuilder: (context, index) {
                          final item = cart.items[index];
                          return ShoppingCartItemCard(item: item);
                        },
                      );
                    },
                  ),
                ),
                SizedBox(width: AppTheme.paddingLarge),
                Expanded(
                  child: Column(
                    children: [
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(AppTheme.paddingMedium),
                          child: CustomerDetails(),
                        ),
                      ),
                      SizedBox(height: AppTheme.paddingMedium),
                      Consumer<ImatDataHandler>(
                        builder: (context, iMat, child) {
                          return ElevatedButton(
                            onPressed: () {
                              iMat.placeOrder();
                              context.go(AppRoutes.checkoutSuccess);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.secondaryColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: AppTheme.paddingMedium,
                                horizontal: AppTheme.paddingLarge,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Lägg beställning på (${iMat.shoppingCartTotal().toStringAsFixed(2).replaceAll('.', ',')} kr)',
                              style: TextStyle(fontSize: 16),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
