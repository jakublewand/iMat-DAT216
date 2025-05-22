import 'package:imat/app_theme.dart';
import 'package:flutter/material.dart';

class CheckoutSuccessView extends StatelessWidget {
  const CheckoutSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          child: Column(
            children: [
              _header(context),
              SizedBox(height: AppTheme.paddingLarge),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 80,
                        color: Colors.green,
                      ),
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

  Widget _flowButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {
            // Navigate back to main view - we'll pop all the way back
            Navigator.popUntil(context, (route) => route.isFirst);
          },
          child: Text('Fortsätt handla'),
        ),
        ElevatedButton(
          onPressed: () {
            // Navigate to history/orders view (you may need to adjust this)
            Navigator.popUntil(context, (route) => route.isFirst);
          },
          child: Text('Se beställningar'),
        ),
      ],
    );
  }
} 