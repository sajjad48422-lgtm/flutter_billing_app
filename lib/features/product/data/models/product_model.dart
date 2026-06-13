import 'package:hive/hive.dart';
import '../../domain/entities/product.dart';

part 'product_model.g.dart';

@HiveType(typeId: 0)
class ProductModel extends Product {
  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String name;
  @override
  @HiveField(2)
  final String barcode;
  @override
  @HiveField(3)
  final double price;
  @override
  @HiveField(4)
  final int stock;
  @override
  @HiveField(5)
  final int lowStockThreshold;
  @HiveField(6)
  final int unitIndex;

  const ProductModel({
    required this.id,
    required this.name,
    required this.barcode,
    required this.price,
    required this.stock,
    this.lowStockThreshold = 2,
    this.unitIndex = 0,
  }) : super(
          id: id,
          name: name,
          barcode: barcode,
          price: price,
          stock: stock,
          lowStockThreshold: lowStockThreshold,
          unit: ProductUnit.values[unitIndex],
        );

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      barcode: product.barcode,
      price: product.price,
      stock: product.stock,
      lowStockThreshold: product.lowStockThreshold,
      unitIndex: product.unit.index,
    );
  }

  Product toEntity() {
    return Product(
      id: id,
      name: name,
      barcode: barcode,
      price: price,
      stock: stock,
      lowStockThreshold: lowStockThreshold,
      unit: ProductUnit.values[unitIndex],
    );
  }
}