import 'package:imat/app_theme.dart';
import 'package:imat/widgets/app_navbar.dart';
import 'package:imat/widgets/card_details.dart';
import 'package:imat/widgets/customer_details.dart';
import 'package:flutter/material.dart';
import 'package:imat/widgets/page_scaffold.dart';

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppTheme.paddingMedium),
            _customerDetails(context),
          ],
        ),
      ),
    );
  }

  Widget _customerDetails(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: CustomerDetails(),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Container(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: CardDetails(),
          ),
        ),
      ],
    );
  }
}
