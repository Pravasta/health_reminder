/// [Default Response] is a class representing a default response
/// From the API, it can be used for any response that does not require specific data
/// It can be used for responses that only need to indicate success or failure, without returning any additional data
class DefaultResponse<T> {
  final String message;
  final T data;

  DefaultResponse({required this.message, required this.data});

  // fromJson is not needed because this class is only used for responses that do not require specific data
  factory DefaultResponse.fromJson(Map<String, dynamic> json) {
    return DefaultResponse(message: json['message'], data: json['data']);
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'data': data};
  }
}
