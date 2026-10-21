import '../config/app_environment.dart';

String? absoluteMediaUrl(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final uri = Uri.tryParse(value);
  if (uri?.hasScheme == true) return value;
  final api = Uri.parse(AppEnvironment.apiBaseUrl);
  return '${api.origin}${value.startsWith('/') ? value : '/$value'}';
}
