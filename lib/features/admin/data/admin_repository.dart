import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers.dart';

final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => AdminRepository(ref.watch(apiClientProvider)),
);

class AdminRepository {
  AdminRepository(this._api);
  final ApiClient _api;

  Future<AdminOverview> overview({
    required bool matchesEnabled,
    required bool bookingsEnabled,
    required bool playersEnabled,
  }) async {
    final matchesResponse = matchesEnabled
        ? await _api.get('/matches', query: {'limit': 200, 'sort': '-date'})
        : null;
    final bookingsResponse = bookingsEnabled
        ? await _api.get('/bookings', query: {'limit': 200, 'sort': '-date'})
        : null;
    final playersResponse = playersEnabled
        ? await _api.get('/players', query: {'limit': 1})
        : null;
    final matches = matchesResponse == null
        ? const []
        : _data(matchesResponse.data);
    final bookings = bookingsResponse == null
        ? const []
        : _data(bookingsResponse.data);
    final playersBody = playersResponse?.data as Map<String, dynamic>?;
    return AdminOverview(
      matches: matches.length,
      pendingResults: matches.where((value) {
        final status = (value as Map<String, dynamic>)['status'];
        return status == 'pending_result' || status == 'in_progress';
      }).length,
      bookings: bookings.length,
      players: _intValue(
        (playersBody?['meta'] as Map<String, dynamic>?)?['total'],
      ),
    );
  }

  Future<List<AdminBooking>> bookings() async {
    final response = await _api.get(
      '/bookings',
      query: {'limit': 200, 'sort': '-date'},
    );
    return _data(
      response.data,
    ).cast<Map<String, dynamic>>().map(AdminBooking.fromJson).toList();
  }

  Future<List<AdminPlayer>> players({String search = ''}) async {
    final response = await _api.get(
      '/players',
      query: {
        'limit': 200,
        if (search.trim().isNotEmpty) 'search': search.trim(),
      },
    );
    return _data(
      response.data,
    ).cast<Map<String, dynamic>>().map(AdminPlayer.fromJson).toList();
  }

  Future<AdminPlayerStatistics> playerStatistics(String id) async {
    final response = await _api.get('/players/$id/statistics');
    return AdminPlayerStatistics.fromJson(
      (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
    );
  }

  Future<AdminPlayer> createPlayer({
    required String fullName,
    required String birthDate,
    required String gender,
    String? email,
    String? phone,
    String? preferredSide,
  }) async {
    final response = await _api.post(
      '/players',
      data: {
        'full_name': fullName.trim(),
        'birth_date': birthDate,
        'gender': gender,
        'email': email?.trim().toLowerCase(),
        'phone': phone?.trim(),
        'preferred_side': preferredSide,
        'is_active': true,
      },
    );
    return AdminPlayer.fromJson(
      (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
    );
  }

  Future<List<AdminUser>> users({String search = ''}) async {
    final response = await _api.get(
      '/users',
      query: {
        'limit': 200,
        if (search.trim().isNotEmpty) 'search': search.trim(),
      },
    );
    return _data(
      response.data,
    ).cast<Map<String, dynamic>>().map(AdminUser.fromJson).toList();
  }

  Future<AdminUser> createUser({
    required String fullName,
    required String email,
    required String password,
    required String role,
    List<String> permissions = const [],
  }) async {
    final response = await _api.post(
      '/users',
      data: {
        'full_name': fullName.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
        'role': role,
        'email_verified': true,
        'admin_menu_permissions': permissions,
      },
    );
    return AdminUser.fromJson(
      (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
    );
  }

  Future<List<AdminCommunication>> communications() async {
    final response = await _api.get('/communications');
    return _data(
      response.data,
    ).cast<Map<String, dynamic>>().map(AdminCommunication.fromJson).toList();
  }

  Future<int> sendCommunication({
    required String title,
    required String body,
    String? destination,
  }) async {
    final response = await _api.post(
      '/communications',
      data: {
        'title': title.trim(),
        'body': body.trim(),
        if (destination != null) 'destination': destination,
        'audience': {'type': 'all'},
      },
    );
    final data =
        (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return _intValue(data['recipient_count']);
  }

  List<dynamic> _data(Object? body) =>
      ((body as Map<String, dynamic>)['data'] as List<dynamic>?) ?? const [];
}

class AdminOverview {
  const AdminOverview({
    required this.matches,
    required this.pendingResults,
    required this.bookings,
    required this.players,
  });
  final int matches;
  final int pendingResults;
  final int bookings;
  final int players;
}

class AdminBooking {
  const AdminBooking({
    required this.id,
    required this.playerName,
    required this.courtName,
    required this.date,
    required this.time,
    required this.status,
    required this.type,
  });
  final String id;
  final String playerName;
  final String courtName;
  final String date;
  final String time;
  final String status;
  final String type;

  factory AdminBooking.fromJson(Map<String, dynamic> json) => AdminBooking(
    id: json['id'].toString(),
    playerName: (json['player_name'] ?? json['player_email'] ?? '—').toString(),
    courtName: (json['court_name'] ?? 'Campo').toString(),
    date: (json['booking_date'] ?? json['date'] ?? '').toString(),
    time:
        (json['time_slot'] ??
                '${json['start_hour'] ?? ''}-${json['end_hour'] ?? ''}')
            .toString(),
    status: (json['status'] ?? '').toString(),
    type: (json['booking_type'] ?? json['type'] ?? 'prenotazione').toString(),
  );
}

class AdminPlayer {
  const AdminPlayer({
    required this.id,
    required this.name,
    required this.email,
    required this.matches,
    required this.wins,
    required this.points,
    required this.status,
    this.phone = '',
    this.birthDate = '',
  });
  final String phone;
  final String birthDate;
  final String id;
  final String name;
  final String email;
  final int matches;
  final int wins;
  final double points;
  final String status;

  factory AdminPlayer.fromJson(Map<String, dynamic> json) => AdminPlayer(
    id: json['id'].toString(),
    name: (json['full_name'] ?? '—').toString(),
    email: (json['email'] ?? '').toString(),
    matches: _intValue(json['ranking_matches_played']),
    wins: _intValue(json['ranking_matches_won']),
    points: _doubleValue(json['ranking_real_points']),
    status: (json['registration_status'] ?? '').toString(),
    phone: (json['phone'] ?? '').toString(),
    birthDate: (json['birth_date'] ?? '').toString(),
  );
}

class AdminCommunication {
  const AdminCommunication({
    required this.title,
    required this.body,
    required this.status,
    required this.recipientCount,
    required this.createdAt,
  });
  final String title;
  final String body;
  final String status;
  final int recipientCount;
  final DateTime? createdAt;

  factory AdminCommunication.fromJson(Map<String, dynamic> json) =>
      AdminCommunication(
        title: (json['title'] ?? '').toString(),
        body: (json['body'] ?? '').toString(),
        status: (json['status'] ?? '').toString(),
        recipientCount: _intValue(json['recipient_count']),
        createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
      );
}

class AdminUser {
  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.active,
    required this.verified,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final bool active;
  final bool verified;

  factory AdminUser.fromJson(Map<String, dynamic> json) => AdminUser(
    id: json['id'].toString(),
    name: (json['full_name'] ?? '—').toString(),
    email: (json['email'] ?? '').toString(),
    role: (json['role'] ?? 'user').toString(),
    active: _boolValue(json['is_active'], fallback: true),
    verified: _boolValue(json['email_verified']),
  );
}

int _intValue(Object? value) => switch (value) {
  num number => number.toInt(),
  String text => num.tryParse(text.replaceAll(',', '.'))?.toInt() ?? 0,
  _ => 0,
};

double _doubleValue(Object? value) => switch (value) {
  num number => number.toDouble(),
  String text => double.tryParse(text.replaceAll(',', '.')) ?? 0,
  _ => 0,
};

bool _boolValue(Object? value, {bool fallback = false}) => switch (value) {
  bool boolean => boolean,
  num number => number != 0,
  String text when text.toLowerCase() == 'true' || text == '1' => true,
  String text when text.toLowerCase() == 'false' || text == '0' => false,
  _ => fallback,
};

class AdminPlayerStatistics {
  const AdminPlayerStatistics({
    required this.matches,
    required this.wins,
    required this.losses,
    required this.history,
  });
  final int matches;
  final int wins;
  final int losses;
  final List<AdminPlayerMatch> history;

  factory AdminPlayerStatistics.fromJson(Map<String, dynamic> json) {
    final totals = json['totals'] as Map<String, dynamic>? ?? const {};
    return AdminPlayerStatistics(
      matches: _intValue(totals['matches_played']),
      wins: _intValue(totals['wins']),
      losses: _intValue(totals['losses']),
      history: (json['matches'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(AdminPlayerMatch.fromJson)
          .toList(),
    );
  }
}

class AdminPlayerMatch {
  const AdminPlayerMatch({
    required this.id,
    required this.date,
    required this.time,
    required this.court,
    required this.score,
    required this.pending,
    required this.players,
  });
  final String id;
  final String date;
  final String time;
  final String court;
  final String score;
  final bool pending;
  final List<String> players;

  factory AdminPlayerMatch.fromJson(Map<String, dynamic> json) =>
      AdminPlayerMatch(
        id: json['id'].toString(),
        date: (json['date'] ?? '').toString(),
        time: (json['time_slot'] ?? '').toString(),
        court: (json['court_name'] ?? '').toString(),
        score: (json['score_team1'] ?? '').toString(),
        pending: json['status'] == 'pending_result',
        players: (json['players'] as List<dynamic>? ?? const [])
            .map(
              (player) => (player as Map<String, dynamic>)['name'].toString(),
            )
            .toList(),
      );
}
