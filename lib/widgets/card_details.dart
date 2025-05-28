import 'package:imat/model/imat/credit_card.dart';
import 'package:imat/model/imat_data_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:imat/app_theme.dart';

// Custom formatter for MM/YY expiry date
class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    // Remove any non-digit characters
    final digitsOnly = text.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Limit to 4 digits max (MMYY)
    final limitedDigits = digitsOnly.length > 4 ? digitsOnly.substring(0, 4) : digitsOnly;
    
    String formatted = '';
    
    if (limitedDigits.isNotEmpty) {
      // Add the month part
      formatted = limitedDigits.substring(0, limitedDigits.length > 2 ? 2 : limitedDigits.length);
      
      // Add the slash and year part if we have more than 2 digits
      if (limitedDigits.length > 2) {
        formatted += '/' + limitedDigits.substring(2);
      }
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Simple widget to edit card information.
// It's probably better to use Form
class CardDetails extends StatefulWidget {
  const CardDetails({super.key});

  @override
  State<CardDetails> createState() => _CardDetailsState();
}

class _CardDetailsState extends State<CardDetails> {
  late final TextEditingController _typeController;
  late final TextEditingController _nameController;
  late final TextEditingController _expiryController;
  late final TextEditingController _numberController;
  late final TextEditingController _codeController;
  
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    var iMat = Provider.of<ImatDataHandler>(context, listen: false);
    CreditCard card = iMat.getCreditCard();

    _typeController = TextEditingController(text: card.cardType);
    _nameController = TextEditingController(text: card.holdersName);
    
    // Format existing month/year as MM/YY
    String expiryText = '';
    if (card.validMonth > 0 && card.validYear > 0) {
      final month = card.validMonth.toString().padLeft(2, '0');
      final year = card.validYear.toString().padLeft(2, '0');
      expiryText = '$month/$year';
    }
    _expiryController = TextEditingController(text: expiryText);
    
    _numberController = TextEditingController(text: card.cardNumber);
    _codeController = TextEditingController(text: card.verificationCode > 0 ? '${card.verificationCode}' : '');
  }

  @override
  void dispose() {
    _typeController.dispose();
    _nameController.dispose();
    _expiryController.dispose();
    _numberController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  String? _validateExpiryDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ange utgångsdatum';
    }
    
    if (value.length != 5 || !value.contains('/')) {
      return 'Format måste vara MM/YY';
    }
    
    final parts = value.split('/');
    if (parts.length != 2) {
      return 'Format måste vara MM/YY';
    }
    
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);
    
    if (month == null || year == null) {
      return 'Ogiltigt datum';
    }
    
    if (month < 1 || month > 12) {
      return 'Månaden måste vara mellan 01-12';
    }
    
    // Check if the card has expired
    final now = DateTime.now();
    final currentYear = now.year % 100; // Get last 2 digits of current year
    final currentMonth = now.month;
    
    if (year < currentYear || (year == currentYear && month < currentMonth)) {
      return 'Kortet har gått ut';
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Kortinnehavare',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.accentColor, width: 2),
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.person, color: AppTheme.accentColor),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ange kortinnehavarens namn';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _numberController,
            decoration: InputDecoration(
              labelText: 'Kortnummer',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.accentColor, width: 2),
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.credit_card, color: AppTheme.accentColor),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ange kortnummer';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _expiryController,
                  decoration: InputDecoration(
                    labelText: 'Utgångsdatum',
                    hintText: 'MM/YY',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.accentColor, width: 2),
                    ),
                    prefixIcon: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.calendar_today, color: AppTheme.accentColor),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [ExpiryDateFormatter()],
                  validator: _validateExpiryDate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _codeController,
                  decoration: InputDecoration(
                    labelText: 'CVV',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.accentColor, width: 2),
                    ),
                    prefixIcon: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.lock, color: AppTheme.accentColor),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ange CVV';
                    }
                    if (value.length < 3) {
                      return 'CVV måste vara 3-4 siffror';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.accentColor, AppTheme.accentColor.withOpacity(0.8)],
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
              onPressed: _saveCard,
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text(
                'Spara kort',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveCard() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      var iMat = Provider.of<ImatDataHandler>(context, listen: false);
      CreditCard card = iMat.getCreditCard();

      card.cardType = _typeController.text;
      card.holdersName = _nameController.text;
      card.cardNumber = _numberController.text;
      card.verificationCode = int.parse(_codeController.text);

      // Parse MM/YY format
      final expiryParts = _expiryController.text.split('/');
      card.validMonth = int.parse(expiryParts[0]);
      card.validYear = int.parse(expiryParts[1]);

      // This needed to trigger update to the server
      iMat.setCreditCard(card);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kortuppgifter sparade'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fel vid sparning av kortuppgifter'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
