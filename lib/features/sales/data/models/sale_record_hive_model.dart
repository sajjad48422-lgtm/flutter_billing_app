import 'package:hive/hive.dart';
import '../../domain/entities/sale_record.dart';

part 'sale_record_hive_model.g.dart';

@HiveType(typeId: 10)
class SaleItemHiveModel extends HiveObject {
  @HiveField(0)
  late String productId;

  @HiveField(1)
  late String productName;

  @HiveField(2)
  late double price;

  @HiveField(3)
  late double purchasePrice;

  @HiveField(4)
  late double quantity;

  @HiveField(5)
  late double total;

  SaleItem toEntity() => SaleItem(
        productId: productId,
        productName: productName,
        price: price,
        purchasePrice: purchasePrice,
        quantity: quantity,
        total: total,
      );

  static SaleItemHiveModel fromEntity(SaleItem item) {
    final model = SaleItemHiveModel();
    model.productId = item.productId;
    model.productName = item.productName;
    model.price = item.price;
    model.purchasePrice = item.purchasePrice;
    model.quantity = item.quantity;
    model.total = item.total;
    return model;
  }
}

@HiveType(typeId: 11)
class SaleRecordHiveModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late DateTime createdAt;

  @HiveField(2)
  late List<SaleItemHiveModel> items;

  @HiveField(3)
  late double totalAmount;

  @HiveField(4)
  late double totalPurchaseAmount;

  @HiveField(5)
  late double taxAmount;

  @HiveField(6)
  late double finalAmount;

  SaleRecord toEntity() => SaleRecord(
        id: id,
        createdAt: createdAt,
        items: items.map((i) => i.toEntity()).toList(),
        totalAmount: totalAmount,
        totalPurchaseAmount: totalPurchaseAmount,
        taxAmount: taxAmount,
        finalAmount: finalAmount,
      );

  static SaleRecordHiveModel fromEntity(SaleRecord record) {
    final model = SaleRecordHiveModel();
    model.id = record.id;
    model.createdAt = record.createdAt;
    model.items = record.items.map(SaleItemHiveModel.fromEntity).toList();
    model.totalAmount = record.totalAmount;
    model.totalPurchaseAmount = record.totalPurchaseAmount;
    model.taxAmount = record.taxAmount;
    model.finalAmount = record.finalAmount;
    return model;
  }
}
