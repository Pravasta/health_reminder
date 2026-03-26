import 'api_exception.dart';

class ApiErrorHandler {
  static ApiException handlerError({
    required int statusCode,
    String message = '',
  }) {
    switch (statusCode) {
      case 400:
        return BadRequestException(message: message);
      case 401:
        return UnauthorizedException(message: message);
      case 402:
        return PaymentRequiredException(message: message);
      case 403:
        return ForbiddenException(message: message);
      case 404:
        return NotFoundException(message: message);
      case 408:
        return RequestTimeoutException(message: message);
      case 405:
        return MethodNotAllowedException(message: message);
      case 406:
        return NotAcceptableException(message: message);
      case 500:
        return InternalServerErrorException(message: message);
      case 501:
        return NotImplementedException(message: message);
      case 502:
        return BadGatewayException(message: message);
      default:
        return ApiException(
          message: 'Received invalid status code: $statusCode',
        );
    }
  }
}
