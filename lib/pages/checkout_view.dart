import 'package:imat/app_theme.dart';
import 'package:imat/pages/checkout_success_view.dart';
import 'package:imat/widgets/app_navbar.dart';
import 'package:flutter/material.dart';

class CheckoutView extends StatelessWidget {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          child: Column(
            children: [
              AppNavbar(),
              SizedBox(height: AppTheme.paddingLarge),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Kassa',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      SizedBox(height: AppTheme.paddingMedium),
                      Text(
                        'Placeholder för kassan',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      SizedBox(height: AppTheme.paddingLarge),
                      _flowButtons(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _flowButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Fortsätt handla'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CheckoutSuccessView()),
            );
          },
          child: Text('Slutför köp'),
        ),
      ],
    );
  }
} 