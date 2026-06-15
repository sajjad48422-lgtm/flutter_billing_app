import 'package:depir/core/error/failures.dart';
import 'package:fpdart/fpdart.dart';
import 'package:depir/features/sales/domain/entities/sale_record.dart';

abstract class SaleRepository {
  Future<Either<Failure, void>> saveSale(SaleRecord record);
  Future<Either<Failure, List<SaleRecord>>> getAllSales();
  Future<Either<Failure, List<SaleRecord>>> getSalesByDateRange(
      DateTime from, DateTime to);
}