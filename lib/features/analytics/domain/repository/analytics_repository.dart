import '../../../../core/utils/result.dart';
import '../entity/analytics_entity.dart';

abstract class AnalyticsRepository {
  Future<Result<List<AnalyticsEntity>>> getAnalyticsData();
}
