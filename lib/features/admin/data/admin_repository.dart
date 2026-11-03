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
      players:
          ((playersBody?['meta'] as Map<String, dynamic>?)?['total'] as num?)
              ?.toInt() ??
          0,
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
    return (data['recipient_count'] as num?)?.toInt() ?? 0;
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
  });
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
    matches: (json['ranking_matches_played'] as num?)?.toInt() ?? 0,
    wins: (json['ranking_matches_won'] as num?)?.toInt() ?? 0,
    points: (json['ranking_real_points'] as num?)?.toDouble() ?? 0,
    status: (json['registration_status'] ?? '').toString(),
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
        recipientCount: (json['recipient_count'] as num?)?.toInt() ?? 0,
        createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
      );
}
