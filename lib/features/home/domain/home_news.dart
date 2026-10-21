class HomeNews {
  const HomeNews({
    required this.id,
    required this.title,
    required this.content,
    this.summary,
    this.imageUrl,
    this.category = 'generale',
    this.isPinned = false,
    this.publishedDate,
  });

  final String id;
  final String title;
  final String content;
  final String? summary;
  final String? imageUrl;
  final String category;
  final bool isPinned;
  final DateTime? publishedDate;

  factory HomeNews.fromJson(Map<String, dynamic> json) => HomeNews(
    id: json['id'] as String,
    title: json['title'] as String,
    content: json['content'] as String? ?? '',
    summary: json['summary'] as String?,
    imageUrl: json['image_url'] as String?,
    category: json['category'] as String? ?? 'generale',
    isPinned: json['is_pinned'] as bool? ?? false,
    publishedDate: DateTime.tryParse(json['published_date'] as String? ?? ''),
  );

  String get preview {
    final value = summary?.trim().isNotEmpty == true
        ? summary!.trim()
        : content.trim();
    return value;
  }
}
