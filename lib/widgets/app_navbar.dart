import 'package:flutter/material.dart';
import 'package:imat/app_theme.dart';
import 'package:imat/model/imat_data_handler.dart';
import 'package:imat/pages/account_view.dart';
import 'package:imat/pages/history_view.dart';
import 'package:imat/pages/login_view.dart';
import 'package:imat/pages/main_view.dart';
import 'package:imat/pages/signup_view.dart';
import 'package:provider/provider.dart';

class AppNavbar extends StatefulWidget {
  const AppNavbar({super.key});

  @override
  State<AppNavbar> createState() => _AppNavbarState();
}

class _AppNavbarState extends State<AppNavbar> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    
    // Register callback to clear search field when category is selected
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ImatDataHandler>().setSearchClearCallback(() {
        _searchController.clear();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var iMat = context.watch<ImatDataHandler>();

    return Container(
      padding: EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
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
              style: Theme.of(
                context,
              ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: AppTheme.paddingLarge),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.primaryShadowColor,
                borderRadius: BorderRadius.circular(999),
              ),
              child: TextField(
                controller: _searchController,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: 'Sök',
                  prefixIcon: Icon(Icons.search),
                  // Workaround to make it vertically centered
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  context.read<ImatDataHandler>().searchProducts(value);
                },
              ),
            ),
          ),
          SizedBox(width: AppTheme.paddingLarge),
          ...iMat.isLoggedIn
              ? _loggedInButtons(context, iMat)
              : _loggedOutButtons(context),
        ],
      ),
    );
  }

  List<Widget> _loggedInButtons(BuildContext context, ImatDataHandler iMat) {
    return [
      ElevatedButton(
        onPressed: () => _showHistory(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.black,
          elevation: 2,
          side: BorderSide(
            color: Colors.black,
            width: 1,
          ),
        ),
        child: Text('Köphistorik'),
      ),
      SizedBox(width: 8),
      ElevatedButton(
        onPressed: () => _showAccount(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.black,
          elevation: 2,
          side: BorderSide(
            color: Colors.black,
            width: 1,
          ),
        ),
        child: Text('Min profil'),
      ),
      SizedBox(width: 8),
      ElevatedButton(
        onPressed: () => _logout(context, iMat),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.black,
          elevation: 2,
          side: BorderSide(
            color: Colors.black,
            width: 1,
          ),
        ),
        child: Text('Logga ut'),
      ),
    ];
  }

  List<Widget> _loggedOutButtons(BuildContext context) {
    return [
      ElevatedButton(
        onPressed: () => _showLogin(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.black,
          elevation: 2,
          side: BorderSide(
            color: Colors.black,
            width: 1,
          ),
        ),
        child: Text('Logga in'),
      ),
      SizedBox(width: 8),
      ElevatedButton(
        onPressed: () => _showSignup(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.black,
          elevation: 2,
          side: BorderSide(
            color: Colors.black,
            width: 1,
          ),
        ),
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

  void _showSignup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpView()),
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
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.secondaryColor,
              ),
              onPressed: () => Navigator.pop(context),
              child: Text('Avbryt'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: AppTheme.secondaryColor,
                backgroundColor: AppTheme.primaryColor,
              ),
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
