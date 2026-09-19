import 'package:flutter/material.dart';
import '../models/laptop.dart';
import '../services/auth_service.dart';
import '../services/laptop_service.dart';
import '../theme/colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/tech_tag.dart';
import 'detail_screen.dart';
import 'main_navigation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LaptopService _laptopService = LaptopService();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedBrand = 'All';
  String _selectedCategory = 'All';
  String _sortBy = 'Default';
  
  // Quick filters from bottom sheet
  double _maxPrice = 4000;
  
  late final List<String> _brands;
  late final List<String> _categories;
  final List<String> _sortOptions = ['Default', 'Price: Low to High', 'Price: High to Low', 'Highest Rating'];

  @override
  void initState() {
    super.initState();
    _brands = _laptopService.getBrands();
    _categories = _laptopService.getCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _selectedBrand = 'All';
      _selectedCategory = 'All';
      _maxPrice = 4000;
      _sortBy = 'Default';
    });
  }

  List<Laptop> get _filteredLaptops {
    return _laptopService.filterAndSort(
      query: _searchQuery,
      brand: _selectedBrand,
      category: _selectedCategory,
      maxPrice: _maxPrice,
      sortBy: _sortBy,
    );
  }

  void _openFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return GlassCard(
              borderRadius: 30,
              color: PremiumTheme.darkSurfaceCard,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: PremiumTheme.textMuted,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Refine Fleet Filters',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Price Range Slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Max Budget Limit',
                          style: TextStyle(color: PremiumTheme.textSecondary),
                        ),
                        Text(
                          '\$${_maxPrice.toInt()}',
                          style: const TextStyle(
                            color: PremiumTheme.primaryNeon,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: PremiumTheme.primaryNeon,
                        inactiveTrackColor: PremiumTheme.darkBorder,
                        thumbColor: PremiumTheme.secondaryNeon,
                        overlayColor: PremiumTheme.secondaryNeon.withValues(alpha: 0.2),
                      ),
                      child: Slider(
                        min: 1000,
                        max: 4000,
                        divisions: 12,
                        value: _maxPrice,
                        onChanged: (val) {
                          setModalState(() {
                            _maxPrice = val;
                          });
                          setState(() {
                            _maxPrice = val;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Usage Category',
                      style: TextStyle(color: PremiumTheme.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((category) {
                        final isSel = _selectedCategory == category;
                        return ChoiceChip(
                          label: Text(category),
                          selected: isSel,
                          onSelected: (selected) {
                            setModalState(() {
                              _selectedCategory = category;
                            });
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          selectedColor: PremiumTheme.primaryNeon.withValues(alpha: 0.2),
                          backgroundColor: Colors.transparent,
                          side: BorderSide(
                            color: isSel ? PremiumTheme.primaryNeon : PremiumTheme.darkBorder,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PremiumTheme.primaryNeon,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'APPLY FILTERS',
                          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
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
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ValueListenableBuilder(
                          valueListenable: AuthService.instance.currentUser,
                          builder: (context, user, _) {
                            final name = user?.name.split(' ').first ?? 'Captain';
                            return Text(
                              'Welcome $name,',
                              style: const TextStyle(
                                color: PremiumTheme.textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Find Your Ultimate Rig',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    // Glass action button (e.g. notifications)
                    GlassCard(
                      borderRadius: 12,
                      padding: const EdgeInsets.all(10),
                      child: const Badge(
                        label: Text('3', style: TextStyle(fontSize: 8)),
                        child: Icon(Icons.notifications_none_rounded, size: 20),
                      ),
                    )
                  ],
                ),
              ),
            ),

            // Admin Mode Banner if current user is admin
            ValueListenableBuilder(
              valueListenable: AuthService.instance.currentUser,
              builder: (context, user, _) {
                if (user?.isAdmin != true) return const SliverToBoxAdapter(child: SizedBox.shrink());
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2A1C00), Color(0xFF1E1400)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: const Color(0xFFFFB300).withValues(alpha: 0.5),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFB300).withValues(alpha: 0.12),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                      child: Row(
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'ADMINISTRATOR MODE',
                                      style: TextStyle(
                                        color: Color(0xFFFFB300),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: const Color(0xFFFFB300).withValues(alpha: 0.2),
                                      ),
                                      child: const Text(
                                        'ACTIVE',
                                        style: TextStyle(color: Color(0xFFFFB300), fontSize: 9, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Browsing Website Store • Access Admin Controls anytime',
                                  style: TextStyle(
                                    color: PremiumTheme.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFB300),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 2,
                            ),
                            icon: const Icon(Icons.dashboard_rounded, size: 14),
                            label: const Text(
                              'Dashboard',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                            onPressed: () {
                              MainNavigationContainer.switchTab(context, 5);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Search Bar & Filter Button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: GlassCard(
                        borderRadius: 16,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val;
                            });
                          },
                          decoration: InputDecoration(
                            icon: const Icon(Icons.search_rounded, color: PremiumTheme.textSecondary),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded, size: 18, color: PremiumTheme.textMuted),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            hintText: 'Search laptops, CPUs, brands...',
                            hintStyle: const TextStyle(color: PremiumTheme.textMuted, fontSize: 14),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Filter Glass Card
                    GestureDetector(
                      onTap: _openFilterBottomSheet,
                      child: GlassCard(
                        borderRadius: 16,
                        padding: const EdgeInsets.all(14),
                        color: PremiumTheme.darkSurfaceCard,
                        child: const Icon(
                          Icons.tune_rounded,
                          color: PremiumTheme.primaryNeon,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Brand Horizontal List
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 20, right: 8),
                    itemCount: _brands.length,
                    itemBuilder: (context, index) {
                      final brand = _brands[index];
                      final isSelected = _selectedBrand == brand;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedBrand = brand;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: isSelected ? PremiumTheme.primaryGradient : null,
                              color: isSelected ? null : PremiumTheme.darkSurfaceCard.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected 
                                    ? Colors.transparent 
                                    : PremiumTheme.darkBorder.withValues(alpha: 0.4),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              brand,
                              style: TextStyle(
                                color: isSelected ? Colors.black : PremiumTheme.textSecondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Usage category Tab Bar with sorting dropdown
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Fleet Categorization',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '${_filteredLaptops.length} rigs',
                          style: const TextStyle(
                            fontSize: 11,
                            color: PremiumTheme.textMuted,
                          ),
                        ),
                        const SizedBox(width: 12),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _sortBy,
                            icon: const Icon(Icons.sort_rounded, size: 14, color: PremiumTheme.primaryNeon),
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            dropdownColor: PremiumTheme.darkSurfaceCard,
                            borderRadius: BorderRadius.circular(12),
                            onChanged: (String? value) {
                              if (value != null) {
                                setState(() {
                                  _sortBy = value;
                                });
                              }
                            },
                            items: _sortOptions.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Categorized Quick Selection Row
            SliverToBoxAdapter(
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 20, right: 8),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSel = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: ActionChip(
                        label: Text(
                          category,
                          style: TextStyle(
                            color: isSel ? Colors.black : Colors.white,
                            fontSize: 11,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        backgroundColor: isSel ? PremiumTheme.primaryNeon : PremiumTheme.darkBg,
                        onPressed: () {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        side: BorderSide(
                          color: isSel ? Colors.transparent : PremiumTheme.darkBorder,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Large Product Grid or Clean Empty State
            if (_filteredLaptops.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  child: GlassCard(
                    borderRadius: 24,
                    padding: const EdgeInsets.all(32),
                    color: PremiumTheme.darkSurfaceCard,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: PremiumTheme.textMuted.withValues(alpha: 0.6),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No Fleet Rigs Found',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'No laptops match your search criteria or price filters. Try adjusting your search query or reset filters.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: PremiumTheme.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: PremiumTheme.primaryNeon,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('RESET FILTERS', style: TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: _resetFilters,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isDesktop ? 3 : (width > 600 ? 2 : 1),
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final laptop = _filteredLaptops[index];
                    return Hero(
                      tag: 'laptop_hero_${laptop.id}',
                      child: GlassCard(
                        borderRadius: 24,
                        padding: EdgeInsets.zero,
                        color: PremiumTheme.darkSurfaceCard,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailScreen(laptop: laptop),
                            ),
                          ).then((_) {
                            // Trigger state rebuild in case ratings changed
                            setState(() {});
                          });
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1. Laptop image with dynamic loading
                            Expanded(
                              flex: 12,
                              child: Stack(
                                children: [
                                  // Gradient overlay behind image
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(24),
                                          topRight: Radius.circular(24),
                                        ),
                                        gradient: LinearGradient(
                                          colors: [
                                            PremiumTheme.secondaryNeon.withValues(alpha: 0.04),
                                            Colors.transparent,
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Product image
                                  Positioned.fill(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Image.network(
                                        laptop.imageUrl,
                                        fit: BoxFit.contain,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return const Center(
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) {
                                          // Sleek Vector Silhouette Fallback
                                          return Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.laptop_chromebook_rounded,
                                                  size: 64,
                                                  color: PremiumTheme.textMuted.withValues(alpha: 0.6),
                                                ),
                                                const SizedBox(height: 8),
                                                const Text(
                                                  'Laptop Premium Silhouette',
                                                  style: TextStyle(fontSize: 10, color: PremiumTheme.textMuted),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  // Rating tag top left
                                  Positioned(
                                    top: 12,
                                    left: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.6),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.star_rounded, color: PremiumTheme.accentGold, size: 14),
                                          const SizedBox(width: 4),
                                          Text(
                                            laptop.rating.toStringAsFixed(1),
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Brand badge top right
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: TechTag(
                                      label: laptop.brand,
                                      isSecondary: laptop.brand == 'Apple',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // 2. Info area
                            Expanded(
                              flex: 10,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      laptop.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      laptop.cpu,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: PremiumTheme.textSecondary,
                                      ),
                                    ),
                                    const Spacer(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Price
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Base Cost',
                                              style: TextStyle(fontSize: 9, color: PremiumTheme.textMuted),
                                            ),
                                            Text(
                                              '\$${laptop.basePrice.toInt()}',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w900,
                                                color: PremiumTheme.primaryNeon,
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Action icon
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: PremiumTheme.primaryNeon.withValues(alpha: 0.08),
                                          ),
                                          child: const Icon(
                                            Icons.arrow_forward_rounded,
                                            color: PremiumTheme.primaryNeon,
                                            size: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: _filteredLaptops.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
