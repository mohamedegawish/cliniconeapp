class NotificationModel {
  final int id;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final String? readAt;
  final String createdAt;
  final Map<String, dynamic>? data;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    this.readAt,
    required this.createdAt,
    this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
    id:        json['id'] as int,
    type:      json['type'] as String? ?? 'system',
    title:     json['title'] as String? ?? '',
    message:   json['message'] as String? ?? '',
    isRead:    json['is_read'] as bool? ?? false,
    readAt:    json['read_at'] as String?,
    createdAt: json['created_at'] as String? ?? '',
    data:      json['data'] as Map<String, dynamic>?,
  );

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
    id: id, type: type, title: title, message: message,
    isRead: isRead ?? this.isRead, readAt: readAt,
    createdAt: createdAt, data: data,
  );
}
