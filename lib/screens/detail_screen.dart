import 'package:flutter/material.dart';
import '../models/laptop.dart';
import '../models/cart.dart';
import '../theme/colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/tech_tag.dart';
import '../widgets/performance_chart.dart';

import '../services/auth_service.dart';

class DetailScreen extends StatefulWidget {
  final Laptop laptop;

  const DetailScreen({super.key, required this.laptop});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late ConfigOption _selectedCpu;
  late ConfigOption _selectedGpu;
  late ConfigOption _selectedRam;
  late ConfigOption _selectedStorage;

  @override
  void initState() {
    super.initState();
    _selectedCpu = widget.laptop.cpuOptions.first;
    _selectedGpu = widget.laptop.gpuOptions.first;
    _selectedRam = widget.laptop.ramOptions.first;
    _selectedStorage = widget.laptop.storageOptions.first;
  }

  double get _currentTotalPrice {
    return widget.laptop.basePrice +
        _selectedCpu.priceDelta +
        _selectedGpu.priceDelta +
        _selectedRam.priceDelta +
        _selectedStorage.priceDelta;
  }

  void _openWriteReviewDialog() {
    showDialog(
      context: context,
      builder: (context) {
        int tempRating = 5;
        final formKey = GlobalKey<FormState>();
        final currentUserName = AuthService.instance.currentUser.value?.name ?? 'Captain User';
        final nameController = TextEditingController(text: currentUserName);
        final commentController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: GlassCard(
                borderRadius: 24,
                color: PremiumTheme.darkSurfaceCard,
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Form(
                    key: formKey,
                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Submit Rig Evaluation',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      // Stars selector
                      const Text('RATING STRENGTH', style: TextStyle(fontSize: 9, color: PremiumTheme.textMuted, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(5, (index) {
                          final isSelected = index < tempRating;
                          return GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                tempRating = index + 1;
                              });
                            },
                            child: Icon(
                              Icons.star_rounded,
                              size: 32,
                              color: isSelected ? PremiumTheme.accentGold : PremiumTheme.textMuted,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      // Commander name
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Commander Signature Name',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          fillColor: Colors.black.withValues(alpha: 0.2),
                          filled: true,
                        ),
                        style: const TextStyle(fontSize: 13),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Enter a valid signature name.';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Review Comment
                      TextFormField(
                        controller: commentController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Evaluation Log Comments',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          fillColor: Colors.black.withValues(alpha: 0.2),
                          filled: true,
                        ),
                        style: const TextStyle(fontSize: 13),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Enter your comments.';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            child: const Text('ABORT', style: TextStyle(color: PremiumTheme.textSecondary)),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: PremiumTheme.primaryNeon,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('SUBMIT LOG', style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                final newReview = LaptopReview(
                                  username: nameController.text.trim(),
                                  rating: tempRating.toDouble(),
                                  date: DateTime.now().toString().substring(0, 10),
                                  comment: commentController.text.trim(),
                                );
                                
                                setState(() {
                                  widget.laptop.reviews.insert(0, newReview);
                                  widget.laptop.reviewsCount = widget.laptop.reviews.length;
                                  
                                  double sum = 0.0;
                                  for (var r in widget.laptop.reviews) {
                                    sum += r.rating;
                                  }
                                  widget.laptop.rating = sum / widget.laptop.reviewsCount;
                                });

                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: PremiumTheme.darkSurface,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: const BorderSide(color: PremiumTheme.successGreen),
                                    ),
                                    content: const Row(
                                      children: [
                                        Icon(Icons.check_circle_rounded, color: PremiumTheme.successGreen),
                                        SizedBox(width: 12),
                                        Text('Review submitted successfully!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            },
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final isDesktop = width > 800;
    
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Scrollable Content
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Top Custom Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          widget.laptop.brand.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: PremiumTheme.primaryNeon,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.share_rounded),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),

                // Large Laptop image
                SliverToBoxAdapter(
                  child: Center(
                    child: Hero(
                      tag: 'laptop_hero_${widget.laptop.id}',
                      child: Container(
                        height: isDesktop ? 350 : 220,
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Image.network(
                          widget.laptop.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.laptop_chromebook_rounded,
                              size: 140,
                              color: PremiumTheme.textMuted.withValues(alpha: 0.5),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                // Specs Summary list
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                widget.laptop.name,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: PremiumTheme.accentGold.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: PremiumTheme.accentGold.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: PremiumTheme.accentGold, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.laptop.rating.toStringAsFixed(1),
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            TechTag(label: widget.laptop.category, isSecondary: true),
                            const SizedBox(width: 8),
                            Text(
                              '(${widget.laptop.reviewsCount} Commander Reviews)',
                              style: const TextStyle(fontSize: 12, color: PremiumTheme.textMuted),
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Overview',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.laptop.description,
                          style: const TextStyle(color: PremiumTheme.textSecondary, fontSize: 13, height: 1.6),
                        ),
                      ],
                    ),
                  ),
                ),

                // Responsive spec customizer vs radar chart
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                  sliver: SliverToBoxAdapter(
                    child: isDesktop 
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 3, child: _buildConfigurator()),
                              const SizedBox(width: 40),
                              Expanded(flex: 2, child: _buildPerformanceChart()),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildConfigurator(),
                              const SizedBox(height: 24),
                              _buildPerformanceChart(),
                            ],
                          ),
                  ),
                ),

                // Hardware Static Spec Sheets
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rig Hardware Specifications',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        GlassCard(
                          borderRadius: 16,
                          child: Column(
                            children: [
                              _buildSpecRow('Display', widget.laptop.display),
                              const Divider(color: PremiumTheme.darkBorder),
                              _buildSpecRow('Base CPU', widget.laptop.cpu),
                              const Divider(color: PremiumTheme.darkBorder),
                              _buildSpecRow('Base GPU', widget.laptop.gpu),
                              const Divider(color: PremiumTheme.darkBorder),
                              _buildSpecRow('Battery', widget.laptop.battery),
                              const Divider(color: PremiumTheme.darkBorder),
                              _buildSpecRow('Weight', '${widget.laptop.weight} kg'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Reviews Section with write review action
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 100.0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Commander Reviews',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            TextButton.icon(
                              onPressed: _openWriteReviewDialog,
                              icon: const Icon(Icons.rate_review_rounded, size: 16, color: PremiumTheme.primaryNeon),
                              label: const Text(
                                'Write Review',
                                style: TextStyle(color: PremiumTheme.primaryNeon, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...widget.laptop.reviews.map((rev) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: GlassCard(
                            borderRadius: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      rev.username,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    Text(rev.date, style: const TextStyle(color: PremiumTheme.textMuted, fontSize: 11)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: List.generate(5, (index) => Icon(
                                    Icons.star_rounded,
                                    size: 14,
                                    color: index < rev.rating.floor() ? PremiumTheme.accentGold : PremiumTheme.textMuted,
                                  )),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  rev.comment,
                                  style: const TextStyle(color: PremiumTheme.textSecondary, fontSize: 12),
                                )
                              ],
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Bottom Sticky Action Bar
            Positioned(
              bottom: 16,
              left: 20,
              right: 20,
              child: GlassCard(
                borderRadius: 24,
                blur: 16.0,
                color: PremiumTheme.darkSurfaceCard,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ESTIMATED COST',
                          style: TextStyle(fontSize: 9, color: PremiumTheme.textMuted, letterSpacing: 1),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) => SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, 0.3),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                          child: Text(
                            '\$${_currentTotalPrice.toInt()}',
                            key: ValueKey<double>(_currentTotalPrice),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: PremiumTheme.primaryNeon,
                            ),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PremiumTheme.primaryNeon,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                      ),
                      onPressed: () {
                        // Add to Cart Logic
                        final cartItem = CartItem(
                          laptop: widget.laptop,
                          selectedCpu: _selectedCpu.name,
                          selectedGpu: _selectedGpu.name,
                          selectedRam: _selectedRam.name,
                          selectedStorage: _selectedStorage.name,
                          totalPrice: _currentTotalPrice,
                        );
                        CartManager.addToCart(cartItem);
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: PremiumTheme.darkSurface,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: PremiumTheme.primaryNeon, width: 1),
                            ),
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_outline_rounded, color: PremiumTheme.successGreen),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '${widget.laptop.name} loaded into Cargo Dock!',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.shopping_cart_outlined, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'LOAD DOCK',
                            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: PremiumTheme.textSecondary, fontSize: 13)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigurator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Customize Specifications',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 16),
        _buildConfigSection('Processor CPU', widget.laptop.cpuOptions, _selectedCpu, (val) {
          setState(() {
            _selectedCpu = val;
          });
        }),
        const SizedBox(height: 16),
        _buildConfigSection('Graphics GPU', widget.laptop.gpuOptions, _selectedGpu, (val) {
          setState(() {
            _selectedGpu = val;
          });
        }),
        const SizedBox(height: 16),
        _buildConfigSection('Memory RAM', widget.laptop.ramOptions, _selectedRam, (val) {
          setState(() {
            _selectedRam = val;
          });
        }),
        const SizedBox(height: 16),
        _buildConfigSection('Storage SSD', widget.laptop.storageOptions, _selectedStorage, (val) {
          setState(() {
            _selectedStorage = val;
          });
        }),
      ],
    );
  }

  Widget _buildConfigSection(
    String title, 
    List<ConfigOption> options, 
    ConfigOption selected, 
    ValueChanged<ConfigOption> onChange,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: PremiumTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((opt) {
            final isSel = selected.name == opt.name;
            final deltaText = opt.priceDelta == 0 
                ? '' 
                : (opt.priceDelta > 0 ? ' (+\$${opt.priceDelta.toInt()})' : ' (-\$${opt.priceDelta.abs().toInt()})');
            return ChoiceChip(
              label: Text('${opt.name}$deltaText'),
              selected: isSel,
              onSelected: (selected) {
                if (selected) {
                  onChange(opt);
                }
              },
              selectedColor: PremiumTheme.primaryNeon.withValues(alpha: 0.15),
              backgroundColor: Colors.transparent,
              side: BorderSide(
                color: isSel ? PremiumTheme.primaryNeon : PremiumTheme.darkBorder,
              ),
              labelStyle: TextStyle(
                color: isSel ? Colors.white : PremiumTheme.textSecondary,
                fontSize: 11,
                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPerformanceChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Benchmark Performance Radar',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 24),
        Center(
          child: PerformanceChart(
            scores: {
              'Gaming': widget.laptop.gamingScore,
              'Coding': widget.laptop.codingScore,
              'Productivity': widget.laptop.productivityScore,
              'Battery': widget.laptop.batteryScore,
            },
            size: 200,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Score indicators represent hardware benchmarks tested under full workload environments.',
          textAlign: TextAlign.center,
          style: TextStyle(color: PremiumTheme.textMuted, fontSize: 10),
        ),
      ],
    );
  }
}
