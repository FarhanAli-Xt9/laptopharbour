# 🖥️ Laptop Harbour

> **Explore • Compare • Configure**
>
> A feature-rich Flutter e-commerce application for browsing, comparing, and
> purchasing premium laptops — built as a Junior Flutter Developer portfolio project.

---

## 📱 Screenshots & Features

| Screen | Features |
|--------|----------|
| **Splash** | Animated fade-in with neon branding, session-aware routing |
| **Auth** | Login / Register with full form validation and loading states |
| **Home** | Search, brand/category chips, price slider, sort options, empty state |
| **Detail** | Spec list, radar performance chart, configurable components, reviews |
| **Cart** | Quantity management, promo codes, real-time price breakdown |
| **Checkout** | Multi-step form: contact info, shipping address, payment method |
| **Orders** | Full order history with line-item detail bottom sheet |
| **Profile** | Dynamic user info, loyalty tier, logout with session clear |
| **AI Finder** | Natural-language chatbot with preset recommendations |
| **Comparison** | Side-by-side spec comparison for any two laptops |

---

## 🏗️ Architecture

The project follows a **layered service architecture** separating concerns cleanly:

```
lib/
├── main.dart                     # App entry, service initialisation
├── models/                       # Pure data classes (Laptop, CartItem, Order, User)
│   ├── laptop.dart
│   ├── cart.dart
│   ├── order.dart
│   └── user.dart
├── services/                     # Business logic & data layer
│   ├── auth_service.dart         # Local session management
│   ├── cart_service.dart         # Cart state (ValueNotifier) + calculations
│   ├── order_service.dart        # Order placement & history
│   ├── laptop_service.dart       # Search, filter, sort on the catalog
│   ├── mock_laptop_data.dart     # 20-laptop catalog dataset (demo backend)
│   ├── recommendation_service.dart # AI Finder scoring heuristics
│   └── storage_service.dart      # SharedPreferences JSON wrapper
├── screens/                      # Full-page UI
│   ├── splash_screen.dart
│   ├── auth_screen.dart
│   ├── main_navigation_screen.dart
│   ├── home_screen.dart
│   ├── detail_screen.dart
│   ├── cart_screen.dart
│   ├── profile_screen.dart
│   ├── ai_finder_screen.dart
│   └── comparison_screen.dart
├── widgets/                      # Reusable components
│   ├── glass_card.dart
│   ├── performance_chart.dart
│   └── tech_tag.dart
├── theme/
│   └── colors.dart               # Design tokens, gradients, glassmorphism helpers
└── utils/
    ├── constants.dart            # App-wide constants (tax, promo codes, storage keys)
    └── validators.dart           # Form validation helpers (email, password, card, etc.)

test/
├── widget_test.dart              # Smoke tests: SplashScreen, MaterialApp
├── validators_test.dart          # 30+ validator unit tests
├── cart_service_test.dart        # Tax, shipping, discount, total calculation tests
└── laptop_service_test.dart      # Search, filter, sort, and data-retrieval tests
```

---

## ✨ Key Flutter Concepts Demonstrated

| Concept | Where |
|---------|-------|
| **Stateful & Stateless Widgets** | All screens and widget components |
| **ValueNotifier + ValueListenableBuilder** | Cart live update across screens |
| **AnimationController + Tween** | Splash screen fade/scale, detail hero animation |
| **CustomPainter** | Radar performance chart (`performance_chart.dart`) |
| **Form + GlobalKey<FormState>** | Auth screen & checkout validation |
| **Navigator.pushReplacement** | Auth → Home routing with fade transition |
| **ModalBottomSheet** | Filter panel, checkout flow, order detail |
| **Responsive Layout** | `LayoutBuilder` — desktop sidebar / mobile bottom nav |
| **SharedPreferences** | Cart & order persistence across app restarts |
| **Singleton Services** | `CartService.instance`, `AuthService.instance` |
| **Factory Constructors** | `UserModel.fromJson()`, `CartItem.fromJson()` |
| **Extension on Context** | Responsive breakpoint helpers |

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x (Dart 3) |
| State Management | `ValueNotifier` / `ChangeNotifier` (no external package) |
| Local Storage | `shared_preferences` |
| UI | Custom glassmorphism dark theme, Google Fonts (Outfit) |
| Charts | `fl_chart` (radar performance chart) |
| Icons | Material Icons |
| Testing | `flutter_test` (unit + widget tests) |

---

## 🚀 Running Locally

### Prerequisites
- Flutter SDK ≥ 3.10 ([install guide](https://docs.flutter.dev/get-started/install))
- Any connected device, emulator, or Chrome for Web

### Steps

```bash
# 1. Clone the repository
git clone <your-repo-url>
cd laptopharbour

# 2. Install dependencies
flutter pub get

# 3. Run on your device / emulator
flutter run

# 4. Run all tests
flutter test

# 5. Static analysis
dart analyze
```

---

## 🧪 Test Coverage

```
flutter test
```

| Test File | Coverage Area | Tests |
|-----------|--------------|-------|
| `widget_test.dart` | App startup, SplashScreen, MaterialApp | 3 |
| `validators_test.dart` | Email, password, phone, card, CVV, address | 30+ |
| `cart_service_test.dart` | Tax (8%), shipping threshold, promo codes, totals | 12 |
| `laptop_service_test.dart` | Search, brand filter, price filter, sort orders | 14 |

**84 tests · 0 failures · No analysis issues**

---

## 🗒️ Demo / Portfolio Notes

This project is a **local-demo implementation** designed for portfolio review.
The following are intentionally simulated without real backend integration:

| Feature | Implementation |
|---------|---------------|
| **Authentication** | Local email/password stored in `shared_preferences` |
| **Payment** | Demo UI only — no real payment gateway |
| **AI Finder** | Rule-based scoring heuristics (no external AI API) |
| **Order Tracking** | Simulated statuses persisted locally |
| **Laptop Catalog** | 20 hard-coded laptop objects in `mock_laptop_data.dart` |

The service layer (`AuthService`, `CartService`, `OrderService`) is designed so
that each can be swapped for a real API client without touching any UI code.

---

## 👤 Author

**Farhan** · Junior Flutter Developer Portfolio Project  
Built with Flutter 3.x & Dart 3 · Dark Glassmorphism Design System
