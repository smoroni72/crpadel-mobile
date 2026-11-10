import 'package:flutter/material.dart';

import '../../../../core/config/app_environment.dart';

String? playerPhotoUrl(String? value) {
  if (value == null || value.isEmpty) return null;
  final uri = Uri.tryParse(value);
  if (uri?.hasScheme == true) return value;
  return Uri.parse(AppEnvironment.apiBaseUrl).resolve(value).toString();
}

class PlayerAvatar extends StatelessWidget {
  const PlayerAvatar({
    super.key,
    required this.name,
    this.photoUrl,
    this.size = 48,
  });

  final String name;
  final String? photoUrl;
  final double size;

  String get initials => name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0].toUpperCase())
      .join();

  @override
  Widget build(BuildContext context) {
    final url = playerPhotoUrl(photoUrl);
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      backgroundImage: url == null ? null : NetworkImage(url),
      child: url == null
          ? Text(
              initials.isEmpty ? '?' : initials,
              style: TextStyle(
                fontSize: size * .32,
                fontWeight: FontWeight.w700,
              ),
            )
          : null,
    );
  }
}
