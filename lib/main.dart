import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/colors.dart';
import 'screens/splash_screen.dart';

import '../services/storage_service.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.instance.init();
  await AuthService.instance.init();
  await CartService.instance.init();
  await OrderService.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Premium custom dark theme integrated with modern Google Fonts
    final darkTheme = PremiumTheme.getThemeData();
    
    return MaterialApp(
      title: 'LaptopHarbour',
      debugShowCheckedModeBanner: false,
      theme: darkTheme.copyWith(
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          darkTheme.textTheme,
        ).apply(
          bodyColor: PremiumTheme.textPrimary,
          displayColor: Colors.white,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
