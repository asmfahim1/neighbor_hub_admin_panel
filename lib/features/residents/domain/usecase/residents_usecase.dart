import '../../../../core/utils/result.dart';
import '../entity/residents_entity.dart';
import '../repository/residents_repository.dart';
import 'package:injectable/injectable.dart';


@injectable

class ResidentsUseCase {
  ResidentsUseCase(this._repo);

  final ResidentsRepository _repo;

  Future<Result<List<ResidentsEntity>>> call() {
    return _repo.getResidentsData();
  }
}
