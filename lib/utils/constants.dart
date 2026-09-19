/// Centralized application constants for Laptop Harbour.
class AppConstants {
  // App Branding
  static const String appName = 'Laptop Harbour';
  static const String appTagline = 'Explore • Compare • Configure';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String keyUserSession = 'lh_session_user';
  static const String keyCartItems = 'lh_cart_items';
  static const String keyOrders = 'lh_order_history';
  static const String keyAppPreferences = 'lh_app_prefs';

  // Commerce & Pricing Rules
  static const double taxRate = 0.08; // 8% Simulated Cargo Tax
  static const double standardShippingFee = 49.0;
  static const double freeShippingThreshold = 2000.0;

  // Promo Codes: code -> discount percentage
  static const Map<String, double> promoCodes = {
    'HARBOUR20': 0.20,
    'PILOT10': 0.10,
  };

  // Cart Limits
  static const int minCartQuantity = 1;
  static const int maxCartQuantity = 10;

  // Responsive Breakpoints
  static const double desktopBreakpoint = 800.0;
  static const double tabletBreakpoint = 600.0;

  // Default Categories & Brands
  static const List<String> defaultBrands = [
    'All',
    'Apple',
    'Razer',
    'ASUS',
    'Lenovo',
    'HP',
    'Dell',
  ];

  static const List<String> defaultCategories = [
    'All',
    'Gaming',
    'Business',
    'Ultra-portable',
    'Creators',
  ];

  static const List<String> sortOptions = [
    'Default',
    'Price: Low to High',
    'Price: High to Low',
    'Highest Rating',
  ];

  // Payment Methods (Portfolio Demo)
  static const List<String> demoPaymentMethods = [
    'Credit Card (Demo Gateway)',
    'Harbour Node Pay (Crypto Demo)',
    'Freight Dock Cash on Arrival',
  ];
}
