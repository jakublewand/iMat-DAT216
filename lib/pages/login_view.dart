import 'package:flutter/material.dart';
import 'package:imat/app_theme.dart';
import 'package:imat/model/imat_data_handler.dart';
import 'package:imat/pages/signup_view.dart';
import 'package:provider/provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.paddingLarge),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  SizedBox(height: AppTheme.paddingHuge),
                  Container(
                    constraints: BoxConstraints(maxWidth: 480),
                    padding: EdgeInsets.symmetric(
                      vertical: AppTheme.paddingHuge,
                      horizontal: AppTheme.paddingLarge,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 16,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Välkommen tillbaka!',
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppTheme.paddingLarge),
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'din.email@exempel.se',
                          keyboardType: TextInputType.emailAddress,
                          onClear: () => _emailController.clear(),
                        ),
                        SizedBox(height: AppTheme.paddingMedium),
                        _buildTextField(
                          controller: _passwordController,
                          label: 'Lösenord',
                          hint: 'Skriv ditt lösenord här...',
                          obscureText: true,
                          onClear: () => _passwordController.clear(),
                        ),
                        SizedBox(height: AppTheme.paddingLarge),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => SignUpView()),
                                );
                              },
                              child: Text('Skapa nytt konto', style: TextStyle(color: Colors.brown[700])),
                            ),
                            SizedBox(width: AppTheme.paddingLarge),
                            ElevatedButton(
                              onPressed: () {
                                // Simulate login
                                Provider.of<ImatDataHandler>(context, listen: false).login(
                                  _emailController.text,
                                  _passwordController.text,
                                );
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.secondaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 12,
                                ),
                              ),
                              child: Text('Logga in'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscureText = false,
    TextInputType? keyboardType,
    required VoidCallback onClear,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
        SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          cursorColor: Colors.brown[600],
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.brown[50],
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[400],
            ),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, size: 20),
                    onPressed: onClear,
                  )
                : null,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.brown[200]!),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.brown[200]!),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.brown[400]!),
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: 4),
        Text(
          label == 'Email' ? 'Ange din e-postadress' : 'Ange ditt lösenord',
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
