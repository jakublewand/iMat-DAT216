import 'package:imat/app_theme.dart';
import 'package:imat/widgets/app_navbar.dart';
import 'package:flutter/material.dart';
import 'package:imat/widgets/page_scaffold.dart';


class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

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
                    Text(
                      'Registrera konto',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: AppTheme.paddingMedium),
                    Text(
                      'Placeholder för registrering',
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
    );
  }

  Widget _flowButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {
            // Placeholder för registrering
          },
          child: Text('Registrera'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Redan medlem? Logga in'),
        ),
      ],
    );
  }
} 