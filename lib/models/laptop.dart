class Laptop {
  final String id;
  final String name;
  final String brand;
  final double basePrice;
  final String imageUrl;
  final String category;
  double rating;
  int reviewsCount;
  final String cpu;
  final String gpu;
  final String ram;
  final String storage;
  final String display;
  final String battery;
  final double weight;
  final String description;

  // Custom Performance Metrics (out of 100)
  final int gamingScore;
  final int codingScore;
  final int productivityScore;
  final int batteryScore;

  // Configurable options
  final List<ConfigOption> cpuOptions;
  final List<ConfigOption> gpuOptions;
  final List<ConfigOption> ramOptions;
  final List<ConfigOption> storageOptions;

  final List<LaptopReview> reviews;

  Laptop({
    required this.id,
    required this.name,
    required this.brand,
    required this.basePrice,
    required this.imageUrl,
    required this.category,
    required this.rating,
    required this.reviewsCount,
    required this.cpu,
    required this.gpu,
    required this.ram,
    required this.storage,
    required this.display,
    required this.battery,
    required this.weight,
    required this.description,
    required this.gamingScore,
    required this.codingScore,
    required this.productivityScore,
    required this.batteryScore,
    required this.cpuOptions,
    required this.gpuOptions,
    required this.ramOptions,
    required this.storageOptions,
    required this.reviews,
  });
}

class ConfigOption {
  final String name;
  final double priceDelta;
  ConfigOption({required this.name, required this.priceDelta});
}

class LaptopReview {
  final String username;
  final double rating;
  final String date;
  final String comment;
  LaptopReview({
    required this.username,
    required this.rating,
    required this.date,
    required this.comment,
  });
}

