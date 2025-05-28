import 'package:imat/app_theme.dart';
import 'package:imat/widgets/card_details.dart';
import 'package:imat/widgets/customer_details.dart';
import 'package:flutter/material.dart';
import 'package:imat/widgets/page_scaffold.dart';
import 'package:imat/model/imat_data_handler.dart';
import 'package:provider/provider.dart';

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      backgroundColor: Colors.grey[50],
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context),
            const SizedBox(height: AppTheme.paddingMedium),
            _buildProfileContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Consumer<ImatDataHandler>(
      builder: (context, iMat, child) {
        final customer = iMat.getCustomer();
        final isLoggedIn = iMat.isLoggedIn;
        final user = iMat.getUser();
        
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.accentColor,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.paddingHuge),
            child: Column(
              children: [
                // Profile Avatar
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: AppTheme.secondaryColor,
                  ),
                ),
                const SizedBox(height: AppTheme.paddingMedium),
                
                // User Name
                Text(
                  isLoggedIn && (customer.firstName.isNotEmpty || customer.lastName.isNotEmpty)
                      ? '${customer.firstName} ${customer.lastName}'.trim()
                      : isLoggedIn && user.userName.isNotEmpty
                          ? user.userName
                          : 'Välkommen!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.paddingSmall),
                
                // Email
                if (isLoggedIn && customer.email.isNotEmpty)
                  Text(
                    customer.email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: AppTheme.paddingMedium),
                
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.paddingMedium,
                    vertical: AppTheme.paddingSmall,
                  ),
                  decoration: BoxDecoration(
                    color: isLoggedIn ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isLoggedIn ? Icons.check_circle : Icons.info_outline,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: AppTheme.paddingSmall),
                      Text(
                        isLoggedIn ? 'Inloggad' : 'Gäst',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Padding(
            padding: const EdgeInsets.only(left: AppTheme.paddingSmall),
            child: Text(
              'Mina uppgifter',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.secondaryColor,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          
          // Content Cards
          LayoutBuilder(
            builder: (context, constraints) {
              // Responsive layout
              if (constraints.maxWidth > 800) {
                // Desktop/Tablet: Side by side
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildCustomerCard(context)),
                    const SizedBox(width: AppTheme.paddingMedium),
                    Expanded(child: _buildPaymentCard(context)),
                  ],
                );
              } else {
                // Mobile: Stacked
                return Column(
                  children: [
                    _buildCustomerCard(context),
                    const SizedBox(height: AppTheme.paddingMedium),
                    _buildPaymentCard(context),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: AppTheme.secondaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppTheme.paddingMedium),
                Text(
                  'Personuppgifter',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.secondaryColor,
                  ),
                ),
              ],
            ),
          ),
          
          // Card Content
          const Padding(
            padding: EdgeInsets.all(AppTheme.paddingMedium),
            child: CustomerDetails(),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.credit_card,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppTheme.paddingMedium),
                Text(
                  'Betalningsinformation',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.secondaryColor,
                  ),
                ),
              ],
            ),
          ),
          
          // Card Content
          const Padding(
            padding: EdgeInsets.all(AppTheme.paddingMedium),
            child: CardDetails(),
          ),
        ],
      ),
    );
  }
}
