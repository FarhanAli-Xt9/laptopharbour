import '../models/laptop.dart';
import 'mock_laptop_data.dart'; // provides mockLaptops dataset

/// Data service providing access to the fleet laptop catalog with search,
/// multi-factor filtering, and sorting capabilities.
class LaptopService {
  static final LaptopService _instance = LaptopService._();
  factory LaptopService() => _instance;
  LaptopService._();

  List<Laptop> get _laptops => mockLaptops;

  /// Returns the complete fleet of laptops
  List<Laptop> getAllLaptops() {
    return List<Laptop>.unmodifiable(_laptops);
  }

  /// Finds a laptop by its unique ID
  Laptop? getLaptopById(String id) {
    try {
      return _laptops.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Retrieves all distinct brand names
  List<String> getBrands() {
    final brands = <String>{'All'};
    for (final laptop in _laptops) {
      brands.add(laptop.brand);
    }
    return brands.toList();
  }

  /// Retrieves all distinct category names
  List<String> getCategories() {
    final categories = <String>{'All'};
    for (final laptop in _laptops) {
      categories.add(laptop.category);
    }
    return categories.toList();
  }

  /// High-performing featured rigs
  List<Laptop> getFeaturedLaptops({int limit = 4}) {
    final sorted = List<Laptop>.from(_laptops)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(limit).toList();
  }

  /// Performs search, category/brand/price filtering, and sorting
  List<Laptop> filterAndSort({
    String query = '',
    String brand = 'All',
    String category = 'All',
    double maxPrice = 4000.0,
    String sortBy = 'Default',
  }) {
    final cleanQuery = query.trim().toLowerCase();

    final filtered = _laptops.where((laptop) {
      final matchesQuery = cleanQuery.isEmpty ||
          laptop.name.toLowerCase().contains(cleanQuery) ||
          laptop.brand.toLowerCase().contains(cleanQuery) ||
          laptop.cpu.toLowerCase().contains(cleanQuery) ||
          laptop.category.toLowerCase().contains(cleanQuery);

      final matchesBrand = brand == 'All' || laptop.brand.toLowerCase() == brand.toLowerCase();
      final matchesCategory = category == 'All' || laptop.category.toLowerCase() == category.toLowerCase();
      final matchesPrice = laptop.basePrice <= maxPrice;

      return matchesQuery && matchesBrand && matchesCategory && matchesPrice;
    }).toList();

    switch (sortBy) {
      case 'Price: Low to High':
        filtered.sort((a, b) => a.basePrice.compareTo(b.basePrice));
        break;
      case 'Price: High to Low':
        filtered.sort((a, b) => b.basePrice.compareTo(a.basePrice));
        break;
      case 'Highest Rating':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      default:
        // Keep default fleet order
        break;
    }

    return filtered;
  }
}
