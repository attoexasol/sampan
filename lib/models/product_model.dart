// lib/data/models/product_model.dart
class Product {
  final String id;
  final String name;
  final String section;
  final String sortOrder;
  final double price;
  final int pieces;
  final String? imageUrl;
  final String? sku;
  final int extraDays;

  Product({
    required this.id,
    required this.name,
    required this.section,
    required this.sortOrder,
    required this.price,
    required this.pieces,
    this.imageUrl,
    this.sku,
    this.extraDays = 0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      section: json['section']?.toString() ?? '',
      sortOrder: json['sortOrder']?.toString() ?? '0',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      pieces: int.tryParse(json['pieces']?.toString() ?? '1') ?? 1,
      imageUrl: json['ic']?.toString(),
      sku: json['sku']?.toString(),
      extraDays: int.tryParse(json['extraDays']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'section': section,
    'sortOrder': sortOrder,
    'price': price,
    'pieces': pieces,
    'ic': imageUrl,
    'sku': sku,
    'extraDays': extraDays,
  };
}

class ProductSection {
  final String id;
  final String name;
  final int order;

  ProductSection({
    required this.id,
    required this.name,
    required this.order,
  });

  factory ProductSection.fromJson(Map<String, dynamic> json) {
    return ProductSection(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      order: int.tryParse(json['order']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'order': order,
  };
}

class ProductsResponse {
  final bool success;
  final List<Product> products;
  final List<ProductSection> sections;
  final String weightSymbol;

  ProductsResponse({
    required this.success,
    required this.products,
    required this.sections,
    required this.weightSymbol,
  });

  factory ProductsResponse.fromJson(Map<String, dynamic> json) {
    return ProductsResponse(
      success: json['Success'] == 'True',
      products: (json['Products'] as List? ?? [])
          .map((p) => Product.fromJson(p))
          .toList(),
      sections: (json['SectionsMap'] as List? ?? [])
          .map((s) => ProductSection.fromJson(s))
          .toList(),
      weightSymbol: json['weightSymbol']?.toString() ?? 'lb',
    );
  }

  Map<String, dynamic> toJson() => {
    'Success': success ? 'True' : 'False',
    'Products': products.map((p) => p.toJson()).toList(),
    'SectionsMap': sections.map((s) => s.toJson()).toList(),
    'weightSymbol': weightSymbol,
  };
}