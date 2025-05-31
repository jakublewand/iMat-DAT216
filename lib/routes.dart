import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:imat/pages/main_view.dart';
import 'package:imat/pages/login_view.dart';
import 'package:imat/pages/signup_view.dart';
import 'package:imat/pages/checkout_view.dart';
import 'package:imat/pages/checkout_success_view.dart';
import 'package:imat/pages/account_view.dart';
import 'package:imat/pages/history_view.dart';
import 'package:imat/widgets/product_lightbox.dart';
import 'package:imat/model/imat_data_handler.dart';
import 'package:provider/provider.dart';

class AppRoutes {
  // Route names as constants
  static const String home = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String checkout = '/checkout';
  static const String checkoutSuccess = '/checkout-success';
  static const String account = '/account';
  static const String history = '/history';
  static const String product = '/product';
  
  // Helper method för produktroute med id
  static String productWithId(int productId) => '/product/$productId';

  // GoRouter configuration
  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => navigationShell,
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: home,
                name: 'home',
                builder: (context, state) => MainView(key: state.pageKey),
                routes: [
                  GoRoute(
                    path: 'product/:id',
                    name: 'product',
                    pageBuilder: (context, state) {
                      final id = int.parse(state.pathParameters['id']!);
                      return ProductModalPage(productId: id, key: state.pageKey);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: signup,
        name: 'signup',
        builder: (context, state) => const SignUpView(),
      ),
      GoRoute(
        path: checkout,
        name: 'checkout',
        builder: (context, state) => const CheckoutView(),
      ),
      GoRoute(
        path: checkoutSuccess,
        name: 'checkout-success',
        builder: (context, state) => const CheckoutSuccessView(),
      ),
      GoRoute(
        path: account,
        name: 'account',
        builder: (context, state) => const AccountView(),
      ),
      GoRoute(
        path: history,
        name: 'history',
        builder: (context, state) => const HistoryView(),
      ),
    ],
  );
}

class ProductModalPage extends Page {
  final int productId;
  
  const ProductModalPage({required this.productId, super.key});

  @override
  Route createRoute(BuildContext context) {
    return ModalBottomSheetRoute(
      settings: this,
      builder: (context) {
        // Fix from GitHub issue #150291 by chunhtai - get fresh settings reference
        final currentPage = ModalRoute.of(context)?.settings as ProductModalPage?;
        
        return Consumer<ImatDataHandler>(
          builder: (context, iMat, child) {
            // Use the current page's productId to ensure fresh data
            final id = currentPage?.productId ?? productId;
            
            // Check if products are still loading
            if (iMat.products.isEmpty) {
              // Products are still loading, show loading indicator
              return Container(
                padding: const EdgeInsets.all(32),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            final product = iMat.getProduct(id);
            
            if (product == null) {
              // Product not found after products loaded, redirect to home
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  context.go(AppRoutes.home);
                }
              });
              return const SizedBox.shrink();
            }
            
            return ProductLightbox(product: product);
          },
        );
      },
      constraints: const BoxConstraints(maxWidth: 1000),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      anchorPoint: const Offset(0, 0),
    );
  }
} 