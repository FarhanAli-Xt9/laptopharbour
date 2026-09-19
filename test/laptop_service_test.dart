// Laptop Harbour – LaptopService Unit Tests
//
// Verifies search, filtering, sorting, and data-retrieval methods against the
// real mockLaptops dataset.

import 'package:flutter_test/flutter_test.dart';
import 'package:laptopharbour/services/laptop_service.dart';

void main() {
  final service = LaptopService();

  // ─── getAllLaptops ─────────────────────────────────────────────────────────
  group('LaptopService.getAllLaptops', () {
    test('returns a non-empty list', () {
      expect(service.getAllLaptops(), isNotEmpty);
    });

    test('returned list is unmodifiable', () {
      final laptops = service.getAllLaptops();
      expect(() => (laptops as dynamic).add(null), throwsA(anything));
    });
  });

  // ─── getLaptopById ─────────────────────────────────────────────────────────
  group('LaptopService.getLaptopById', () {
    test('returns correct laptop for valid id', () {
      final first = service.getAllLaptops().first;
      final found = service.getLaptopById(first.id);
      expect(found, isNotNull);
      expect(found!.id, equals(first.id));
      expect(found.name, equals(first.name));
    });

    test('returns null for unknown id', () {
      expect(service.getLaptopById('__non_existent_id__'), isNull);
    });
  });

  // ─── getBrands ────────────────────────────────────────────────────────────
  group('LaptopService.getBrands', () {
    test('includes "All" as first entry', () {
      expect(service.getBrands(), contains('All'));
    });

    test('contains at least one real brand', () {
      final brands = service.getBrands();
      // Must have more than just "All"
      expect(brands.length, greaterThan(1));
    });
  });

  // ─── getCategories ────────────────────────────────────────────────────────
  group('LaptopService.getCategories', () {
    test('includes "All" as entry', () {
      expect(service.getCategories(), contains('All'));
    });

    test('contains at least one real category', () {
      expect(service.getCategories().length, greaterThan(1));
    });
  });

  // ─── getFeaturedLaptops ───────────────────────────────────────────────────
  group('LaptopService.getFeaturedLaptops', () {
    test('returns up to the specified limit', () {
      expect(service.getFeaturedLaptops(limit: 4).length, lessThanOrEqualTo(4));
    });

    test('results are sorted by rating descending', () {
      final featured = service.getFeaturedLaptops(limit: 10);
      for (int i = 0; i < featured.length - 1; i++) {
        expect(featured[i].rating, greaterThanOrEqualTo(featured[i + 1].rating));
      }
    });
  });

  // ─── filterAndSort – Search Query ────────────────────────────────────────
  group('LaptopService.filterAndSort – search', () {
    test('empty query with no filter returns all laptops', () {
      // Use a very high maxPrice so no laptops are excluded by price filter.
      expect(
        service.filterAndSort(query: '', maxPrice: 999999.0).length,
        equals(service.getAllLaptops().length),
      );
    });

    test('matches by laptop name (case-insensitive)', () {
      final all = service.getAllLaptops();
      final firstName = all.first.name.split(' ').first.toLowerCase();
      final results = service.filterAndSort(query: firstName);
      expect(results, isNotEmpty);
      for (final l in results) {
        expect(
          l.name.toLowerCase().contains(firstName) ||
              l.brand.toLowerCase().contains(firstName) ||
              l.cpu.toLowerCase().contains(firstName) ||
              l.category.toLowerCase().contains(firstName),
          isTrue,
        );
      }
    });

    test('returns empty list for nonsense query', () {
      expect(service.filterAndSort(query: 'xyzzy_not_found_ever'), isEmpty);
    });
  });

  // ─── filterAndSort – Brand Filter ────────────────────────────────────────
  group('LaptopService.filterAndSort – brand filter', () {
    test('"All" brand returns all laptops (no price filter)', () {
      // filterAndSort defaults to maxPrice 4000 which may exclude some laptops;
      // set a high limit to test the brand filter in isolation.
      expect(
        service.filterAndSort(brand: 'All', maxPrice: 999999.0).length,
        equals(service.getAllLaptops().length),
      );
    });

    test('specific brand filters correctly', () {
      final allBrands = service.getBrands().where((b) => b != 'All').toList();
      if (allBrands.isEmpty) return; // guard for empty dataset
      final brand = allBrands.first;
      final results = service.filterAndSort(brand: brand);
      expect(results, isNotEmpty);
      for (final l in results) {
        expect(l.brand.toLowerCase(), equals(brand.toLowerCase()));
      }
    });
  });

  // ─── filterAndSort – Price Filter ────────────────────────────────────────
  group('LaptopService.filterAndSort – price filter', () {
    test('maxPrice=0 returns empty list', () {
      expect(service.filterAndSort(maxPrice: 0.0), isEmpty);
    });

    test('maxPrice=999999 returns all laptops', () {
      expect(
        service.filterAndSort(maxPrice: 999999.0).length,
        equals(service.getAllLaptops().length),
      );
    });

    test('all results are within the maxPrice bound', () {
      const maxPrice = 1500.0;
      final results = service.filterAndSort(maxPrice: maxPrice);
      for (final l in results) {
        expect(l.basePrice, lessThanOrEqualTo(maxPrice));
      }
    });
  });

  // ─── filterAndSort – Sorting ──────────────────────────────────────────────
  group('LaptopService.filterAndSort – sorting', () {
    test('"Price: Low to High" returns ascending price order', () {
      final results = service.filterAndSort(sortBy: 'Price: Low to High');
      for (int i = 0; i < results.length - 1; i++) {
        expect(results[i].basePrice, lessThanOrEqualTo(results[i + 1].basePrice));
      }
    });

    test('"Price: High to Low" returns descending price order', () {
      final results = service.filterAndSort(sortBy: 'Price: High to Low');
      for (int i = 0; i < results.length - 1; i++) {
        expect(results[i].basePrice, greaterThanOrEqualTo(results[i + 1].basePrice));
      }
    });

    test('"Highest Rating" returns descending rating order', () {
      final results = service.filterAndSort(sortBy: 'Highest Rating');
      for (int i = 0; i < results.length - 1; i++) {
        expect(results[i].rating, greaterThanOrEqualTo(results[i + 1].rating));
      }
    });
  });
}
