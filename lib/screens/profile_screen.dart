import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/auth_service.dart';
import '../theme/colors.dart';
import '../widgets/glass_card.dart';
import 'main_navigation_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _biometricClearance = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Captain Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Access fleet credentials, loyalty certificates, and clearance log records.',
                style: TextStyle(
                  fontSize: 13,
                  color: PremiumTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Captain Profile Header
              ValueListenableBuilder(
                valueListenable: AuthService.instance.currentUser,
                builder: (context, user, _) {
                  final name = user?.name ?? 'Captain User';
                  final email = user?.email ?? 'captain@harbour.com';
                  final id = user?.id ?? 'LHP-981765';
                  final joined = user?.joinedDate ?? 'March 2026';
                  final isAdmin = user?.isAdmin ?? false;
                  final initial = user?.initials ?? 'CU';

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: isAdmin
                                  ? const LinearGradient(
                                      colors: [Color(0xFFFFB300), Color(0xFFFF6D00)],
                                    )
                                  : PremiumTheme.primaryGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: (isAdmin ? const Color(0xFFFFB300) : PremiumTheme.primaryNeon)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 15,
                                )
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              initial,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 20),
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
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                    ),
                                    if (isAdmin) ...[
                                      const SizedBox(width: 6),
                                      const Icon(Icons.verified_rounded, color: Color(0xFFFFB300), size: 18),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  email,
                                  style: const TextStyle(color: PremiumTheme.primaryNeon, fontSize: 12),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Node: $id • Joined: $joined',
                                  style: const TextStyle(color: PremiumTheme.textMuted, fontSize: 11),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),

                      // Admin Control Desk Card if Admin
                      if (isAdmin) ...[
                        const SizedBox(height: 24),
                        GlassCard(
                          borderRadius: 20,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFFFB300), Color(0xFFFF6D00)],
                                      ),
                                    ),
                                    child: const Icon(Icons.shield_rounded, color: Colors.white, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'ADMIN CONTROL PANEL',
                                          style: TextStyle(
                                            color: Color(0xFFFFB300),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                        Text(
                                          'Super Administrator Privileges Active',
                                          style: TextStyle(color: PremiumTheme.textSecondary, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'Manage product inventory, review platform revenue, audit orders and users.',
                                style: TextStyle(color: PremiumTheme.textSecondary, fontSize: 12),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFB300),
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  icon: const Icon(Icons.dashboard_rounded, size: 18),
                                  label: const Text(
                                    'OPEN ADMIN DASHBOARD',
                                    style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                  ),
                                  onPressed: () {
                                    MainNavigationContainer.switchTab(context, 5);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 28),

              // Loyalty Certificate Gold Card
              const Text(
                'LOYALTY CREDENTIALS CERTIFICATE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: PremiumTheme.accentGold,
                ),
              ),
              const SizedBox(height: 12),
              _buildLoyaltyCard(),
              
              const SizedBox(height: 28),
              // Shipment / Order History Records
              const Text(
                'WARP CLEARANCE LOGS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: PremiumTheme.primaryNeon,
                ),
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<List<Order>>(
                valueListenable: OrderHistoryManager.orders,
                builder: (context, ordersList, child) {
                  if (ordersList.isEmpty) {
                    return GlassCard(
                      borderRadius: 16,
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Text(
                            'No cargo logs recorded.',
                            style: TextStyle(color: PremiumTheme.textSecondary, fontSize: 12),
                          ),
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: ordersList.map((order) => _buildOrderHistoryItem(order)).toList(),
                  );
                },
              ),

              const SizedBox(height: 28),
              // System Preferences
              const Text(
                'SYSTEM SETTINGS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: PremiumTheme.secondaryNeon,
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                borderRadius: 16,
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Direct Cargo Notifications', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      subtitle: const Text('Receive push alerts on cargo coordinates and transit.', style: TextStyle(fontSize: 11, color: PremiumTheme.textSecondary)),
                      value: _notificationsEnabled,
                      activeThumbColor: PremiumTheme.primaryNeon,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        setState(() {
                          _notificationsEnabled = val;
                        });
                      },
                    ),
                    const Divider(color: PremiumTheme.darkBorder),
                    SwitchListTile(
                      title: const Text('Biometric Payment Clearance', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      subtitle: const Text('Require touch ID / face ID before checkout authorization.', style: TextStyle(fontSize: 11, color: PremiumTheme.textSecondary)),
                      value: _biometricClearance,
                      activeThumbColor: PremiumTheme.primaryNeon,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        setState(() {
                          _biometricClearance = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoyaltyCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF2C2512), Color(0xFF14130F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: PremiumTheme.accentGold.withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: PremiumTheme.accentGold.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ]
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GOLD COMMANDER',
                    style: TextStyle(
                      color: PremiumTheme.accentGold,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text('LAPTOPHARBOUR ELITE CLUB', style: TextStyle(fontSize: 9, color: PremiumTheme.textSecondary)),
                ],
              ),
              Icon(Icons.military_tech_rounded, color: PremiumTheme.accentGold.withValues(alpha: 0.8), size: 36),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'CLEARANCE POINTS BALANCE',
            style: TextStyle(fontSize: 9, color: PremiumTheme.textMuted, letterSpacing: 1),
          ),
          const SizedBox(height: 4),
          const Text(
            '12,850 Pts',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          // Progress to Platinum Tier
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tier Progress to Platinum', style: TextStyle(color: PremiumTheme.textSecondary, fontSize: 11)),
              const Text('85%', style: TextStyle(color: PremiumTheme.accentGold, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 0.85,
              backgroundColor: Color(0xFF383321),
              color: PremiumTheme.accentGold,
              minHeight: 6,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOrderHistoryItem(Order order) {
    String statusStr = 'PLACED';
    Color statusColor = PremiumTheme.textSecondary;

    if (order.status == OrderTrackingStatus.processing) {
      statusStr = 'PROCESSING';
      statusColor = PremiumTheme.accentGold;
    } else if (order.status == OrderTrackingStatus.inTransit) {
      statusStr = 'IN FLIGHT';
      statusColor = PremiumTheme.primaryNeon;
    } else if (order.status == OrderTrackingStatus.delivered) {
      statusStr = 'DELIVERED';
      statusColor = PremiumTheme.successGreen;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        borderRadius: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusStr,
                    style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ...order.items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                '${item.laptopName} (${item.quantity}x) - ${item.cpu} | ${item.gpu}',
                style: const TextStyle(color: PremiumTheme.textSecondary, fontSize: 11),
              ),
            )),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Clearance Date: ${order.date}', style: const TextStyle(color: PremiumTheme.textMuted, fontSize: 10)),
                Text(
                  'Paid: \$${order.finalTotal.toInt()}',
                  style: const TextStyle(color: PremiumTheme.primaryNeon, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(color: PremiumTheme.darkBorder, height: 24),
            
            // Custom Timeline Widget based on dynamic state
            Column(
              children: [
                _buildTimelineStep(
                  'Order Authorization', 
                  order.status.index >= 0 ? 'Completed' : 'Scheduled', 
                  order.status.index == 0, 
                  order.status.index >= 1
                ),
                _buildTimelineStep(
                  'Hardware Diagnostics', 
                  order.status.index >= 1 ? 'Completed' : 'Scheduled', 
                  order.status.index == 1, 
                  order.status.index >= 2
                ),
                _buildTimelineStep(
                  'Warp Flight Bay Transit', 
                  order.status.index >= 2 ? (order.status.index == 2 ? 'In Transit' : 'Completed') : 'Scheduled', 
                  order.status.index == 2, 
                  order.status.index >= 3
                ),
                _buildTimelineStep(
                  'Orbit landing Delivery', 
                  order.status.index == 3 ? 'Completed' : 'Scheduled', 
                  order.status.index == 3, 
                  false
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep(String label, String status, bool isActive, bool isCompleted) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Line and Dot
        Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted 
                    ? PremiumTheme.successGreen 
                    : (isActive ? PremiumTheme.primaryNeon : PremiumTheme.darkBorder),
                boxShadow: isCompleted || isActive ? [
                  BoxShadow(
                    color: (isCompleted ? PremiumTheme.successGreen : PremiumTheme.primaryNeon).withValues(alpha: 0.4),
                    blurRadius: 6,
                  )
                ] : null,
              ),
            ),
            Container(
              width: 2,
              height: 30,
              color: isCompleted ? PremiumTheme.successGreen : PremiumTheme.darkBorder,
            )
          ],
        ),
        const SizedBox(width: 16),
        // Text details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isCompleted || isActive ? FontWeight.bold : FontWeight.normal,
                  color: isCompleted || isActive ? Colors.white : PremiumTheme.textSecondary,
                ),
              ),
              Text(
                status,
                style: TextStyle(
                  fontSize: 10,
                  color: isCompleted 
                      ? PremiumTheme.successGreen 
                      : (isActive ? PremiumTheme.primaryNeon : PremiumTheme.textMuted),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
