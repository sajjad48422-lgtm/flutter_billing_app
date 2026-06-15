import 'package:equatable/equatable.dart';

class SaleItem extends Equatable {
  final String productId;
  final String productName;
  final double price;
  final double purchasePrice;
  final double quantity; // supports weight-based
  final double total;

  const SaleItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.purchasePrice,
    required this.quantity,
    required this.total,
  });

  double get profit => (price - purchasePrice) * quantity;

  @override
  List<Object?> get props =>
      [productId, productName, price, purchasePrice, quantity, total];
}

class SaleRecord extends Equatable {
  final String id;
  final DateTime createdAt;
  final List<SaleItem> items;
  final double totalAmount;
  final double totalPurchaseAmount;
  final double taxAmount;
  final double finalAmount;

  const SaleRecord({
    required this.id,
    required this.createdAt,
    required this.items,
    required this.totalAmount,
    required this.totalPurchaseAmount,
    required this.taxAmount,
    required this.finalAmount,
  });

  double get totalProfit => totalAmount - totalPurchaseAmount;

  @override
  List<Object?> get props =>
      [id, createdAt, items, totalAmount, totalPurchaseAmount, taxAmount, finalAmount];
}
