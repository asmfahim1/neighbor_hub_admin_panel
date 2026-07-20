import '../../../../core/utils/result.dart';
import '../entity/dashboard_entity.dart';
import '../repository/dashboard_repository.dart';
import 'package:injectable/injectable.dart';


@injectable

class DashboardUseCase {
  DashboardUseCase(this._repo);

  final DashboardRepository _repo;

  Future<Result<List<DashboardEntity>>> call() {
    return _repo.getDashboardData();
  }
}
