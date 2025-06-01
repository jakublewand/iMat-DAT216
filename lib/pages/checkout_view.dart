import 'package:flutter/material.dart';
import 'package:imat/app_theme.dart';
import 'package:imat/model/imat_data_handler.dart';
import 'package:imat/widgets/customer_details.dart';
import 'package:imat/widgets/card_details.dart';
import 'package:imat/widgets/shopping_cart.dart';
import 'package:imat/widgets/custom_components.dart';
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
                onPressed: () => context.go(AppRoutes.home),
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
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Leveransuppgifter
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(AppTheme.paddingMedium),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.local_shipping,
                                        color: AppTheme.secondaryColor,
                                        size: 20,
                                      ),
                                    ),
                                    SizedBox(width: AppTheme.paddingMedium),
                                    Text(
                                      'Leveransuppgifter',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.secondaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: AppTheme.paddingMedium),
                                CustomerDetails(
                                  showSaveButton: false,
                                  enableEmailEditing: false,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: AppTheme.paddingMedium),
                        // Betalningsuppgifter
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(AppTheme.paddingMedium),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.credit_card,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    SizedBox(width: AppTheme.paddingMedium),
                                    Text(
                                      'Betalningsuppgifter',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.secondaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: AppTheme.paddingMedium),
                                CardDetails(showSaveButton: false),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: AppTheme.paddingMedium),
                        // Beställningsknapp
                        Consumer<ImatDataHandler>(
                          builder: (context, iMat, child) {
                            return CustomButton(
                              text: 'Lägg beställning (${iMat.shoppingCartTotal().toStringAsFixed(2).replaceAll('.', ',')} kr)',
                              icon: Icons.shopping_cart_checkout,
                              onPressed: () {
                                iMat.placeOrder();
                                context.replace(AppRoutes.checkoutSuccess);
                              },
                              width: double.infinity,
                              backgroundColor: AppTheme.secondaryColor,
                            );
                          },
                        ),
                      ],
                    ),
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
