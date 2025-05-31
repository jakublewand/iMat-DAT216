import 'package:imat/app_theme.dart';
import 'package:imat/model/imat/order.dart';
import 'package:imat/model/imat_data_handler.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:imat/widgets/page_scaffold.dart';

// Stateful eftersom man behöver komma ihåg vilken order som är vald
// När den valda ordern ändras så ritas gränssnittet om pga
// anropet till setState
class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  Order? _selectedOrder;

  @override
  Widget build(BuildContext context) {
    // Provider.of eftersom denna vy inte behöver veta något om
    // ändringar i iMats data. Den visar bara det som finns nu
    var iMat = Provider.of<ImatDataHandler>(context, listen: false);

    // Hämta datan som ska visas
    var orders = iMat.orders;

    return PageScaffold(
      child: Column(
        children: [
          SizedBox(height: AppTheme.paddingLarge),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 300,
                  //height: 600,
                  // Creates the list to the left.
                  // When a user taps on an item the function _selectOrder is called
                  // The Material widget is need to make hovering pliancy effects visible
                  child: Material(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: _ordersList(context, orders, _selectOrder),
                  ),
                ),
                // Creates the view to the right showing the
                // currently selected order.
                Expanded(child: _orderDetails(_selectedOrder)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderInfo(Order order, Function onTap) {
    return Column(
      children: [
        ListTile(
          onTap: () => onTap(order),
          title: Text('Order ${order.orderNumber}, ${_formatDateTime(order.date)}'),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: Colors.black,
        ),
      ],
    );
  }

  Widget _ordersList(BuildContext context, List<Order> orders, Function onTap) {
    final sortedOrders = List<Order>.from(orders)
      ..sort((a, b) => b.date.compareTo(a.date));  

    return ListView.builder(
      itemCount: sortedOrders.length,
      itemBuilder: (context, index) {
        return _orderInfo(sortedOrders[index], onTap);
      },
    );
}

  _selectOrder(Order order) {
    setState(() {
      //dbugPrint('select order ${order.orderNumber}');
      _selectedOrder = order;
    });
  }

  // This uses the package intl
  String _formatDateTime(DateTime dt) {
    final formatter = DateFormat('yyyy-MM-dd, HH:mm');
    return formatter.format(dt);
  }

  // THe view to the right.
  // When the history is shown the first time
  // order will be null.
  // In the null case the function returns SizedBox.shrink()
  // which is a what to use to create an empty widget.
  Widget _orderDetails(Order? order) {
    if (order != null) {
      var iMat = Provider.of<ImatDataHandler>(context, listen: false);
      
      return Padding(
        padding: EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section - fixed at top
            Text(
              'Order ${order.orderNumber}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: AppTheme.paddingSmall),
            Text(
              'Beställd: ${_formatDateTime(order.date)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: AppTheme.paddingMedium),
            Text(
              'Produkter:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: AppTheme.paddingSmall),
            
            // Scrollable items section
            Expanded(
              child: ListView.builder(
                itemCount: order.items.length,
                itemBuilder: (context, index) {
                  final item = order.items[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: AppTheme.paddingSmall),
                    child: Padding(
                      padding: EdgeInsets.all(AppTheme.paddingMedium),
                      child: Row(
                        children: [
                          // Product image
                          Container(
                            width: 60,
                            height: 60,
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
                          
                          // Product details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.name,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  item.product.priceString,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Antal: ${item.amount}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          
                          // Item total
                          Text(
                            item.totalString,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Total section - fixed at bottom
            Container(
              padding: EdgeInsets.symmetric(vertical: AppTheme.paddingMedium),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Totalt:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    order.getTotal().toStringAsFixed(2).replaceAll('.', ','),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: AppTheme.paddingMedium),
          Text(
            'Välj en beställning för att se detaljer',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
