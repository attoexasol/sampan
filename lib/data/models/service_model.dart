class ServiceModel {
  final String id;
  final String name;
  final double price;
  final bool isSelected;

  ServiceModel({
    required this.id,
    required this.name,
    required this.price,
    this.isSelected = false,
  });

  ServiceModel copyWith({bool? isSelected}) {
    return ServiceModel(
      id: id,
      name: name,
      price: price,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class ItemQuantity {
  final String id;
  final String name;
  final double price;
  int quantity;

  ItemQuantity({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 0,
  });
}
