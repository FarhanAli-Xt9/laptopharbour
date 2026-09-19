import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/colors.dart';
import 'home_screen.dart';
import 'comparison_screen.dart';
import 'ai_finder_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'admin_dashboard_screen.dart';

/// Navigation shell for Laptop Harbour accommodating desktop responsive sidebar
/// and mobile adaptive bottom navigation.
/// Displays the full website (Explore, Compare, AI Finder, Cart, Profile),
/// and integrates the Admin Dashboard directly for administrative users.
class MainNavigationContainer extends StatefulWidget {
  final int initialIndex;

  const MainNavigationContainer({
    super.key,
    this.initialIndex = 0,
  });

  /// Allows child widgets anywhere in the tree to switch tabs
  static void switchTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_MainNavigationContainerState>();
    if (state != null) {
      state.setIndex(index);
    }
  }

  @override
  State<MainNavigationContainer> createState() => _MainNavigationContainerState();
}

class _MainNavigationContainerState extends State<MainNavigationContainer> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void setIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  List<Widget> _getScreens(bool isAdmin) {
    return [
      const HomeScreen(),
      const ComparisonScreen(),
      const AIFinderScreen(),
      const CartScreen(),
      const ProfileScreen(),
      if (isAdmin)
        AdminDashboardScreen(
          isEmbedded: true,
          onNavigateToStore: () => setIndex(0),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width > 800;
    final currentUser = AuthService.instance.currentUser.value;
    final bool isAdmin = currentUser?.isAdmin ?? false;

    final screens = _getScreens(isAdmin);
    final int safeIndex = _currentIndex < screens.length ? _currentIndex : 0;

    return Scaffold(
      body: Row(
        children: [
          // Sidebar for Desktop view
          if (isDesktop)
            Container(
              width: 250,
              decoration: const BoxDecoration(
                color: PremiumTheme.darkBg,
                border: Border(
                  right: BorderSide(color: PremiumTheme.darkBorder, width: 1),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Logo
                  InkWell(
                    onTap: () => setIndex(0),
                    borderRadius: BorderRadius.circular(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: PremiumTheme.primaryGradient,
                          ),
                          child: const Icon(Icons.anchor_rounded, size: 24, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'LAPTOPHARBOUR',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Navigation Items
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Text(
                            'WEBSITE & STORE',
                            style: TextStyle(
                              color: PremiumTheme.textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        _buildSidebarItem(0, safeIndex, 'Explore Store', Icons.storefront_rounded),
                        _buildSidebarItem(1, safeIndex, 'Compare Rig', Icons.compare_arrows_rounded),
                        _buildSidebarItem(2, safeIndex, 'AI Finder', Icons.auto_awesome_rounded),
                        _buildSidebarItem(3, safeIndex, 'Dock / Cart', Icons.shopping_cart_rounded),
                        _buildSidebarItem(4, safeIndex, 'Captain Log', Icons.person_rounded),

                        // Admin section in sidebar if user is Admin
                        if (isAdmin) ...[
                          const SizedBox(height: 18),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: Text(
                              'CONTROL CENTER',
                              style: TextStyle(
                                color: Color(0xFFFFB300),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          _buildAdminSidebarItem(5, safeIndex == 5),
                        ],
                      ],
                    ),
                  ),

                  const Divider(color: PremiumTheme.darkBorder),

                  // Dynamic User Information from AuthService
                  ValueListenableBuilder(
                    valueListenable: AuthService.instance.currentUser,
                    builder: (context, user, _) {
                      final name = user?.name ?? 'Captain User';
                      final tier = user?.tier ?? (isAdmin ? 'ADMIN COMMANDER' : 'Gold Commander');
                      final initial = user?.initials.isNotEmpty == true
                          ? user!.initials[0]
                          : 'C';

                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: isAdmin
                                  ? const Color(0xFFFFB300)
                                  : PremiumTheme.secondaryNeon,
                              child: Text(
                                initial,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                      ),
                                      if (isAdmin) ...[
                                        const SizedBox(width: 4),
                                        const Icon(Icons.verified_rounded, size: 14, color: Color(0xFFFFB300)),
                                      ],
                                    ],
                                  ),
                                  Text(
                                    tier,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isAdmin
                                          ? const Color(0xFFFFB300)
                                          : PremiumTheme.accentGold.withValues(alpha: 0.8),
                                      fontSize: 11,
                                      fontWeight: isAdmin ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

          // Main Screen area using IndexedStack to preserve state
          Expanded(
            child: IndexedStack(
              index: safeIndex,
              children: screens,
            ),
          ),
        ],
      ),

      // Bottom navigation bar for mobile view
      bottomNavigationBar: isDesktop
          ? null
          : Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: PremiumTheme.darkBorder, width: 1),
                ),
              ),
              child: BottomNavigationBar(
                currentIndex: safeIndex,
                onTap: setIndex,
                backgroundColor: PremiumTheme.darkBg,
                selectedItemColor: safeIndex == 5 ? const Color(0xFFFFB300) : PremiumTheme.primaryNeon,
                unselectedItemColor: PremiumTheme.textSecondary,
                type: BottomNavigationBarType.fixed,
                showUnselectedLabels: true,
                selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                unselectedLabelStyle: const TextStyle(fontSize: 10),
                items: [
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.storefront_rounded),
                    label: 'Explore',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.compare_arrows_rounded),
                    label: 'Compare',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.auto_awesome_rounded),
                    label: 'AI Finder',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.shopping_cart_rounded),
                    label: 'Dock',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.person_rounded),
                    label: 'Profile',
                  ),
                  if (isAdmin)
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.shield_rounded, color: Color(0xFFFFB300)),
                      label: 'Admin',
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildSidebarItem(int index, int activeIndex, String title, IconData icon) {
    final bool isSelected = activeIndex == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: isSelected ? PremiumTheme.primaryNeon.withValues(alpha: 0.08) : Colors.transparent,
        leading: Icon(
          icon,
          color: isSelected ? PremiumTheme.primaryNeon : PremiumTheme.textSecondary,
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : PremiumTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
        onTap: () => setIndex(index),
      ),
    );
  }

  Widget _buildAdminSidebarItem(int index, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: isSelected
            ? const LinearGradient(
                colors: [Color(0xFFFFB300), Color(0xFFFF6D00)],
              )
            : null,
        border: Border.all(
          color: const Color(0xFFFFB300).withValues(alpha: isSelected ? 0.9 : 0.35),
        ),
        color: isSelected
            ? null
            : const Color(0xFFFFB300).withValues(alpha: 0.08),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(
          Icons.shield_rounded,
          color: isSelected ? Colors.black : const Color(0xFFFFB300),
          size: 20,
        ),
        title: Text(
          'Admin Dashboard',
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: isSelected
                ? Colors.black.withValues(alpha: 0.2)
                : const Color(0xFFFFB300).withValues(alpha: 0.2),
          ),
          child: Text(
            'ADMIN',
            style: TextStyle(
              color: isSelected ? Colors.black : const Color(0xFFFFB300),
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () => setIndex(index),
      ),
    );
  }
}
