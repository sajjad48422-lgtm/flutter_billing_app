import 'package:equatable/equatable.dart';

enum ProductUnit {
  piece,     // عدد
  kg,        // کیلوگرم
  gram,      // گرم
  liter,     // لیتر
  pack,      // بسته
  carton,    // کارتن
  box,       // جعبه
  bag,       // کیسه
  meter,     // متر
  dozen,     // دوجین
}

extension ProductUnitExtension on ProductUnit {
  String get label {
    switch (this) {
      case ProductUnit.piece:   return 'عدد';
      case ProductUnit.kg:      return 'کیلوگرم';
      case ProductUnit.gram:    return 'گرم';
      case ProductUnit.liter:   return 'لیتر';
      case ProductUnit.pack:    return 'بسته';
      case ProductUnit.carton:  return 'کارتن';
      case ProductUnit.box:     return 'جعبه';
      case ProductUnit.bag:     return 'کیسه';
      case ProductUnit.meter:   return 'متر';
      case ProductUnit.dozen:   return 'دوجین';
    }
  }
}

class Product extends Equatable {
  final String id;
  final String name;
  final String barcode;
  final double price;
  final int stock;
  final int lowStockThreshold;
  final ProductUnit unit;

  const Product({
    required this.id,
    required this.name,
    required this.barcode,
    required this.price,
    this.stock = 0,
    this.lowStockThreshold = 2,
    this.unit = ProductUnit.piece,
  });

  Product copyWith({
    String? id,
    String? name,
    String? barcode,
    double? price,
    int? stock,
    int? lowStockThreshold,
    ProductUnit? unit,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      unit: unit ?? this.unit,
    );
  }

  bool get isLowStock => stock <= lowStockThreshold && stock > 0;
  bool get isOutOfStock => stock <= 0;
  bool get isWeightBased => unit == ProductUnit.kg || unit == ProductUnit.gram;
  @override
  List<Object?> get props =>
      [id, name, barcode, price, stock, lowStockThreshold, unit];
}