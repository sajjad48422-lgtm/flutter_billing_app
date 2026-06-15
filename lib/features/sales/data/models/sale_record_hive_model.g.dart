// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'sale_record_hive_model.dart';

class SaleItemHiveModelAdapter extends TypeAdapter<SaleItemHiveModel> {
  @override
  final int typeId = 10;

  @override
  SaleItemHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SaleItemHiveModel()
      ..productId = fields[0] as String
      ..productName = fields[1] as String
      ..price = fields[2] as double
      ..purchasePrice = fields[3] as double
      ..quantity = fields[4] as double
      ..total = fields[5] as double;
  }

  @override
  void write(BinaryWriter writer, SaleItemHiveModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.productId)
      ..writeByte(1)
      ..write(obj.productName)
      ..writeByte(2)
      ..write(obj.price)
      ..writeByte(3)
      ..write(obj.purchasePrice)
      ..writeByte(4)
      ..write(obj.quantity)
      ..writeByte(5)
      ..write(obj.total);
  }

  @override
  List<int> get additionalTypeIds => [];
}

class SaleRecordHiveModelAdapter extends TypeAdapter<SaleRecordHiveModel> {
  @override
  final int typeId = 11;

  @override
  SaleRecordHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SaleRecordHiveModel()
      ..id = fields[0] as String
      ..createdAt = fields[1] as DateTime
      ..items = (fields[2] as List).cast<SaleItemHiveModel>()
      ..totalAmount = fields[3] as double
      ..totalPurchaseAmount = fields[4] as double
      ..taxAmount = fields[5] as double
      ..finalAmount = fields[6] as double;
  }

  @override
  void write(BinaryWriter writer, SaleRecordHiveModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.items)
      ..writeByte(3)
      ..write(obj.totalAmount)
      ..writeByte(4)
      ..write(obj.totalPurchaseAmount)
      ..writeByte(5)
      ..write(obj.taxAmount)
      ..writeByte(6)
      ..write(obj.finalAmount);
  }

  @override
  List<int> get additionalTypeIds => [];
}
