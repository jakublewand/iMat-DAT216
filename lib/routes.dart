import 'package:go_router/go_router.dart';
import 'package:imat/pages/main_view.dart';
import 'package:imat/pages/login_view.dart';
import 'package:imat/pages/signup_view.dart';
import 'package:imat/pages/checkout_view.dart';
import 'package:imat/pages/checkout_success_view.dart';
import 'package:imat/pages/account_view.dart';
import 'package:imat/pages/history_view.dart';
import 'package:imat/pages/product_detail_view.dart';

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
  static String productWithId(int productId) => '$product/$productId';

  // GoRouter configuration
  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const MainView(),
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
      GoRoute(
        path: '/product/:id',
        name: 'product',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ProductDetailView(productId: id);
        },
      ),
    ],
  );
} 