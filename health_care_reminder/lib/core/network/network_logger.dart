import 'dart:developer';

import 'package:flutter/foundation.dart';

void appNetworkLogger({
  required String endpoint,
  required String payload,
  required String response,
}) {
  if (kDebugMode) {
    log('===============================================');
    log('Endpoint: $endpoint');
    log('Payload: $payload');
    log('Response: $response');
    log('===============================================');
  }
}
