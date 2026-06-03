import 'package:equatable/equatable.dart';
import 'package:depir/features/product/domain/entities/product.dart';

class CartItem extends Equatable {
  final Product product;
  final int quantity;
  final double weightAmount;

  const CartItem({
    required this.product,
    this.quantity = 1,
    this.weightAmount = 1.0,
  });

  /// آیا کالا وزنی/حجمیه؟
  bool get isWeightBased {
    switch (product.unit) {
      case ProductUnit.kg:
      case ProductUnit.gram:
      case ProductUnit.liter:
      case ProductUnit.meter:
        return true;
      default:
        return false;
    }
  }

  /// مبلغ کل
  double get total {
    if (isWeightBased) {
      return product.price * weightAmount;
    }
    return product.price * quantity;
  }

  /// نمایش مقدار
  String get displayAmount {
    if (isWeightBased) {
      return '${weightAmount.toStringAsFixed(weightAmount % 1 == 0 ? 0 : 2)} ${product.unit.label}';
    }
    return '$quantity ${product.unit.label}';
  }

  CartItem copyWith({
    Product? product,
    int? quantity,
    double? weightAmount,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      weightAmount: weightAmount ?? this.weightAmount,
    );
  }

  @override
  List<Object> get props => [product, quantity, weightAmount];
}