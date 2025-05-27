import 'package:flutter/material.dart';
import 'package:imat/app_theme.dart';
import 'package:imat/model/imat_data_handler.dart';
import 'package:imat/pages/checkout_success_view.dart';
import 'package:imat/widgets/customer_details.dart';
import 'package:provider/provider.dart';
import 'package:imat/widgets/page_scaffold.dart';

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
                onPressed: () => Navigator.pop(context),
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
                  flex: 2,
                  child: Consumer<ImatDataHandler>(
                    builder: (context, iMat, child) {
                      final cart = iMat.getShoppingCart();
                      return ListView.builder(
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
                                    color: Colors.grey[200],
                                    child: iMat.getImage(item.product),
                                  ),
                                  SizedBox(width: AppTheme.paddingMedium),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.product.name,
                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.titleMedium,
                                        ),
                                        Text(
                                          '${item.product.price} kr/${item.product.unit}',
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.remove),
                                        onPressed:
                                            () => iMat.shoppingCartUpdate(
                                              item,
                                              delta: -1,
                                            ),
                                      ),
                                      SizedBox(
                                        width: 40,
                                        child: Text(
                                          '${item.amount}',
                                          textAlign: TextAlign.center,
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
                                ],
                              ),
                            ),
                          );
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
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CheckoutSuccessView(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.brown,
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
                              'Lägg beställning på (${iMat.shoppingCartTotal()} kr)',
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
