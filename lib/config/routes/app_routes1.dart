import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/product/presentation/pages/add_product_page.dart';
import '../../features/product/presentation/pages/edit_product_page.dart';
import '../../features/shop/presentation/pages/shop_details_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/about_page.dart';
import '../../features/billing/presentation/pages/scanner_page.dart';
import '../../features/billing/presentation/pages/checkout_page.dart';
import '../../features/product/domain/entities/product.dart';
import '../../features/auth/presentation/pages/pin_setup_page.dart';
import '../../features/auth/presentation/pages/lock_screen_page.dart';
import '../../core/services/auth_service.dart';
import '../../core/widgets/main_shell.dart';

final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    final hasPIN = await AuthService.hasPIN();
    final isLockScreen = state.matchedLocation == '/lock';
    final isPinSetup = state.matchedLocation == '/pin-setup';

    if (!hasPIN && !isPinSetup) return '/pin-setup';
    if (hasPIN && !AuthService.isUnlocked && !isLockScreen && !isPinSetup) {
      return '/lock';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainShell(),
      routes: [
        GoRoute(
          path: 'scanner',
          builder: (context, state) => const ScannerPage(),
        ),
        GoRoute(
          path: 'checkout',
          builder: (context, state) => const CheckoutPage(),
        ),
        GoRoute(
          path: 'products/add',
          builder: (context, state) => const AddProductPage(),
        ),
        GoRoute(
          path: 'products/edit/:id',
          builder: (context, state) {
            final product = state.extra as Product?;
            if (product == null) return const MainShell();
            return EditProductPage(product: product);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => const AboutPage(),
    ),
    GoRoute(
      path: '/shop',
      builder: (context, state) => const ShopDetailsPage(),
    ),
    GoRoute(
      path: '/pin-setup',
      builder: (context, state) => const PinSetupPage(),
    ),
    GoRoute(
      path: '/lock',
      builder: (context, state) => const LockScreenPage(),
    ),
  ],
);
