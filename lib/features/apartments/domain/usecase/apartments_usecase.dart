import '../../../../core/utils/result.dart';
import '../entity/apartments_entity.dart';
import '../repository/apartments_repository.dart';
import 'package:injectable/injectable.dart';


@injectable

class ApartmentsUseCase {
  ApartmentsUseCase(this._repo);

  final ApartmentsRepository _repo;

  Future<Result<List<ApartmentsEntity>>> call() {
    return _repo.getApartmentsData();
  }
}
