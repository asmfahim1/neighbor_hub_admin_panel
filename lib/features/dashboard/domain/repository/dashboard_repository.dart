import '../../../../core/utils/result.dart';
import '../entity/dashboard_entity.dart';

abstract class DashboardRepository {
  Future<Result<List<DashboardEntity>>> getDashboardData();
}
