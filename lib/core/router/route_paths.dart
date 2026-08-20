class RoutePaths {
  const RoutePaths._();

  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const emailVerification = '/email-verification';
  static const profileSetup = '/profile-setup';
  static const biometricLogin = '/biometric-login';
  static const dashboard = '/dashboard';
  static const portfolio = '/portfolio';
  static const portfolioAdd = '/portfolio/add';
  static const portfolioDetail = '/portfolio/:assetId';
  static const portfolioEdit = '/portfolio/:assetId/edit';
  static const market = '/market';
  static const assetSearch = '/assets/search';
  static const watchlist = '/watchlist';
  static const alerts = '/alerts';
  static const settings = '/settings';

  static String portfolioDetailPath(String assetId) => '/portfolio/$assetId';

  static String portfolioEditPath(String assetId) => '/portfolio/$assetId/edit';
}
