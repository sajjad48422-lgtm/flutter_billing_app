import 'package:fpdart/fpdart.dart';
import 'package:hive/hive.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/sale_record.dart';
import '../../domain/repositories/sale_repository.dart';
import '../models/sale_record_hive_model.dart';

class SaleRepositoryImpl implements SaleRepository {
  static const String _salesBox = 'sales_box';

  Box<SaleRecordHiveModel> get _box =>
      Hive.box<SaleRecordHiveModel>(_salesBox);

  @override
  Future<Either<Failure, void>> saveSale(SaleRecord record) async {
    try {
      final model = SaleRecordHiveModel.fromEntity(record);
      await _box.put(record.id, model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('خطا در ذخیره فروش: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SaleRecord>>> getAllSales() async {
    try {
      final records = _box.values.map((m) => m.toEntity()).toList();
      records.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return Right(records);
    } catch (e) {
      return Left(CacheFailure('خطا در دریافت فروش‌ها: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SaleRecord>>> getSalesByDateRange(
      DateTime from, DateTime to) async {
    try {
      final records = _box.values
          .map((m) => m.toEntity())
          .where((r) =>
              r.createdAt.isAfter(from) &&
              r.createdAt.isBefore(to.add(const Duration(days: 1))))
          .toList();
      records.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return Right(records);
    } catch (e) {
      return Left(CacheFailure('خطا در دریافت فروش‌ها: $e'));
    }
  }
}