import 'package:imat/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:imat/widgets/page_scaffold.dart';
import 'package:imat/routes.dart';
import 'package:go_router/go_router.dart';

class CheckoutSuccessView extends StatelessWidget {
  const CheckoutSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          children: [
            SizedBox(height: AppTheme.paddingLarge),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 80, color: Colors.green),
                    SizedBox(height: AppTheme.paddingMedium),
                    Text(
                      'Tack för ditt köp!',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: AppTheme.paddingMedium),
                    Text(
                      'Din beställning har mottagits och kommer att behandlas.',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
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
    );
  }

  Widget _flowButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {
            // Navigate back to main view
            context.go(AppRoutes.home);
          },
          style: ElevatedButton.styleFrom(
            elevation: 2,
            side: BorderSide(
              color: Colors.black,
              width: 1,
            ),
          ),
          child: Text('Fortsätt handla', style: TextStyle(color: Colors.black)),
        ),
        ElevatedButton(
          onPressed: () {
            context.go(AppRoutes.history);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.secondaryColor,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              vertical: AppTheme.paddingMedium,
              horizontal: AppTheme.paddingLarge,
            ),
          ),
          child: Text('Se orderhistorik'),
        ),
      ],
    );
  }
}
