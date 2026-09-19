import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/colors.dart';
import 'auth_screen.dart';
import 'main_navigation_screen.dart';

export 'main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.8, curve: Curves.elasticOut)),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background subtle radial glow
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                color: PremiumTheme.darkBg,
              ),
            ),
          ),
          Positioned(
            top: -200,
            left: -200,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: PremiumTheme.primaryNeon.withValues(alpha: 0.05),
              ),
              child: BackdropFilter(
                filter: ColorFilter.mode(PremiumTheme.primaryNeon.withValues(alpha: 0.01), BlendMode.srcOver),
                child: Container(),
              ),
            ),
          ),
          Positioned(
            bottom: -200,
            right: -200,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: PremiumTheme.secondaryNeon.withValues(alpha: 0.05),
              ),
            ),
          ),
          
          // Main content
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Sleek Custom Icon/Logo
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: PremiumTheme.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: PremiumTheme.primaryNeon.withValues(alpha: 0.35),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.anchor_rounded, // Harbour / Anchor symbol for LaptopHarbour
                      size: 56,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // App Title
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Colors.white,
                      ),
                      children: [
                        TextSpan(text: 'LAPTOP'),
                        TextSpan(
                          text: 'HARBOUR',
                          style: TextStyle(
                            color: PremiumTheme.primaryNeon,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Explore • Compare • Configure',
                    style: TextStyle(
                      color: PremiumTheme.textSecondary,
                      fontSize: 16,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 60),
                  // Futuristic Action Button
                  GestureDetector(
                    onTap: () {
                      final targetPage = AuthService.instance.isAuthenticated
                          ? const MainNavigationContainer()
                          : const AuthScreen();

                      Navigator.of(context).pushReplacement(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => targetPage,
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 600),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: PremiumTheme.primaryNeon.withValues(alpha: 0.4),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: PremiumTheme.primaryNeon.withValues(alpha: 0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        gradient: LinearGradient(
                          colors: [
                            PremiumTheme.primaryNeon.withValues(alpha: 0.15),
                            PremiumTheme.secondaryNeon.withValues(alpha: 0.05),
                          ],
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'ENTER PORT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: PremiumTheme.primaryNeon,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
