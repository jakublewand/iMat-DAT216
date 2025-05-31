import 'package:flutter/material.dart';
import 'package:imat/model/imat/credit_card.dart';
import 'package:provider/provider.dart';
import 'package:imat/app_theme.dart';
import 'package:imat/model/imat/customer.dart';
import 'package:imat/model/imat/user.dart';
import 'package:imat/model/imat_data_handler.dart';
import 'package:imat/widgets/custom_text_field.dart';
import 'package:imat/widgets/page_scaffold.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _postCodeController = TextEditingController();
  final _postAddressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _mobileNumberController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _postCodeController.dispose();
    _postAddressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      backgroundColor: Colors.brown[50],
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 8,
              shadowColor: AppTheme.secondaryColor.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with back button
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Text(
                            'Skapa konto',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineMedium?.copyWith(
                              color: AppTheme.secondaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48), // Balance the back button
                      ],
                    ),
                    const SizedBox(height: AppTheme.paddingLarge),

                    // Registration form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: _firstNameController,
                            label: 'Förnamn',
                            icon: Icons.person,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vänligen ange ditt förnamn';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppTheme.paddingMedium),

                          CustomTextField(
                            controller: _lastNameController,
                            label: 'Efternamn',
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vänligen ange ditt efternamn';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppTheme.paddingMedium),

                          CustomTextField(
                            controller: _mobileNumberController,
                            label: 'Mobilnummer',
                            icon: Icons.phone_android,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vänligen ange ditt mobilnummer';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppTheme.paddingMedium),

                          CustomTextField(
                            controller: _emailController,
                            label: 'E-post',
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vänligen ange din e-postadress';
                              }
                              if (!value.contains('@') ||
                                  !value.contains('.')) {
                                return 'Vänligen ange en giltig e-postadress';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppTheme.paddingMedium),

                          CustomPasswordField(
                            controller: _passwordController,
                            label: 'Lösenord',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vänligen ange ett lösenord';
                              }
                              if (value.length < 6) {
                                return 'Lösenordet måste vara minst 6 tecken';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppTheme.paddingMedium),

                          CustomPasswordField(
                            controller: _confirmPasswordController,
                            label: 'Bekräfta lösenord',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vänligen bekräfta ditt lösenord';
                              }
                              if (value != _passwordController.text) {
                                return 'Lösenorden matchar inte';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppTheme.paddingMedium),

                          CustomTextField(
                            controller: _addressController,
                            label: 'Adress',
                            icon: Icons.home,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vänligen ange din adress';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppTheme.paddingMedium),

                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: CustomTextField(
                                  controller: _postCodeController,
                                  label: 'Postnummer',
                                  icon: Icons.local_post_office,
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Ange postnummer';
                                    }
                                    if (value.length < 5) {
                                      return 'Ogiltigt postnummer';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: AppTheme.paddingMedium),
                              Expanded(
                                flex: 3,
                                child: CustomTextField(
                                  controller: _postAddressController,
                                  label: 'Ort',
                                  icon: Icons.location_city,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Ange ort';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.paddingLarge),

                          // Register button
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.accentColor,
                                  AppTheme.accentColor.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.accentColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _registerCustomer,
                              icon:
                                  _isLoading
                                      ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                      : const Icon(
                                        Icons.person_add,
                                        color: Colors.white,
                                      ),
                              label: Text(
                                _isLoading ? 'Registrerar...' : 'Skapa konto',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppTheme.paddingMedium),

                          // Login link
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Har du redan ett konto? Logga in här',
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

  void _registerCustomer() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final imatDataHandler = Provider.of<ImatDataHandler>(
          context,
          listen: false,
        );

        // Create new customer with form data
        final customer = Customer(
          _firstNameController.text.trim(),
          _lastNameController.text.trim(),
          '', // phoneNumber - not used in form
          _mobileNumberController.text.trim(),
          _emailController.text.trim(),
          _addressController.text.trim(),
          _postCodeController.text.trim(),
          _postAddressController.text.trim(),
        );

        // Create new user with email as username and provided password
        final user = User(
          _emailController.text.trim(), // email as username
          _passwordController.text,
        );

        // Set customer data (always group 22)
        imatDataHandler.setCustomer(customer);
        imatDataHandler.setCreditCard(CreditCard.empty);
        imatDataHandler.clearAllFilters();
        imatDataHandler.shoppingCartClear();
        imatDataHandler.setUser(user);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Konto skapat framgångsrikt!'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );

          // Navigate back to login/previous page
          Navigator.pop(context);
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
                    child: Text('Fel vid registrering: ${e.toString()}'),
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
