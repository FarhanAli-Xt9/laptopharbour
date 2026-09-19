import 'package:flutter/material.dart';
import '../models/cart.dart';
import '../models/order.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';
import '../theme/colors.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../widgets/glass_card.dart';
import 'main_navigation_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _promoController = TextEditingController();
  double _promoDiscountPercentage = 0.0;
  String? _appliedPromoCode;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _applyPromo() {
    final code = _promoController.text.trim().toUpperCase();
    if (AppConstants.promoCodes.containsKey(code)) {
      final discount = AppConstants.promoCodes[code]!;
      setState(() {
        _promoDiscountPercentage = discount;
        _appliedPromoCode = '$code (${(discount * 100).toInt()}% Off)';
      });
      _showToast('Promo Code $code applied! Saved ${(discount * 100).toInt()}%.', true);
    } else {
      _showToast('Invalid promo code. Try HARBOUR20 or PILOT10.', false);
    }
  }

  void _showToast(String msg, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: PremiumTheme.darkSurface,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSuccess ? PremiumTheme.successGreen : PremiumTheme.errorRed,
            width: 1,
          ),
        ),
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_outline_rounded : Icons.error_outline_rounded,
              color: isSuccess ? PremiumTheme.successGreen : PremiumTheme.errorRed,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _triggerCheckout(double subtotal, double tax, double shipping, double discount, double finalTotal) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return CheckoutModal(
          subtotal: subtotal,
          tax: tax,
          shippingFee: shipping,
          discount: discount,
          finalTotal: finalTotal,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: ValueListenableBuilder<List<CartItem>>(
            valueListenable: CartService.instance.items,
            builder: (context, cartItems, child) {
              if (cartItems.isEmpty) {
                return _buildEmptyState();
              }

              final cartService = CartService.instance;
              final subtotal = cartService.subtotal;
              final discount = cartService.calculateDiscount(subtotal, _promoDiscountPercentage);
              final tax = cartService.calculateTax(subtotal);
              final shipping = cartService.calculateShipping(subtotal);
              final finalTotal = cartService.calculateFinalTotal(
                subtotalAmount: subtotal,
                taxAmount: tax,
                shippingAmount: shipping,
                discountAmount: discount,
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Cargo Dock Cargo',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: PremiumTheme.primaryNeon.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: PremiumTheme.primaryNeon.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          '${cartService.totalItemCount} items',
                          style: const TextStyle(
                            color: PremiumTheme.primaryNeon,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Review your configuration orders before submitting payment clearance.',
                    style: TextStyle(
                      fontSize: 13,
                      color: PremiumTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cart list
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: GlassCard(
                            borderRadius: 20,
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Thumbnail
                                Container(
                                  width: 80,
                                  height: 80,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Image.network(
                                    item.laptop.imageUrl,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) => const Icon(
                                      Icons.laptop_chromebook_rounded,
                                      color: PremiumTheme.textMuted,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.laptop.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline_rounded,
                                              color: PremiumTheme.errorRed,
                                              size: 18,
                                            ),
                                            onPressed: () => CartService.instance.removeFromCart(item),
                                            constraints: const BoxConstraints(),
                                            padding: EdgeInsets.zero,
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'CPU: ${item.selectedCpu}\nGPU: ${item.selectedGpu}\nRAM: ${item.selectedRam} | SSD: ${item.selectedStorage}',
                                        style: const TextStyle(
                                          color: PremiumTheme.textMuted,
                                          fontSize: 10,
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 8),

                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '\$${(item.totalPrice * item.quantity).toInt()}',
                                            style: const TextStyle(
                                              color: PremiumTheme.primaryNeon,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          // Counter
                                          Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () => CartService.instance.updateQuantity(item, -1),
                                                child: Container(
                                                  padding: const EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(color: PremiumTheme.darkBorder),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: const Icon(Icons.remove, size: 12),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                                child: Text(
                                                  item.quantity.toString(),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () => CartService.instance.updateQuantity(item, 1),
                                                child: Container(
                                                  padding: const EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(color: PremiumTheme.darkBorder),
                                                    borderRadius: BorderRadius.circular(6),
                                                    color: PremiumTheme.primaryNeon.withValues(alpha: 0.08),
                                                  ),
                                                  child: const Icon(Icons.add, size: 12, color: PremiumTheme.primaryNeon),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Promo code and summary
                  GlassCard(
                    borderRadius: 24,
                    color: PremiumTheme.darkSurfaceCard,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Promo Field
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _promoController,
                                decoration: InputDecoration(
                                  hintText: 'Promo Code (HARBOUR20 / PILOT10)',
                                  hintStyle: const TextStyle(color: PremiumTheme.textMuted, fontSize: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: PremiumTheme.darkBorder),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  fillColor: Colors.black.withValues(alpha: 0.2),
                                  filled: true,
                                ),
                                style: const TextStyle(fontSize: 12, color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: PremiumTheme.secondaryNeon,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _applyPromo,
                              child: const Text('Apply', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                            )
                          ],
                        ),
                        if (_appliedPromoCode != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Active Promo: $_appliedPromoCode',
                            style: const TextStyle(color: PremiumTheme.successGreen, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                        const SizedBox(height: 16),

                        // Subtotal rows
                        _buildSummaryRow('Subtotal', '\$${subtotal.toInt()}'),
                        if (discount > 0) ...[
                          const SizedBox(height: 6),
                          _buildSummaryRow('Fleet Promo Discount', '-\$${discount.toInt()}', isDiscount: true),
                        ],
                        const SizedBox(height: 6),
                        _buildSummaryRow('Simulated Tax (8%)', '\$${tax.toInt()}'),
                        const SizedBox(height: 6),
                        _buildSummaryRow('Freight Clearance', shipping == 0 ? 'FREE' : '\$${shipping.toInt()}'),
                        const Divider(color: PremiumTheme.darkBorder, height: 20),
                        _buildSummaryRow('Clearance Final Total', '\$${finalTotal.toInt()}', isTotal: true),

                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: PremiumTheme.primaryNeon,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () => _triggerCheckout(subtotal, tax, shipping, discount, finalTotal),
                          child: const Text(
                            'PROCEED TO CLEARANCE',
                            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: PremiumTheme.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Cargo Dock is Empty',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Set coordinates to the fleet dashboard to add your custom configured rigs.',
              textAlign: TextAlign.center,
              style: TextStyle(color: PremiumTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: PremiumTheme.primaryNeon,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.explore_rounded, size: 18),
              label: const Text(
                'EXPLORE FLEET RIGS',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              onPressed: () {
                MainNavigationContainer.switchTab(context, 0);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isDiscount = false, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.white : PremiumTheme.textSecondary,
            fontSize: isTotal ? 14 : 12,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isDiscount
                ? PremiumTheme.successGreen
                : (isTotal ? PremiumTheme.primaryNeon : Colors.white),
            fontSize: isTotal ? 18 : 12,
            fontWeight: isTotal || isDiscount ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

/// Comprehensive, validated checkout dialog supporting customer details,
/// demo payment methods, diagnostic processing state, and order ID generation.
class CheckoutModal extends StatefulWidget {
  final double subtotal;
  final double tax;
  final double shippingFee;
  final double discount;
  final double finalTotal;

  const CheckoutModal({
    super.key,
    required this.subtotal,
    required this.tax,
    required this.shippingFee,
    required this.discount,
    required this.finalTotal,
  });

  @override
  State<CheckoutModal> createState() => _CheckoutModalState();
}

class _CheckoutModalState extends State<CheckoutModal> {
  int _stage = 0; // 0: Customer & Shipping, 1: Payment, 2: Diagnostics, 3: Success

  final _shippingFormKey = GlobalKey<FormState>();
  final _paymentFormKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addrController;

  final TextEditingController _cardController = TextEditingController(text: '4111 8899 7755 3300');
  final TextEditingController _expController = TextEditingController(text: '08/28');
  final TextEditingController _cvvController = TextEditingController(text: '884');

  String _selectedPaymentMethod = AppConstants.demoPaymentMethods[0];
  String _generatedOrderId = '';

  @override
  void initState() {
    super.initState();
    final user = AuthService.instance.currentUser.value;
    _nameController = TextEditingController(text: user?.name ?? 'Captain User');
    _emailController = TextEditingController(text: user?.email ?? 'captain@harbour.com');
    _phoneController = TextEditingController(text: '+1 415-555-0199');
    _addrController = TextEditingController(text: '72 sector-X, Cyber Harbour, SF 94103');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addrController.dispose();
    _cardController.dispose();
    _expController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _nextStage() {
    if (_stage == 0) {
      if (_shippingFormKey.currentState!.validate()) {
        setState(() => _stage = 1);
      }
    } else if (_stage == 1) {
      // Validate payment if credit card is selected
      if (_selectedPaymentMethod == AppConstants.demoPaymentMethods[0]) {
        if (!_paymentFormKey.currentState!.validate()) {
          return;
        }
      }

      setState(() => _stage = 2);

      // Create Order in OrderService
      final cartItems = CartService.instance.items.value;
      final orderItems = cartItems
          .map((c) => OrderItemInfo(
                laptopName: c.laptop.name,
                brand: c.laptop.brand,
                imageUrl: c.laptop.imageUrl,
                cpu: c.selectedCpu,
                gpu: c.selectedGpu,
                ram: c.selectedRam,
                storage: c.selectedStorage,
                singlePrice: c.totalPrice,
                quantity: c.quantity,
              ))
          .toList();

      final createdOrder = OrderService.instance.createOrder(
        items: orderItems,
        customerName: _nameController.text.trim(),
        customerEmail: _emailController.text.trim(),
        customerPhone: _phoneController.text.trim(),
        shippingAddress: _addrController.text.trim(),
        paymentMethod: _selectedPaymentMethod,
        subtotal: widget.subtotal,
        tax: widget.tax,
        shippingFee: widget.shippingFee,
        finalTotal: widget.finalTotal,
      );

      _generatedOrderId = createdOrder.id;

      // Simulated diagnostic clearance delays
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _stage = 3);
        }
      });
    } else if (_stage == 3) {
      CartService.instance.clearCart();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: GlassCard(
        borderRadius: 24,
        color: PremiumTheme.darkSurfaceCard,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getStageTitle(),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  if (_stage < 2)
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: PremiumTheme.textMuted),
                      onPressed: () => Navigator.pop(context),
                    )
                ],
              ),
              const Divider(color: PremiumTheme.darkBorder, height: 24),

              // Content based on stage
              _buildStageContent(),
              const SizedBox(height: 24),

              // Action Button
              if (_stage != 2)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _stage == 3 ? PremiumTheme.successGreen : PremiumTheme.primaryNeon,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _nextStage,
                    child: Text(
                      _getStageBtnText(),
                      style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStageTitle() {
    switch (_stage) {
      case 0:
        return 'Shipping Coordinates';
      case 1:
        return 'Clearance Gateway';
      case 2:
        return 'Diagnostic System Integrity';
      case 3:
        return 'Clearance Successful';
      default:
        return '';
    }
  }

  String _getStageBtnText() {
    switch (_stage) {
      case 0:
        return 'VALIDATE & PROCEED TO PAYMENT';
      case 1:
        return 'AUTHORIZE CLEARANCE (\$${widget.finalTotal.toInt()})';
      case 3:
        return 'DOCK SHIPMENT & EXIT';
      default:
        return 'CONTINUE';
    }
  }

  Widget _buildStageContent() {
    switch (_stage) {
      case 0:
        return Form(
          key: _shippingFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Recipient Name',
                  prefixIcon: const Icon(Icons.person_outline_rounded, color: PremiumTheme.textSecondary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  fillColor: Colors.black.withValues(alpha: 0.2),
                  filled: true,
                ),
                style: const TextStyle(fontSize: 13),
                validator: (val) => Validators.validateName(val, fieldName: 'Recipient name'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Clearance Email Address',
                  prefixIcon: const Icon(Icons.email_outlined, color: PremiumTheme.textSecondary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  fillColor: Colors.black.withValues(alpha: 0.2),
                  filled: true,
                ),
                style: const TextStyle(fontSize: 13),
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Contact Phone Number',
                  prefixIcon: const Icon(Icons.phone_outlined, color: PremiumTheme.textSecondary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  fillColor: Colors.black.withValues(alpha: 0.2),
                  filled: true,
                ),
                style: const TextStyle(fontSize: 13),
                validator: Validators.validatePhone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addrController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Shipping Destination Address',
                  prefixIcon: const Icon(Icons.location_on_outlined, color: PremiumTheme.textSecondary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  fillColor: Colors.black.withValues(alpha: 0.2),
                  filled: true,
                ),
                style: const TextStyle(fontSize: 13),
                validator: Validators.validateAddress,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.speed_rounded, color: PremiumTheme.primaryNeon, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Express Cargo Freight (2-3 Space Days)',
                    style: TextStyle(color: PremiumTheme.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        );

      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PAYMENT CLEARANCE METHOD',
              style: TextStyle(fontSize: 10, color: PremiumTheme.textMuted, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Payment method selector – uses RadioGroup (Flutter 3.32+)
            RadioGroup<String>(
              groupValue: _selectedPaymentMethod,
              onChanged: (val) {
                if (val != null) setState(() => _selectedPaymentMethod = val);
              },
              child: Column(
                children: AppConstants.demoPaymentMethods.map((method) {
                  final isSel = _selectedPaymentMethod == method;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedPaymentMethod = method),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSel ? PremiumTheme.primaryNeon : PremiumTheme.darkBorder,
                        ),
                        color: isSel
                            ? PremiumTheme.primaryNeon.withValues(alpha: 0.08)
                            : Colors.transparent,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        child: Row(
                          children: [
                            Radio<String>(
                              value: method,
                              activeColor: PremiumTheme.primaryNeon,
                            ),
                            Text(
                              method,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                color: isSel ? Colors.white : PremiumTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 12),

            if (_selectedPaymentMethod == AppConstants.demoPaymentMethods[0]) ...[
              Form(
                key: _paymentFormKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _cardController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Credit Card Number (Demo)',
                        prefixIcon: const Icon(Icons.credit_card_rounded, color: PremiumTheme.primaryNeon),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        fillColor: Colors.black.withValues(alpha: 0.2),
                        filled: true,
                      ),
                      style: const TextStyle(fontSize: 13),
                      validator: Validators.validateCardNumber,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _expController,
                            decoration: InputDecoration(
                              labelText: 'Exp (MM/YY)',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              fillColor: Colors.black.withValues(alpha: 0.2),
                              filled: true,
                            ),
                            style: const TextStyle(fontSize: 13),
                            validator: Validators.validateCardExpiry,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _cvvController,
                            obscureText: true,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'CVV (3-4 digits)',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              fillColor: Colors.black.withValues(alpha: 0.2),
                              filled: true,
                            ),
                            style: const TextStyle(fontSize: 13),
                            validator: Validators.validateCvv,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black.withValues(alpha: 0.3),
                  border: Border.all(color: PremiumTheme.darkBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: PremiumTheme.primaryNeon),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedPaymentMethod.contains('Crypto')
                            ? 'Simulated Crypto Node settlement. Token allowance will be verified instantly upon authorization.'
                            : 'Pay upon delivery at the freight arrival dock. Cash and electronic terminal accepted.',
                        style: const TextStyle(fontSize: 11, color: PremiumTheme.textSecondary),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ],
        );

      case 2:
        return const Column(
          children: [
            SizedBox(height: 24),
            CircularProgressIndicator(color: PremiumTheme.primaryNeon),
            SizedBox(height: 24),
            Text(
              'Running security diagnostic integrity checks...',
              style: TextStyle(color: PremiumTheme.textSecondary, fontSize: 13),
            ),
            SizedBox(height: 12),
            Text(
              'DO NOT OFF-LOAD POWER CURRENT',
              style: TextStyle(
                color: PremiumTheme.accentGold,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: 12),
          ],
        );

      case 3:
        return Column(
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: PremiumTheme.successGreen,
              ),
              child: const Icon(Icons.check_rounded, color: Colors.black, size: 40),
            ),
            const SizedBox(height: 24),
            const Text(
              'Clearance Approved',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Order ID: $_generatedOrderId has been successfully authorized.\n\nAn order confirmation email containing your diagnostic clearance invoice has been sent to ${_emailController.text.trim()}.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: PremiumTheme.textSecondary, fontSize: 12, height: 1.5),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
