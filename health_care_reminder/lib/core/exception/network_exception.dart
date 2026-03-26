abstract class AppException implements Exception {
  final String message;
  AppException(this.message);

  @override
  String toString() => message;
}

class NoInternetException extends AppException {
  NoInternetException([super.message = 'No Internet connection']);
}

class ServerException extends AppException {
  ServerException([super.message = 'Server error occurred']);
}
