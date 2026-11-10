class AppMenuConfiguration {
  const AppMenuConfiguration({
    this.home = true,
    this.bookings = true,
    this.matches = true,
    this.profile = true,
    this.tournaments = true,
    this.rankings = true,
    this.lessons = true,
    this.gallery = true,
    this.crpadelTv = true,
    this.notifications = true,
    this.clubInfo = true,
    this.createMatches = true,
  });

  factory AppMenuConfiguration.fromJson(Map<String, dynamic> json) =>
      AppMenuConfiguration(
        home: json['home'] as bool? ?? true,
        bookings: json['bookings'] as bool? ?? true,
        matches: json['matches'] as bool? ?? true,
        profile: json['profile'] as bool? ?? true,
        tournaments: json['tournaments'] as bool? ?? true,
        rankings: json['rankings'] as bool? ?? true,
        lessons: json['lessons'] as bool? ?? true,
        gallery: json['gallery'] as bool? ?? true,
        crpadelTv: json['crpadel_tv'] as bool? ?? true,
        notifications: json['notifications'] as bool? ?? true,
        clubInfo: json['club_info'] as bool? ?? true,
        createMatches: json['create_matches'] as bool? ?? true,
      );

  final bool home;
  final bool bookings;
  final bool matches;
  final bool profile;
  final bool tournaments;
  final bool rankings;
  final bool lessons;
  final bool gallery;
  final bool crpadelTv;
  final bool notifications;
  final bool clubInfo;

  /// Permesso operativo separato dalla visibilità della voce Partite.
  /// Admin e super admin vengono comunque autorizzati dal backend.
  final bool createMatches;

  static const allEnabled = AppMenuConfiguration();

  bool isEnabled(AppMenuFeature feature) => switch (feature) {
    AppMenuFeature.home => home,
    AppMenuFeature.bookings => bookings,
    AppMenuFeature.matches => matches,
    AppMenuFeature.profile => profile,
    AppMenuFeature.tournaments => tournaments,
    AppMenuFeature.rankings => rankings,
    AppMenuFeature.lessons => lessons,
    AppMenuFeature.gallery => gallery,
    AppMenuFeature.crpadelTv => crpadelTv,
    AppMenuFeature.notifications => notifications,
    AppMenuFeature.clubInfo => clubInfo,
  };

  bool get hasExploreItems =>
      tournaments ||
      rankings ||
      lessons ||
      gallery ||
      crpadelTv ||
      notifications ||
      clubInfo;
}

enum AppMenuFeature {
  home,
  bookings,
  matches,
  profile,
  tournaments,
  rankings,
  lessons,
  gallery,
  crpadelTv,
  notifications,
  clubInfo,
}
