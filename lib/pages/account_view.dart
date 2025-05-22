import 'package:imat/app_theme.dart';
import 'package:imat/widgets/card_details.dart';
import 'package:imat/widgets/customer_details.dart';
import 'package:flutter/material.dart';

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          child: Column(
            children: [
              _header(context),
              SizedBox(height: AppTheme.paddingMedium),
              _customerDetails(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text('iMat'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Tillbaka'),
        ),
      ],
    );
  }

  Widget _customerDetails() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            color: Color.fromARGB(255, 154, 172, 134),
            child: CustomerDetails(),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Container(
            color: Color.fromARGB(255, 154, 172, 134),
            child: CardDetails(),
          ),
        ),
      ],
    );
  }
}
