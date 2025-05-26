import 'package:flutter/material.dart';
import 'package:imat/app_theme.dart';
import 'package:imat/model/imat_data_handler.dart';
import 'package:imat/pages/account_view.dart';
import 'package:imat/pages/history_view.dart';
import 'package:imat/pages/login_view.dart';
import 'package:imat/pages/main_view.dart';
import 'package:provider/provider.dart';

class AppNavbar extends StatelessWidget {
  const AppNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    var iMat = context.watch<ImatDataHandler>();
    
    return Container(
      padding: EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainView()),
              );
            },
            child: Text(
              'iMat',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: AppTheme.paddingLarge),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Sök',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
                onChanged: (value) {
                  if (value.isEmpty) {
                    context.read<ImatDataHandler>().selectAllProducts();
                  } else {
                    var searchResults = context.read<ImatDataHandler>().findProducts(value);
                    context.read<ImatDataHandler>().selectSelection(searchResults);
                  }
                },
              ),
            ),
          ),
          SizedBox(width: AppTheme.paddingLarge),
          ...iMat.isLoggedIn ? _loggedInButtons(context, iMat) : _loggedOutButtons(context),
        ],
      ),
    );
  }

  List<Widget> _loggedInButtons(BuildContext context, ImatDataHandler iMat) {
    return [
      ElevatedButton(
        onPressed: () => _showHistory(context),
        child: Text('Köphistorik'),
      ),
      SizedBox(width: 8),
      ElevatedButton(
        onPressed: () => _showAccount(context),
        child: Text('Min profil'),
      ),
      SizedBox(width: 8),
      ElevatedButton(
        onPressed: () => _logout(context, iMat),
        child: Text('Logga ut'),
      ),
    ];
  }

  List<Widget> _loggedOutButtons(BuildContext context) {
    return [
      ElevatedButton(
        onPressed: () => _showLogin(context),
        child: Text('Logga in'),
      ),
      SizedBox(width: 8),
      ElevatedButton(
        onPressed: () => _showLogin(context),
        child: Text('Registrera'),
      ),
    ];
  }

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
                Navigator.pop(context);
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: Text('Logga ut'),
            ),
          ],
        );
      },
    );
  }
}
