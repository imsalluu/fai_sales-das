import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'network_client.dart';
import 'token_service.dart';

final networkClientProvider = Provider<NetworkClient>((ref) {
  return NetworkClient(
    onUnAuthorize: () {
      TokenService.clear();
      // Note: Navigation to login should be handled by the router or auth provider listener
    },
    commonHeaders: () => {
      "Content-Type": "application/json",
      if (TokenService.accessToken != null)
        "Authorization": "Bearer ${TokenService.accessToken}",
    },
  );
});
