import '../../../../core/utils/result.dart';
import '../entity/analytics_entity.dart';
import '../repository/analytics_repository.dart';
import 'package:injectable/injectable.dart';


@injectable

class AnalyticsUseCase {
  AnalyticsUseCase(this._repo);

  final AnalyticsRepository _repo;

  Future<Result<List<AnalyticsEntity>>> call() {
    return _repo.getAnalyticsData();
  }
}
