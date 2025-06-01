import 'package:flutter/material.dart';
import 'package:imat/model/imat/customer.dart';
import 'package:imat/model/imat_data_handler.dart';
import 'package:imat/widgets/custom_components.dart';
import 'package:provider/provider.dart';

// Simple widget to edit card information.
// It's probably better to use Form
class CustomerDetails extends StatefulWidget {
  final bool showSaveButton;
  final bool enableEmailEditing;

  const CustomerDetails({
    super.key,
    this.showSaveButton = true,
    this.enableEmailEditing = true,
  });

  @override
  State<CustomerDetails> createState() => _CustomerDetailsState();
}

class _CustomerDetailsState extends State<CustomerDetails> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _mobileNumberController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _postCodeController;
  late final TextEditingController _postAddressController;
  bool _hasLoadedData = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with empty values
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _mobileNumberController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    _postCodeController = TextEditingController();
    _postAddressController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _mobileNumberController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _postCodeController.dispose();
    _postAddressController.dispose();
    super.dispose();
  }

  void _loadCustomerData(Customer customer) {
    // Check if this is real data (not just empty defaults) and we haven't loaded yet
    if (!_hasLoadedData &&
        (customer.firstName.isNotEmpty ||
            customer.lastName.isNotEmpty ||
            customer.email.isNotEmpty)) {
      _firstNameController.text = customer.firstName;
      _lastNameController.text = customer.lastName;
      _mobileNumberController.text = customer.mobilePhoneNumber;
      _emailController.text = customer.email;
      _addressController.text = customer.address;
      _postCodeController.text = customer.postCode;
      _postAddressController.text = customer.postAddress;
      _hasLoadedData = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ImatDataHandler>(
      builder: (context, iMat, child) {
        // Load data when it becomes available
        Customer customer = iMat.getCustomer();
        _loadCustomerData(customer);

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              Tooltip(
                message:
                    widget.enableEmailEditing
                        ? 'E-post kan ändras här'
                        : 'E-post kan endast ändras i profilen',
                child: Stack(
                  children: [
                    CustomTextField(
                      controller: _emailController,
                      label: 'E-post',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      enabled: widget.enableEmailEditing,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vänligen ange din e-postadress';
                        }
                        if (!value.contains('@')) {
                          return 'Vänligen ange en giltig e-postadress';
                        }
                        return null;
                      },
                    ),
                    if (!widget.enableEmailEditing)
                      Positioned(
                        right: 12,
                        top: 12,
                        child: Icon(
                          Icons.lock,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
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
                          return 'Vänligen ange postnummer';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: CustomTextField(
                      controller: _postAddressController,
                      label: 'Ort',
                      icon: Icons.location_city,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vänligen ange ort';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              if (widget.showSaveButton) ...[
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Spara uppgifter',
                  icon: Icons.save,
                  onPressed: _saveCustomer,
                  width: double.infinity,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _saveCustomer() {
    if (_formKey.currentState!.validate()) {
      var imatDataHandler = Provider.of<ImatDataHandler>(
        context,
        listen: false,
      );
      Customer customer = imatDataHandler.getCustomer();

      customer.firstName = _firstNameController.text;
      customer.lastName = _lastNameController.text;
      customer.mobilePhoneNumber = _mobileNumberController.text;
      customer.email = _emailController.text;
      customer.address = _addressController.text;
      customer.postCode = _postCodeController.text;
      customer.postAddress = _postAddressController.text;

      imatDataHandler.setCustomer(customer);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kunduppgifter sparade'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
