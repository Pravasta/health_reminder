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
        return 'http';
      case Environment.production:
        return 'http';
      case Environment.staging:
        return 'https';
      case Environment.testing:
        return 'https';
    }
  }

  String get baseURL {
    switch (this) {
      case Environment.development:
        return '192.168.0.107';
      case Environment.production:
        return '103.175.220.73';
      case Environment.staging:
        return 'https://staging.com';
      case Environment.testing:
        return 'https://testing.com';
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
