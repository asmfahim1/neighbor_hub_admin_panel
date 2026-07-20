import '../../../../core/api_client/api_service.dart';
import '../../../../core/session_manager/session_manager.dart';
import '../../../../core/utils/endpoints.dart';
import 'package:injectable/injectable.dart';

import '../model/residents_model.dart';

@lazySingleton

class ResidentsRemoteSource {
  ResidentsRemoteSource(this._api, this._session);

  final ApiService _api;
  final SessionManager _session;

  Future<List<ResidentsModel>> fetchData() async {
    final token = await _session.getToken();
    final response = await _api.get(ApiEndpoints.residentsList, query: {
      'token': token ?? '',
    });

    final data = (response.data as List<dynamic>? ?? []);
    return data
        .map((item) => ResidentsModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
