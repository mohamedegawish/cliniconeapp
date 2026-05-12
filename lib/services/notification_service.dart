import '../api/api_client.dart';
import '../constants/endpoints.dart';
import '../models/notification_model.dart';

class NotificationService {
  final ApiClient _client;
  NotificationService(this._client);

  Future<({List<NotificationModel> items, int unread, int total})> getNotifications({int page = 1}) async {
    final res  = await _client.get(Endpoints.clinicNotifications, queryParameters: {'page': page});
    final data = res['data'] as Map<String, dynamic>? ?? {};
    final list = (data['data'] as List? ?? [])
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return (
      items: list,
      unread: data['unread'] as int? ?? 0,
      total:  data['total']  as int? ?? 0,
    );
  }

  Future<int> getUnreadCount() async {
    final res  = await _client.get(Endpoints.clinicNotifUnreadCount);
    final data = res['data'] as Map<String, dynamic>? ?? {};
    return data['count'] as int? ?? 0;
  }

  Future<void> markRead(int id) async {
    await _client.post(Endpoints.notifMarkRead(id));
  }

  Future<void> markAllRead() async {
    await _client.post(Endpoints.clinicNotifReadAll);
  }
}
