import 'package:health_care_reminder/core/injection/env.dart';

import '../../main_app.dart';
import '../network/http_client.dart';

class Injection {
  static const String fontFamily = 'Inter';
  // static final AppSharedPrefKey sharedPrefKey = AppSharedPrefKey();
  static final HttpClient httpClient = CustomHttpClient.create();
  static final String baseUrl = appEnvironment.baseURL;
  static final String schema = appEnvironment.schema;
  static final int port = appEnvironment.port;
  static final String baseImageUrl = appEnvironment.baseImageUrl;
  static final bool isDevelopMode = appEnvironment.isDevelopMode;
  // static final HeaderProvider headerProvider = AppHeaderProvider.create();
}
