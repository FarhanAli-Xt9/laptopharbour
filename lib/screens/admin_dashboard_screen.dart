import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/colors.dart';
import '../widgets/glass_card.dart';
import 'auth_screen.dart';
import 'main_navigation_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final bool isEmbedded;
  final VoidCallback? onNavigateToStore;

  const AdminDashboardScreen({
    super.key,
    this.isEmbedded = false,
    this.onNavigateToStore,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with TickerProviderStateMixin {
  int _selectedSection = 0;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final List<Map<String, dynamic>> _sections = [
    {'label': 'Overview', 'icon': Icons.dashboard_rounded},
    {'label': 'Users', 'icon': Icons.people_rounded},
    {'label': 'Orders', 'icon': Icons.receipt_long_rounded},
    {'label': 'Products', 'icon': Icons.laptop_rounded},
    {'label': 'Settings', 'icon': Icons.settings_rounded},
  ];

  // Fake stats
  final List<Map<String, dynamic>> _stats = [
    {
      'title': 'Total Revenue',
      'value': 'Rs. 12,48,500',
      'icon': Icons.currency_rupee_rounded,
      'change': '+18.4%',
      'positive': true,
      'gradient': [Color(0xFF00E5FF), Color(0xFF0072FF)],
    },
    {
      'title': 'Active Users',
      'value': '2,847',
      'icon': Icons.people_alt_rounded,
      'change': '+6.2%',
      'positive': true,
      'gradient': [Color(0xFF7C4DFF), Color(0xFFE040FB)],
    },
    {
      'title': 'Total Orders',
      'value': '1,293',
      'icon': Icons.shopping_bag_rounded,
      'change': '+12.1%',
      'positive': true,
      'gradient': [Color(0xFFFFB300), Color(0xFFFF6D00)],
    },
    {
      'title': 'Pending Shipments',
      'value': '47',
      'icon': Icons.local_shipping_rounded,
      'change': '-3 today',
      'positive': false,
      'gradient': [Color(0xFF00E676), Color(0xFF00BCD4)],
    },
  ];

  final List<Map<String, dynamic>> _recentOrders = [
    {'id': '#ORD-9821', 'user': 'Ali Hassan', 'product': 'MacBook Pro M4', 'amount': 'Rs. 3,49,000', 'status': 'Delivered', 'statusColor': Color(0xFF00E676)},
    {'id': '#ORD-9820', 'user': 'Sara Ahmed', 'product': 'Dell XPS 15', 'amount': 'Rs. 1,89,000', 'status': 'Processing', 'statusColor': Color(0xFFFFB300)},
    {'id': '#ORD-9819', 'user': 'Usman Raza', 'product': 'HP Spectre x360', 'amount': 'Rs. 2,10,000', 'status': 'Shipped', 'statusColor': Color(0xFF00E5FF)},
    {'id': '#ORD-9818', 'user': 'Aisha Khan', 'product': 'Lenovo ThinkPad X1', 'amount': 'Rs. 1,65,000', 'status': 'Cancelled', 'statusColor': Color(0xFFFF1744)},
    {'id': '#ORD-9817', 'user': 'Bilal Mir', 'product': 'ASUS ROG Zephyrus', 'amount': 'Rs. 2,75,000', 'status': 'Delivered', 'statusColor': Color(0xFF00E676)},
  ];

  final List<Map<String, dynamic>> _users = [
    {'name': 'Ali Hassan', 'email': 'ali@example.com', 'tier': 'GOLD', 'orders': 12, 'joined': 'Jan 2026'},
    {'name': 'Sara Ahmed', 'email': 'sara@example.com', 'tier': 'SILVER', 'orders': 5, 'joined': 'Mar 2026'},
    {'name': 'Usman Raza', 'email': 'usman@example.com', 'tier': 'BRONZE', 'orders': 3, 'joined': 'May 2026'},
    {'name': 'Aisha Khan', 'email': 'aisha@example.com', 'tier': 'GOLD', 'orders': 18, 'joined': 'Dec 2025'},
    {'name': 'Bilal Mir', 'email': 'bilal@example.com', 'tier': 'SILVER', 'orders': 7, 'joined': 'Apr 2026'},
    {'name': 'Zara Qureshi', 'email': 'zara@example.com', 'tier': 'BRONZE', 'orders': 2, 'joined': 'Aug 2026'},
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _changeSection(int index) {
    setState(() => _selectedSection = index);
    _animController.reset();
    _animController.forward();
  }

  Future<void> _logout() async {
    await AuthService.instance.logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, anim, secondaryAnim) => const AuthScreen(),
        transitionsBuilder: (context, anim, secondaryAnim, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width > 800;
    final user = AuthService.instance.currentUser.value;
    final bool showSidebar = isDesktop && !widget.isEmbedded;

    return Scaffold(
      body: Row(
        children: [
          // ─── Sidebar (only when standalone desktop) ───────────────
          if (showSidebar)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 260,
              child: _buildSidebar(user?.name ?? 'Admin'),
            ),

          // ─── Main Content ───────────────────────────────────────
          Expanded(
            child: Column(
              children: [
                // Top App Bar
                _buildTopBar(isDesktop, user?.name ?? 'Admin'),
                // Sub-navbar when embedded or when sidebar hidden
                if (!showSidebar) _buildSubNavBar(),
                // Body
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: _buildContent(isDesktop),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Mobile bottom nav only when NOT embedded
      bottomNavigationBar: widget.isEmbedded
          ? null
          : (isDesktop ? null : _buildMobileBottomNav()),
    );
  }

  // ── Sidebar ─────────────────────────────────────────────────────────
  Widget _buildSidebar(String adminName) {
    return Container(
      decoration: const BoxDecoration(
        color: PremiumTheme.darkSurface,
        border: Border(
          right: BorderSide(color: PremiumTheme.darkBorder, width: 1),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 48),
          // Logo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFB300), Color(0xFFFF6D00)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFB300).withValues(alpha: 0.3),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.shield_rounded, size: 22, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ADMIN PANEL',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'LaptopHarbour',
                      style: TextStyle(
                        fontSize: 10,
                        color: PremiumTheme.textSecondary,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // View Website Store button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _goToWebsite,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: PremiumTheme.primaryNeon.withValues(alpha: 0.1),
                  border: Border.all(color: PremiumTheme.primaryNeon.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.storefront_rounded, color: PremiumTheme.primaryNeon, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'View Website Store',
                        style: TextStyle(
                          color: PremiumTheme.primaryNeon,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_rounded, color: PremiumTheme.primaryNeon, size: 14),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Nav items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _sections.length,
              itemBuilder: (_, i) => _buildSidebarItem(i),
            ),
          ),

          const Divider(color: PremiumTheme.darkBorder),

          // Admin profile at bottom
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFB300), Color(0xFFFF6D00)],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      adminName.isNotEmpty ? adminName[0].toUpperCase() : 'A',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        adminName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const Text(
                        'Super Administrator',
                        style: TextStyle(
                          color: Color(0xFFFFB300),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: PremiumTheme.textSecondary, size: 18),
                  onPressed: _logout,
                  tooltip: 'Logout',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index) {
    final bool selected = _selectedSection == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: selected
            ? const Color(0xFFFFB300).withValues(alpha: 0.12)
            : Colors.transparent,
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(
          _sections[index]['icon'] as IconData,
          color: selected ? const Color(0xFFFFB300) : PremiumTheme.textSecondary,
          size: 20,
        ),
        title: Text(
          _sections[index]['label'] as String,
          style: TextStyle(
            color: selected ? Colors.white : PremiumTheme.textSecondary,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        onTap: () => _changeSection(index),
      ),
    );
  }

  void _goToWebsite() {
    if (widget.onNavigateToStore != null) {
      widget.onNavigateToStore!();
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, anim, secondaryAnim) => const MainNavigationContainer(initialIndex: 0),
          transitionsBuilder: (context, anim, secondaryAnim, child) => FadeTransition(opacity: anim, child: child),
        ),
      );
    }
  }

  Widget _buildSubNavBar() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: PremiumTheme.darkSurface,
        border: Border(
          bottom: BorderSide(color: PremiumTheme.darkBorder, width: 1),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _sections.length,
        itemBuilder: (context, i) {
          final isSelected = _selectedSection == i;
          return Padding(
            padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => _changeSection(i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: isSelected
                      ? const Color(0xFFFFB300)
                      : PremiumTheme.darkSurfaceCard,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFFFB300)
                        : PremiumTheme.darkBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _sections[i]['icon'] as IconData,
                      size: 16,
                      color: isSelected ? Colors.black : const Color(0xFFFFB300),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _sections[i]['label'] as String,
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Top Bar ─────────────────────────────────────────────────────────
  Widget _buildTopBar(bool isDesktop, String adminName) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: PremiumTheme.darkSurface,
        border: Border(
          bottom: BorderSide(color: PremiumTheme.darkBorder, width: 1),
        ),
      ),
      child: Row(
        children: [
          if (!isDesktop) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFB300), Color(0xFFFF6D00)],
                ),
              ),
              child: const Icon(Icons.shield_rounded, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 12),
          ],
          Text(
            _sections[_selectedSection]['label'] as String,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          // View Website Store button
          TextButton.icon(
            style: TextButton.styleFrom(
              backgroundColor: PremiumTheme.primaryNeon.withValues(alpha: 0.12),
              foregroundColor: PremiumTheme.primaryNeon,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: PremiumTheme.primaryNeon.withValues(alpha: 0.4)),
              ),
            ),
            icon: const Icon(Icons.storefront_rounded, size: 16),
            label: Text(
              isDesktop ? 'View Website / Store' : 'Website',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            ),
            onPressed: _goToWebsite,
          ),
          const SizedBox(width: 10),
          // Admin badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFFFFB300), Color(0xFFFF6D00)],
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_rounded, size: 14, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  isDesktop ? 'ADMIN: $adminName' : 'ADMIN',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: PremiumTheme.textSecondary),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
    );
  }

  // ── Content Router ───────────────────────────────────────────────────
  Widget _buildContent(bool isDesktop) {
    switch (_selectedSection) {
      case 0:
        return _buildOverview(isDesktop);
      case 1:
        return _buildUsersSection();
      case 2:
        return _buildOrdersSection();
      case 3:
        return _buildProductsSection();
      case 4:
        return _buildSettingsSection();
      default:
        return _buildOverview(isDesktop);
    }
  }

  // ── Overview ─────────────────────────────────────────────────────────
  Widget _buildOverview(bool isDesktop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1200), Color(0xFF2A1800)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: const Color(0xFFFFB300).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.wb_sunny_rounded, color: Color(0xFFFFB300), size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Good ${_getGreeting()}',
                            style: const TextStyle(color: PremiumTheme.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ValueListenableBuilder(
                        valueListenable: AuthService.instance.currentUser,
                        builder: (context, user, child) => Text(
                          'Welcome back, ${user?.name ?? 'Admin'}! 👋',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Here\'s what\'s happening at LaptopHarbour today.',
                        style: TextStyle(color: PremiumTheme.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFFB300).withValues(alpha: 0.1),
                    border: Border.all(
                      color: const Color(0xFFFFB300).withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(Icons.shield_rounded, color: Color(0xFFFFB300), size: 32),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Stats Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 4 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isDesktop ? 1.6 : 1.3,
            ),
            itemCount: _stats.length,
            itemBuilder: (_, i) => _buildStatCard(_stats[i]),
          ),
          const SizedBox(height: 24),

          // Recent Orders
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Orders',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => _changeSection(2),
                child: const Text('View All →', style: TextStyle(color: Color(0xFFFFB300))),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildOrdersTable(),
        ],
      ),
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat) {
    final gradient = stat['gradient'] as List<Color>;
    return GlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(colors: gradient),
                ),
                child: Icon(stat['icon'] as IconData, color: Colors.white, size: 18),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: (stat['positive'] as bool)
                      ? PremiumTheme.successGreen.withValues(alpha: 0.12)
                      : PremiumTheme.errorRed.withValues(alpha: 0.12),
                ),
                child: Text(
                  stat['change'] as String,
                  style: TextStyle(
                    color: (stat['positive'] as bool)
                        ? PremiumTheme.successGreen
                        : PremiumTheme.errorRed,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stat['value'] as String,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                stat['title'] as String,
                style: const TextStyle(
                  color: PremiumTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTable() {
    return GlassCard(
      borderRadius: 16,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(1.2),
            1: FlexColumnWidth(1.5),
            2: FlexColumnWidth(2),
            3: FlexColumnWidth(1.5),
            4: FlexColumnWidth(1.2),
          },
          children: [
            // Header
            TableRow(
              decoration: const BoxDecoration(
                color: Color(0xFF1B2030),
              ),
              children: ['Order ID', 'Customer', 'Product', 'Amount', 'Status']
                  .map(
                    (h) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Text(
                        h,
                        style: const TextStyle(
                          color: PremiumTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            // Rows
            ..._recentOrders.map(
              (o) => TableRow(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: PremiumTheme.darkBorder, width: 0.5),
                  ),
                ),
                children: [
                  _tableCell(o['id'] as String, color: PremiumTheme.primaryNeon),
                  _tableCell(o['user'] as String),
                  _tableCell(o['product'] as String),
                  _tableCell(o['amount'] as String, bold: true),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: (o['statusColor'] as Color).withValues(alpha: 0.12),
                      ),
                      child: Text(
                        o['status'] as String,
                        style: TextStyle(
                          color: o['statusColor'] as Color,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tableCell(String text, {Color? color, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        text,
        style: TextStyle(
          color: color ?? PremiumTheme.textPrimary,
          fontSize: 13,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // ── Users Section ────────────────────────────────────────────────────
  Widget _buildUsersSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Registered Users',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFB300), Color(0xFFFF6D00)],
                  ),
                ),
                child: const Text(
                  '+ Add User',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GlassCard(
            borderRadius: 16,
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                children: _users.asMap().entries.map((entry) {
                  final u = entry.value;
                  final isLast = entry.key == _users.length - 1;
                  return Container(
                    decoration: BoxDecoration(
                      border: isLast
                          ? null
                          : const Border(
                              bottom: BorderSide(color: PremiumTheme.darkBorder, width: 0.5),
                            ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: PremiumTheme.secondaryNeon.withValues(alpha: 0.2),
                        child: Text(
                          u['name'].toString()[0],
                          style: const TextStyle(color: PremiumTheme.secondaryNeon, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        u['name'] as String,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        u['email'] as String,
                        style: const TextStyle(color: PremiumTheme.textSecondary, fontSize: 12),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _tierBadge(u['tier'] as String),
                          const SizedBox(width: 8),
                          Text(
                            '${u['orders']} orders',
                            style: const TextStyle(color: PremiumTheme.textSecondary, fontSize: 12),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.more_vert_rounded, color: PremiumTheme.textSecondary, size: 18),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tierBadge(String tier) {
    Color color;
    switch (tier) {
      case 'GOLD':
        color = const Color(0xFFFFB300);
        break;
      case 'SILVER':
        color = const Color(0xFF9E9E9E);
        break;
      default:
        color = const Color(0xFFCD7F32);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        tier,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ── Orders Section ───────────────────────────────────────────────────
  Widget _buildOrdersSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'All Orders',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildOrdersTable(),
        ],
      ),
    );
  }

  // ── Products Section ─────────────────────────────────────────────────
  Widget _buildProductsSection() {
    final products = [
      {'name': 'MacBook Pro M4', 'stock': 24, 'price': 'Rs. 3,49,000', 'sold': 128},
      {'name': 'Dell XPS 15', 'stock': 18, 'price': 'Rs. 1,89,000', 'sold': 95},
      {'name': 'HP Spectre x360', 'stock': 12, 'price': 'Rs. 2,10,000', 'sold': 67},
      {'name': 'Lenovo ThinkPad X1', 'stock': 31, 'price': 'Rs. 1,65,000', 'sold': 143},
      {'name': 'ASUS ROG Zephyrus', 'stock': 9, 'price': 'Rs. 2,75,000', 'sold': 52},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Product Inventory',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFB300), Color(0xFFFF6D00)],
                  ),
                ),
                child: const Text(
                  '+ Add Product',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...products.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                borderRadius: 14,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: PremiumTheme.primaryNeon.withValues(alpha: 0.08),
                      ),
                      child: const Icon(Icons.laptop_rounded, color: PremiumTheme.primaryNeon, size: 22),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p['name'] as String,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            p['price'] as String,
                            style: const TextStyle(color: PremiumTheme.primaryNeon, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Stock: ${p['stock']}',
                          style: TextStyle(
                            color: (p['stock'] as int) < 12
                                ? PremiumTheme.errorRed
                                : PremiumTheme.successGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Sold: ${p['sold']}',
                          style: const TextStyle(color: PremiumTheme.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, color: PremiumTheme.textSecondary, size: 18),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Settings Section ─────────────────────────────────────────────────
  Widget _buildSettingsSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Admin Settings',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GlassCard(
            borderRadius: 16,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ValueListenableBuilder(
                  valueListenable: AuthService.instance.currentUser,
                  builder: (context, user, child) => Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFB300), Color(0xFFFF6D00)],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'A',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Admin',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            user?.email ?? 'farhan2407a@gmail.com',
                            style: const TextStyle(color: PremiumTheme.textSecondary, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: const Color(0xFFFFB300).withValues(alpha: 0.15),
                            ),
                            child: const Text(
                              'Super Administrator',
                              style: TextStyle(color: Color(0xFFFFB300), fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ...[
            {'icon': Icons.notifications_rounded, 'label': 'Push Notifications', 'subtitle': 'Manage notification settings'},
            {'icon': Icons.security_rounded, 'label': 'Security', 'subtitle': 'Two-factor authentication, sessions'},
            {'icon': Icons.palette_rounded, 'label': 'Appearance', 'subtitle': 'Theme and display options'},
            {'icon': Icons.analytics_rounded, 'label': 'Analytics', 'subtitle': 'View detailed platform analytics'},
          ].map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                borderRadius: 14,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFFFFB300).withValues(alpha: 0.1),
                    ),
                    child: Icon(item['icon'] as IconData, color: const Color(0xFFFFB300), size: 20),
                  ),
                  title: Text(item['label'] as String, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(item['subtitle'] as String, style: const TextStyle(color: PremiumTheme.textSecondary, fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: PremiumTheme.textSecondary),
                  onTap: () {},
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: PremiumTheme.errorRed.withValues(alpha: 0.15),
                foregroundColor: PremiumTheme.errorRed,
                side: BorderSide(color: PremiumTheme.errorRed.withValues(alpha: 0.4)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Logout from Admin Panel', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: _logout,
            ),
          ),
        ],
      ),
    );
  }

  // ── Mobile Bottom Nav ─────────────────────────────────────────────────
  Widget _buildMobileBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: PremiumTheme.darkSurface,
        border: Border(top: BorderSide(color: PremiumTheme.darkBorder)),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedSection,
        onTap: _changeSection,
        backgroundColor: PremiumTheme.darkSurface,
        selectedItemColor: const Color(0xFFFFB300),
        unselectedItemColor: PremiumTheme.textSecondary,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: _sections
            .map(
              (s) => BottomNavigationBarItem(
                icon: Icon(s['icon'] as IconData),
                label: s['label'] as String,
              ),
            )
            .toList(),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}
