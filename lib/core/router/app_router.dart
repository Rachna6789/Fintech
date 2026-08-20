import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/biometric_login_screen.dart';
import '../../features/auth/presentation/screens/email_verification_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/profile_setup_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/alerts/presentation/screens/alerts_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/state/auth_state.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/market/presentation/screens/market_screen.dart';
import '../../features/portfolio/presentation/screens/add_portfolio_asset_screen.dart';
import '../../features/portfolio/presentation/screens/edit_portfolio_asset_screen.dart';
import '../../features/portfolio/presentation/screens/portfolio_detail_screen.dart';
import '../../features/portfolio/presentation/screens/portfolio_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../widgets/app_error_view.dart';
import 'app_route.dart';
import 'route_paths.dart';

final appNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    navigatorKey: appNavigatorKey,
    initialLocation: RoutePaths.splash,
    redirect: (context, state) {
      final location = state.uri.path;
      final publicRoutes = {
        RoutePaths.login,
        RoutePaths.register,
        RoutePaths.forgotPassword,
        RoutePaths.biometricLogin,
      };

      if (authState.status == AuthFlowStatus.checking) {
        return location == RoutePaths.splash ? null : RoutePaths.splash;
      }

      if (authState.status == AuthFlowStatus.unauthenticated) {
        return publicRoutes.contains(location) ? null : RoutePaths.login;
      }

      if (authState.status == AuthFlowStatus.emailUnverified) {
        return location == RoutePaths.emailVerification
            ? null
            : RoutePaths.emailVerification;
      }

      if (authState.status == AuthFlowStatus.profileIncomplete) {
        return location == RoutePaths.profileSetup
            ? null
            : RoutePaths.profileSetup;
      }

      final isAuthRoute = publicRoutes.contains(location) ||
          location == RoutePaths.emailVerification ||
          location == RoutePaths.profileSetup ||
          location == RoutePaths.splash;
      if (authState.status == AuthFlowStatus.authenticated && isAuthRoute) {
        return RoutePaths.dashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        name: AppRoute.splash.name,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        name: AppRoute.login.name,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.register,
        name: AppRoute.register.name,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        name: AppRoute.forgotPassword.name,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RoutePaths.emailVerification,
        name: AppRoute.emailVerification.name,
        builder: (context, state) => const EmailVerificationScreen(),
      ),
      GoRoute(
        path: RoutePaths.profileSetup,
        name: AppRoute.profileSetup.name,
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: RoutePaths.biometricLogin,
        name: AppRoute.biometricLogin.name,
        builder: (context, state) => const BiometricLoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.dashboard,
        name: AppRoute.dashboard.name,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: RoutePaths.portfolio,
        name: AppRoute.portfolio.name,
        builder: (context, state) => const PortfolioScreen(),
      ),
      GoRoute(
        path: RoutePaths.portfolioAdd,
        name: AppRoute.portfolioAdd.name,
        builder: (context, state) => const AddPortfolioAssetScreen(),
      ),
      GoRoute(
        path: RoutePaths.portfolioDetail,
        name: AppRoute.portfolioDetail.name,
        builder: (context, state) {
          return PortfolioDetailScreen(
            assetId: state.pathParameters['assetId'] ?? '',
          );
        },
      ),
      GoRoute(
        path: RoutePaths.portfolioEdit,
        name: AppRoute.portfolioEdit.name,
        builder: (context, state) {
          return EditPortfolioAssetScreen(
            assetId: state.pathParameters['assetId'] ?? '',
          );
        },
      ),
      GoRoute(
        path: RoutePaths.market,
        name: AppRoute.market.name,
        builder: (context, state) => const MarketScreen(),
      ),
      GoRoute(
        path: RoutePaths.alerts,
        name: AppRoute.alerts.name,
        builder: (context, state) => const AlertsScreen(),
      ),
      GoRoute(
        path: RoutePaths.settings,
        name: AppRoute.settings.name,
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
    errorBuilder: (context, state) {
      return AppErrorView(
        title: 'Page not found',
        message: state.error?.message ?? 'The requested page does not exist.',
      );
    },
  );
});
