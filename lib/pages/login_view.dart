import 'package:imat/app_theme.dart';
import 'package:imat/model/imat_data_handler.dart';
import 'package:imat/pages/signup_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:imat/widgets/page_scaffold.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

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
                      'Logga in',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: AppTheme.paddingMedium),
                    Text(
                      'Placeholder för inloggning',
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
    var iMat = Provider.of<ImatDataHandler>(context, listen: false);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {
            // Placeholder för riktigt login - simulerar inloggning
            iMat.login('testanvändare', 'lösenord');
            Navigator.pop(context);
          },
          child: Text('Logga in'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignUpView()),
            );
          },
          child: Text('Registrera'),
        ),
      ],
    );
  }
}
