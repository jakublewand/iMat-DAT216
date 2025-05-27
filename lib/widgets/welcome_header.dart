import 'package:flutter/material.dart';
import 'package:imat/app_theme.dart';
import 'package:imat/model/imat_data_handler.dart';
import 'package:provider/provider.dart';

class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    var name = context.read<ImatDataHandler>().getCustomer().firstName;
    return Container(
      padding: EdgeInsets.all(AppTheme.paddingHuge),
      color: AppTheme.accentColor,
      child: Text(
        name.isEmpty ? 'Välkommen!' : 'Välkommen $name!',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
} 