import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/sale_record.dart';

abstract class SaleRepository {
  Future<Either<Failure, void>> saveSale(SaleRecord record);
  Future<Either<Failure, List<SaleRecord>>> getAllSales();
  Future<Either<Failure, List<SaleRecord>>> getSalesByDateRange(
      DateTime from, DateTime to);
}