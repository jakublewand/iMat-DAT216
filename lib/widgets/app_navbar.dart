import 'package:imat/model/imat_data_handler.dart';
import 'package:imat/pages/account_view.dart';
import 'package:imat/pages/history_view.dart';
import 'package:imat/pages/login_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppNavbar extends StatelessWidget {
  const AppNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    var iMat = context.watch<ImatDataHandler>();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // iMat logo - always visible
        ElevatedButton(
          onPressed: () {
            // Navigate to main if not already there
            Navigator.popUntil(context, (route) => route.isFirst);
          },
          child: Text('iMat'),
        ),
        
        // Right side buttons - different based on login status
        Row(
          children: iMat.isLoggedIn ? _loggedInButtons(context, iMat) : _loggedOutButtons(context),
        ),
      ],
    );
  }

  // Buttons shown when user is logged in
  List<Widget> _loggedInButtons(BuildContext context, ImatDataHandler iMat) {
    return [
      ElevatedButton(
        onPressed: () {
          _showHistory(context);
        },
        child: Text('Köphistorik'),
      ),
      SizedBox(width: 8),
      ElevatedButton(
        onPressed: () {
          _showAccount(context);
        },
        child: Text('Min profil'),
      ),
      SizedBox(width: 8),
      ElevatedButton(
        onPressed: () {
          _logout(context, iMat);
        },
        child: Text('Logga ut'),
      ),
    ];
  }

  // Buttons shown when user is not logged in
  List<Widget> _loggedOutButtons(BuildContext context) {
    return [
      ElevatedButton(
        onPressed: () {
          _showLogin(context);
        },
        child: Text('Logga in'),
      ),
      SizedBox(width: 8),
      ElevatedButton(
        onPressed: () {
          _showLogin(context);
        },
        child: Text('Registrera'),
      ),
    ];
  }

  // Navigation methods
  void _showLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginView()),
    );
  }

  void _showAccount(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AccountView()),
    );
  }

  void _showHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HistoryView()),
    );
  }

  void _logout(BuildContext context, ImatDataHandler iMat) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logga ut'),
          content: Text('Är du säker på att du vill logga ut?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Avbryt'),
            ),
            TextButton(
              onPressed: () {
                iMat.logout();
                Navigator.pop(context); // Close dialog
                Navigator.popUntil(context, (route) => route.isFirst); // Go to main
              },
              child: Text('Logga ut'),
            ),
          ],
        );
      },
    );
  }
} 