class ClubTournament {
  const ClubTournament({
    required this.id,
    required this.name,
    required this.startDate,
    required this.status,
    required this.type,
    required this.level,
    this.description,
    this.endDate,
    this.maxTeams,
    this.registeredPlayers = 0,
    this.entryFee = 0,
    this.prize,
    this.rules,
    this.imageUrl,
    this.affectsRanking = false,
  });

  final String id;
  final String name;
  final String? description;
  final DateTime startDate;
  final DateTime? endDate;
  final String status;
  final String type;
  final String level;
  final int? maxTeams;
  final int registeredPlayers;
  final double entryFee;
  final String? prize;
  final String? rules;
  final String? imageUrl;
  final bool affectsRanking;

  factory ClubTournament.fromJson(Map<String, dynamic> json) => ClubTournament(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',
    description: json['description'] as String?,
    startDate: DateTime.parse(json['start_date'] as String),
    endDate: DateTime.tryParse(json['end_date'] as String? ?? ''),
    status: json['status'] as String? ?? 'upcoming',
    type: json['type'] as String? ?? 'elimination',
    level: json['level'] as String? ?? 'open',
    maxTeams: (json['max_teams'] as num?)?.toInt(),
    registeredPlayers: (json['registered_players_count'] as num?)?.toInt() ?? 0,
    entryFee: (json['entry_fee'] as num?)?.toDouble() ?? 0,
    prize: json['prize'] as String?,
    rules: json['rules'] as String?,
    imageUrl: json['image_url'] as String?,
    affectsRanking: json['affects_ranking'] as bool? ?? false,
  );
}

class GalleryImage {
  const GalleryImage({required this.url, this.caption});
  final String url;
  final String? caption;

  factory GalleryImage.fromJson(Map<String, dynamic> json) => GalleryImage(
    url: json['url'] as String? ?? '',
    caption: json['caption'] as String?,
  );
}

class GalleryEvent {
  const GalleryEvent({
    required this.id,
    required this.title,
    required this.eventDate,
    required this.category,
    this.description,
    this.coverImage,
    this.images = const [],
  });

  final String id;
  final String title;
  final String? description;
  final DateTime eventDate;
  final String category;
  final String? coverImage;
  final List<GalleryImage> images;

  factory GalleryEvent.fromJson(Map<String, dynamic> json) => GalleryEvent(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    description: json['description'] as String?,
    eventDate: DateTime.parse(json['event_date'] as String),
    category: json['category'] as String? ?? 'evento',
    coverImage: json['cover_image'] as String?,
    images: (json['images'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(GalleryImage.fromJson)
        .toList(),
  );
}

class ClubInfo {
  const ClubInfo({
    required this.name,
    required this.slug,
    required this.timezone,
  });

  final String name;
  final String slug;
  final String timezone;

  factory ClubInfo.fromJson(Map<String, dynamic> json) => ClubInfo(
    name: json['name'] as String? ?? 'CRPadel',
    slug: json['slug'] as String? ?? '',
    timezone: json['timezone'] as String? ?? 'Europe/Rome',
  );
}
