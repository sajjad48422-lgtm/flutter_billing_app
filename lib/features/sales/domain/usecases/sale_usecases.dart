import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/sale_record.dart';
import '../repositories/sale_repository.dart';

class SaveSaleUseCase {
  final SaleRepository repository;
  SaveSaleUseCase(this.repository);

  Future<Either<Failure, void>> call(SaleRecord record) =>
      repository.saveSale(record);
}

class GetAllSalesUseCase {
  final SaleRepository repository;
  GetAllSalesUseCase(this.repository);

  Future<Either<Failure, List<SaleRecord>>> call() =>
      repository.getAllSales();
}

class GetSalesByDateRangeUseCase {
  final SaleRepository repository;
  GetSalesByDateRangeUseCase(this.repository);

  Future<Either<Failure, List<SaleRecord>>> call(
          DateTime from, DateTime to) =>
      repository.getSalesByDateRange(from, to);
}
