class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.imageUrl,
    this.destination,
    this.entityId,
    this.readAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
    id: json['id'] as String,
    title: json['title'] as String,
    body: json['body'] as String,
    imageUrl: json['image_url'] as String?,
    destination: json['destination'] as String?,
    entityId: json['entity_id'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    readAt: json['read_at'] == null ? null : DateTime.parse(json['read_at'] as String).toLocal(),
  );

  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final String? destination;
  final String? entityId;
  final DateTime createdAt;
  final DateTime? readAt;
  bool get isRead => readAt != null;
}
