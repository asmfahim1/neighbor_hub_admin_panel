import '../../../../core/utils/result.dart';
import '../entity/residents_entity.dart';

abstract class ResidentsRepository {
  Future<Result<List<ResidentsEntity>>> getResidentsData();
}
