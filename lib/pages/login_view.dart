import 'package:flutter/material.dart';
import 'package:imat/app_theme.dart';
import 'package:imat/widgets/custom_components.dart';
import 'package:imat/model/imat_data_handler.dart';
import 'package:imat/routes.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _loginError;
  String? _returnTo;

  @override
  void initState() {
    super.initState();
    // Get return path from URL parameters
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uri = GoRouter.of(context).routeInformationProvider.value.location;
      final queryParams = Uri.parse(uri).queryParameters;
      _returnTo = queryParams['returnTo'];
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Logga in',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.paddingLarge),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header section
                    Icon(
                      Icons.login,
                      size: 64,
                      color: AppTheme.accentColor,
                    ),
                    const SizedBox(height: AppTheme.paddingMedium),
                    Text(
                      'Välkommen tillbaka!',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.secondaryColor,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.paddingSmall),
                    Text(
                      'Logga in för att fortsätta handla',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.paddingLarge),
                    
                    // Form section
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Show login error if exists
                          if (_loginError != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                border: Border.all(color: Colors.red.shade200),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error, color: Colors.red.shade600, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _loginError!,
                                      style: TextStyle(
                                        color: Colors.red.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppTheme.paddingMedium),
                          ],
                          CustomTextField(
                            controller: _emailController,
                            label: 'E-post',
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            hintText: 'din.email@exempel.se',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vänligen ange din e-postadress';
                              }
                              if (!value.contains('@') || !value.contains('.')) {
                                return 'Vänligen ange en giltig e-postadress';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              // Clear login error when user starts typing
                              if (_loginError != null) {
                                setState(() {
                                  _loginError = null;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: AppTheme.paddingMedium),
                          
                          CustomTextField(
                            obscureText: true,
                            icon: Icons.lock,
                            controller: _passwordController,
                            label: 'Lösenord',
                            hintText: 'Skriv ditt lösenord här...',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vänligen ange ditt lösenord';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              // Clear login error when user starts typing
                              if (_loginError != null) {
                                setState(() {
                                  _loginError = null;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: AppTheme.paddingLarge),
                          
                          // Login button
                          CustomButton(
                            text: _isLoading ? 'Loggar in...' : 'Logga in',
                            icon: Icons.login,
                            onPressed: _isLoading ? null : _performLogin,
                            isLoading: _isLoading,
                            loadingText: 'Loggar in...',
                            width: double.infinity,
                          ),
                          const SizedBox(height: AppTheme.paddingMedium),
                          
                          // Sign up link
                          TextButton(
                            onPressed: () {
                              context.go(AppRoutes.signup);
                            },
                            child: Text(
                              'Har du inget konto? Registrera dig här',
                              style: TextStyle(
                                color: AppTheme.secondaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
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
      ),
    );
  }

  void _performLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final imatDataHandler = Provider.of<ImatDataHandler>(
          context,
          listen: false,
        );

        String? loginError = await imatDataHandler.login(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (mounted) {
          if (loginError == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Inloggning lyckades!'),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
            
            // Navigate to return path or home
            if (_returnTo != null && _returnTo!.isNotEmpty) {
              context.go(_returnTo!);
            } else {
              context.go(AppRoutes.home);
            }
          } else {
            setState(() {
              _loginError = loginError;
            });
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Fel vid inloggning: ${e.toString()}'),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}
