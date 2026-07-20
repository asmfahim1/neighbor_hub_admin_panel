import '../../../../core/utils/result.dart';
import '../entity/apartments_entity.dart';

abstract class ApartmentsRepository {
  Future<Result<List<ApartmentsEntity>>> getApartmentsData();
}
