import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/colors.dart';
import '../utils/validators.dart';
import '../widgets/glass_card.dart';
import 'main_navigation_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  bool _isLoading = false;
  String? _errorMessage;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'farhan2407a@gmail.com');
  final _passwordController = TextEditingController(text: 'farhan xt9');
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _obscurePassword = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
      _errorMessage = null;
    });
    _animationController.reset();
    _animationController.forward();
  }

  Future<void> _submit() async {
    if (_isLoading) return;

    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    AuthResult result;
    if (_isLogin) {
      result = await AuthService.instance.login(
        email: email,
        password: password,
      );
    } else {
      result = await AuthService.instance.register(
        name: _nameController.text.trim(),
        email: email,
        password: password,
        confirmPassword: _confirmPasswordController.text,
      );
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: PremiumTheme.darkSurface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: PremiumTheme.successGreen, width: 1),
          ),
          content: Row(
            children: [
              const Icon(Icons.verified_user_rounded, color: PremiumTheme.successGreen),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _isLogin
                      ? 'Clearance Authorized. Welcome aboard, ${result.user?.name}!'
                      : 'Account registered successfully! Welcome to the fleet.',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );

      // Route to website navigation shell with embedded Admin Dashboard for admins
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MainNavigationContainer(initialIndex: 0),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    } else {
      setState(() {
        _errorMessage = result.errorMessage ?? 'Authentication authorization failed.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width > 800;

    return Scaffold(
      body: Stack(
        children: [
          // Background ambient lights
          Positioned(
            top: -150,
            right: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: PremiumTheme.primaryNeon.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: PremiumTheme.secondaryNeon.withValues(alpha: 0.05),
              ),
            ),
          ),

          // Center Card
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isDesktop ? 450 : double.infinity),
                child: GlassCard(
                  borderRadius: 28,
                  padding: const EdgeInsets.all(32),
                  color: PremiumTheme.darkSurfaceCard,
                  child: Form(
                    key: _formKey,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // App icon / Logo
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: PremiumTheme.primaryGradient,
                                boxShadow: [
                                  BoxShadow(
                                    color: PremiumTheme.primaryNeon.withValues(alpha: 0.25),
                                    blurRadius: 20,
                                  )
                                ],
                              ),
                              child: const Icon(Icons.anchor_rounded, size: 36, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _isLogin ? 'Clearance Authorization' : 'Register Crew Node',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _isLogin
                                ? 'Submit secure credentials to enter LaptopHarbour.'
                                : 'Establish a new login coordinates signature.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: PremiumTheme.textSecondary, fontSize: 12),
                          ),
                          const SizedBox(height: 24),

                          // Error message banner if any
                          if (_errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: PremiumTheme.errorRed.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: PremiumTheme.errorRed.withValues(alpha: 0.4)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline_rounded, color: PremiumTheme.errorRed, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: const TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Name field if Register
                          if (!_isLogin) ...[
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Crew Name',
                                prefixIcon: const Icon(Icons.person_outline_rounded, color: PremiumTheme.textSecondary),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              validator: (val) => Validators.validateName(val, fieldName: 'Crew Name'),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Email
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              prefixIcon: const Icon(Icons.email_outlined, color: PremiumTheme.textSecondary),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            validator: Validators.validateEmail,
                          ),
                          const SizedBox(height: 16),

                          // Password
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Secure Passkey',
                              prefixIcon: const Icon(Icons.lock_outline_rounded, color: PremiumTheme.textSecondary),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: PremiumTheme.textSecondary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            validator: Validators.validatePassword,
                          ),
                          const SizedBox(height: 16),

                          // Confirm Password if Register
                          if (!_isLogin) ...[
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Confirm Passkey',
                                prefixIcon: const Icon(Icons.lock_outline_rounded, color: PremiumTheme.textSecondary),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              validator: (val) => Validators.validateConfirmPassword(val, _passwordController.text),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Submit Button
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: PremiumTheme.primaryNeon,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 4,
                            ),
                            onPressed: _isLoading ? null : _submit,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black,
                                    ),
                                  )
                                : Text(
                                    _isLogin ? 'SECURE LOGIN' : 'CREATE ACCOUNT',
                                    style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                                  ),
                          ),
                          const SizedBox(height: 20),

                          // Quick Admin Login shortcut
                          if (_isLogin) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.fingerprint_rounded, color: PremiumTheme.primaryNeon, size: 36),
                                  onPressed: _isLoading
                                      ? null
                                      : () {
                                          _emailController.text = 'farhan2407a@gmail.com';
                                          _passwordController.text = 'farhan xt9';
                                          _submit();
                                        },
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Quick Admin Login',
                                  style: TextStyle(color: PremiumTheme.textSecondary, fontSize: 11),
                                )
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Toggle Auth Mode
                          TextButton(
                            onPressed: _isLoading ? null : _toggleAuthMode,
                            child: Text(
                              _isLogin ? "No signature credentials? Register here" : "Already registered? Login here",
                              style: const TextStyle(color: PremiumTheme.primaryNeon, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
