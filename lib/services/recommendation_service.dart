import '../models/laptop.dart';
import 'laptop_service.dart';

/// Structured outcome of a recommendation query with explainable diagnostic reasoning.
class RecommendationResult {
  final String explanation;
  final List<Laptop> laptops;
  final String matchedCategory;

  const RecommendationResult({
    required this.explanation,
    required this.laptops,
    required this.matchedCategory,
  });
}

/// Heuristic rule-based recommendation engine for the AI Finder screen.
///
/// Note: This is an explainable rule-based expert system designed for portfolio
/// demonstration, simulating intelligent workload analysis without external cloud AI dependencies.
class RecommendationService {
  static final RecommendationService instance = RecommendationService._();
  RecommendationService._();

  final LaptopService _laptopService = LaptopService();

  /// Analyzes a prompt and returns relevant rigs with an explainable diagnostic narrative
  Future<RecommendationResult> getRecommendations(String userQuery) async {
    // Simulate brief algorithmic processing latency
    await Future.delayed(const Duration(milliseconds: 600));

    final query = userQuery.toLowerCase().trim();
    final allLaptops = _laptopService.getAllLaptops();

    if (query.isEmpty) {
      return RecommendationResult(
        explanation: 'Please enter a target budget, specification, or primary workload.',
        laptops: [],
        matchedCategory: 'None',
      );
    }

    // 1. Software Development / Engineering
    if (query.contains('developer') ||
        query.contains('coding') ||
        query.contains('programming') ||
        query.contains('dev') ||
        query.contains('software') ||
        query.contains('xcode') ||
        query.contains('docker')) {
      final matches = allLaptops.where((l) => l.codingScore >= 88).toList()
        ..sort((a, b) => b.codingScore.compareTo(a.codingScore));

      return RecommendationResult(
        explanation:
            'Analyzing fleet compilation diagnostics... Identified ${matches.length} machines scoring 88+ in code compilation, multi-threaded container execution, and responsive UNIX/ARM environments.',
        laptops: matches.take(3).toList(),
        matchedCategory: 'Software Development',
      );
    }

    // 2. High-Performance Gaming / Ray Tracing
    if (query.contains('gaming') ||
        query.contains('game') ||
        query.contains('fps') ||
        query.contains('rtx') ||
        query.contains('gpu') ||
        query.contains('steam')) {
      final matches = allLaptops.where((l) => l.gamingScore >= 85).toList()
        ..sort((a, b) => b.gamingScore.compareTo(a.gamingScore));

      return RecommendationResult(
        explanation:
            'Scanning high-refresh thermal-dense architectures... Filtered ${matches.length} elite gaming rigs featuring dedicated RTX GPUs and high-wattage power deliverable for ultra frame rates.',
        laptops: matches.take(3).toList(),
        matchedCategory: 'Extreme Gaming',
      );
    }

    // 3. Portability, Flight / Commute & Battery Endurance
    if (query.contains('portable') ||
        query.contains('travel') ||
        query.contains('battery') ||
        query.contains('light') ||
        query.contains('weight') ||
        query.contains('flight')) {
      final matches = allLaptops
          .where((l) => l.batteryScore >= 80 || l.weight <= 1.7)
          .toList()
        ..sort((a, b) => b.batteryScore.compareTo(a.batteryScore));

      return RecommendationResult(
        explanation:
            'Diagnosing ultra-low wattage silicon and sub-1.7kg chassis... Found ${matches.length} lightweight ultrabooks engineered for all-day unplugged productivity.',
        laptops: matches.take(3).toList(),
        matchedCategory: 'Ultra-portable & Battery',
      );
    }

    // 4. Creative Production / 4K Video / Color Accuracy
    if (query.contains('video') ||
        query.contains('render') ||
        query.contains('creator') ||
        query.contains('photo') ||
        query.contains('design') ||
        query.contains('oled') ||
        query.contains('4k')) {
      final matches = allLaptops
          .where((l) =>
              l.category == 'Creators' ||
              l.display.contains('OLED') ||
              l.display.contains('Liquid Retina'))
          .toList()
        ..sort((a, b) => b.productivityScore.compareTo(a.productivityScore));

      return RecommendationResult(
        explanation:
            'Matching factory-calibrated color spaces and high-memory creative pipelines... Selected ${matches.length} machines optimal for Premiere, DaVinci, Blender, and Photoshop.',
        laptops: matches.take(3).toList(),
        matchedCategory: 'Digital Creation',
      );
    }

    // 5. Budget constraints (e.g. "under 2000", "under $1500")
    final budgetMatch = RegExp(r'under\s*\$?(\d+)').firstMatch(query);
    if (budgetMatch != null) {
      final limit = double.tryParse(budgetMatch.group(1) ?? '2000') ?? 2000.0;
      final matches = allLaptops.where((l) => l.basePrice <= limit).toList()
        ..sort((a, b) => b.rating.compareTo(a.rating));

      return RecommendationResult(
        explanation:
            'Applying cost-limit filter under \$${limit.toInt()}... Filtered ${matches.length} rigs offering the highest performance-per-dollar ratio within your budget ceiling.',
        laptops: matches.take(3).toList(),
        matchedCategory: 'Budget Value',
      );
    }

    // Fallback: Highest rated versatile general fleet rigs
    final fallback = List<Laptop>.from(allLaptops)
      ..sort((a, b) => b.rating.compareTo(a.rating));

    return RecommendationResult(
      explanation:
          'Parsing fleet metrics across balanced workloads... Displaying our highest-rated versatile workstations and ultrabooks.',
      laptops: fallback.take(3).toList(),
      matchedCategory: 'Fleet Best-in-Class',
    );
  }
}
