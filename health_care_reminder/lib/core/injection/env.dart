import 'package:flutter_dotenv/flutter_dotenv.dart';

enum Environment { development, production, staging, testing }

extension EnvironmentExtension on Environment {
  String get value {
    switch (this) {
      case Environment.development:
        return 'development';
      case Environment.production:
        return 'production';
      case Environment.staging:
        return 'staging';
      case Environment.testing:
        return 'testing';
    }
  }

  String get schema {
    switch (this) {
      case Environment.development:
        return dotenv.env['API_SCHEME_DEV'].toString();
      case Environment.production:
        return dotenv.env['API_SCHEME_PROD'].toString();
      case Environment.staging:
        return dotenv.env['API_SCHEME_STAGING'].toString();
      case Environment.testing:
        return dotenv.env['API_SCHEME_TESTING'].toString();
    }
  }

  String get baseURL {
    switch (this) {
      case Environment.development:
        return dotenv.env['API_BASE_URL_DEV'].toString();
      case Environment.production:
        return dotenv.env['API_BASE_URL_PROD'].toString();
      case Environment.staging:
        return dotenv.env['API_BASE_URL_STAGING'].toString();
      case Environment.testing:
        return dotenv.env['API_BASE_URL_TESTING'].toString();
    }
  }

  int get port {
    switch (this) {
      case Environment.development:
        return 8080;
      case Environment.production:
        return 8080;
      case Environment.staging:
        return 8081;
      case Environment.testing:
        return 8082;
    }
  }

  String get baseImageUrl {
    switch (this) {
      case Environment.development:
        return 'covers.openlibrary.org/b/id';
      case Environment.production:
        return 'covers.openlibrary.org/b/id';
      case Environment.staging:
        return 'covers.openlibrary.org/b/id';
      case Environment.testing:
        return 'covers.openlibrary.org/b/id';
    }
  }

  bool get isDevelopMode {
    switch (this) {
      case Environment.development:
        return true;
      case Environment.production:
        return false;
      case Environment.staging:
        return false;
      case Environment.testing:
        return true;
    }
  }
}
