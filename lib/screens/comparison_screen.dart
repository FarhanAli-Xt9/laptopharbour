import 'package:flutter/material.dart';
import '../models/laptop.dart';
import '../services/mock_laptop_data.dart';
import '../theme/colors.dart';
import '../widgets/glass_card.dart';


class ComparisonScreen extends StatefulWidget {
  const ComparisonScreen({super.key});

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  Laptop? _laptopA;
  Laptop? _laptopB;

  @override
  void initState() {
    super.initState();
    // Default select first two items
    if (mockLaptops.length >= 2) {
      _laptopA = mockLaptops[0];
      _laptopB = mockLaptops[1];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Rig Comparison Engine',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Select two rigs to perform side-by-side benchmark diagnostics.',
                style: TextStyle(
                  fontSize: 13,
                  color: PremiumTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              
              // Selectors Row
              Row(
                children: [
                  Expanded(child: _buildLaptopSelector(true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildLaptopSelector(false)),
                ],
              ),
              const SizedBox(height: 24),

              // Specifications Comparison Grid
              Expanded(
                child: _laptopA == null || _laptopB == null
                    ? const Center(child: Text('Select two rigs to diagnose.'))
                    : ListView(
                        physics: const BouncingScrollPhysics(),
                        children: [
                          // Graphic representations side-by-side
                          Row(
                            children: [
                              Expanded(child: _buildVisualPanel(_laptopA!)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildVisualPanel(_laptopB!)),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // Header Spec Label
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'HARDWARE HARBOUR DIAGNOSTIC',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                color: PremiumTheme.primaryNeon,
                              ),
                            ),
                          ),

                          GlassCard(
                            borderRadius: 16,
                            child: Column(
                              children: [
                                _buildComparisonRow(
                                  'Base Price',
                                  '\$${_laptopA!.basePrice.toInt()}',
                                  '\$${_laptopB!.basePrice.toInt()}',
                                  isBetter: _laptopA!.basePrice < _laptopB!.basePrice,
                                  isEqual: _laptopA!.basePrice == _laptopB!.basePrice,
                                ),
                                const Divider(color: PremiumTheme.darkBorder),
                                _buildComparisonRow(
                                  'Weight',
                                  '${_laptopA!.weight} kg',
                                  '${_laptopB!.weight} kg',
                                  isBetter: _laptopA!.weight < _laptopB!.weight,
                                  isEqual: _laptopA!.weight == _laptopB!.weight,
                                ),
                                const Divider(color: PremiumTheme.darkBorder),
                                _buildComparisonRow(
                                  'Processor CPU',
                                  _laptopA!.cpu,
                                  _laptopB!.cpu,
                                  isBetter: null, // text description
                                ),
                                const Divider(color: PremiumTheme.darkBorder),
                                _buildComparisonRow(
                                  'Graphics GPU',
                                  _laptopA!.gpu,
                                  _laptopB!.gpu,
                                  isBetter: null, // text description
                                ),
                                const Divider(color: PremiumTheme.darkBorder),
                                _buildComparisonRow(
                                  'Battery capacity',
                                  _laptopA!.battery,
                                  _laptopB!.battery,
                                  isBetter: null,
                                ),
                                const Divider(color: PremiumTheme.darkBorder),
                                _buildComparisonRow(
                                  'Product Display',
                                  _laptopA!.display,
                                  _laptopB!.display,
                                  isBetter: null,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),
                          // Performance benchmark labels
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'BENCHMARK SCORES DIAGNOSTIC',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                color: PremiumTheme.secondaryNeon,
                              ),
                            ),
                          ),

                          GlassCard(
                            borderRadius: 16,
                            child: Column(
                              children: [
                                _buildComparisonRow(
                                  'Coding & Dev',
                                  '${_laptopA!.codingScore}%',
                                  '${_laptopB!.codingScore}%',
                                  isBetter: _laptopA!.codingScore > _laptopB!.codingScore,
                                  isEqual: _laptopA!.codingScore == _laptopB!.codingScore,
                                ),
                                const Divider(color: PremiumTheme.darkBorder),
                                _buildComparisonRow(
                                  'Gaming Rig Performance',
                                  '${_laptopA!.gamingScore}%',
                                  '${_laptopB!.gamingScore}%',
                                  isBetter: _laptopA!.gamingScore > _laptopB!.gamingScore,
                                  isEqual: _laptopA!.gamingScore == _laptopB!.gamingScore,
                                ),
                                const Divider(color: PremiumTheme.darkBorder),
                                _buildComparisonRow(
                                  'Productivity',
                                  '${_laptopA!.productivityScore}%',
                                  '${_laptopB!.productivityScore}%',
                                  isBetter: _laptopA!.productivityScore > _laptopB!.productivityScore,
                                  isEqual: _laptopA!.productivityScore == _laptopB!.productivityScore,
                                ),
                                const Divider(color: PremiumTheme.darkBorder),
                                _buildComparisonRow(
                                  'Battery Endurance',
                                  '${_laptopA!.batteryScore}%',
                                  '${_laptopB!.batteryScore}%',
                                  isBetter: _laptopA!.batteryScore > _laptopB!.batteryScore,
                                  isEqual: _laptopA!.batteryScore == _laptopB!.batteryScore,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLaptopSelector(bool isLeft) {
    final activeLaptop = isLeft ? _laptopA : _laptopB;
    return GlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Laptop>(
          value: activeLaptop,
          hint: const Text('Pick Rig', style: TextStyle(fontSize: 13)),
          isExpanded: true,
          dropdownColor: PremiumTheme.darkSurfaceCard,
          borderRadius: BorderRadius.circular(16),
          items: mockLaptops.map((laptop) {
            return DropdownMenuItem<Laptop>(
              value: laptop,
              child: Text(
                laptop.name,
                style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              if (isLeft) {
                _laptopA = val;
              } else {
                _laptopB = val;
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildVisualPanel(Laptop laptop) {
    return GlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(12),
      color: PremiumTheme.darkSurfaceCard,
      child: Column(
        children: [
          Container(
            height: 100,
            padding: const EdgeInsets.all(8),
            child: Image.network(
              laptop.imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.laptop, size: 50),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            laptop.brand.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: PremiumTheme.primaryNeon,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            laptop.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(
    String label, 
    String valA, 
    String valB, {
    bool? isBetter, 
    bool isEqual = false,
  }) {
    Color colorA = Colors.white;
    Color colorB = Colors.white;

    if (isBetter != null && !isEqual) {
      colorA = isBetter ? PremiumTheme.successGreen : PremiumTheme.textSecondary;
      colorB = isBetter ? PremiumTheme.textSecondary : PremiumTheme.successGreen;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: PremiumTheme.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  valA,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isBetter == true ? FontWeight.bold : FontWeight.normal,
                    color: colorA,
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 15,
                color: PremiumTheme.darkBorder,
              ),
              Expanded(
                child: Text(
                  valB,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isBetter == false ? FontWeight.bold : FontWeight.normal,
                    color: colorB,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
