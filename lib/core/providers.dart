import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'network/api_client.dart';

/// Creato in `main()` e iniettato con `overrideWithValue`.
final apiClientProvider = Provider<ApiClient>(
  (ref) => throw UnimplementedError('apiClientProvider va sovrascritto'),
);

/// Ora corrente; nei test si sostituisce con un orario fisso.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
