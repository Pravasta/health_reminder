import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../exception/api_error_handler.dart';
import '../exception/network_exception.dart';
import 'network_logger.dart';

abstract class HttpClient<T> {
  Future<T> get(Uri url, {Map<String, String>? headers});
  Future<T> post(Uri url, {Map<String, String>? headers, Object? body});
  Future<T> put(Uri url, {Map<String, String>? headers, Object? body});
  Future<T> delete(Uri url, {Map<String, String>? headers});
  Future<T> patch(Uri url, {Map<String, String>? headers, Object? body});
}

class CustomHttpClient implements HttpClient {
  final http.Client _client;
  final Duration timeout;

  CustomHttpClient(this._client, {this.timeout = const Duration(seconds: 30)});

  factory CustomHttpClient.create({Duration? timeout}) {
    return CustomHttpClient(
      http.Client(),
      timeout: timeout ?? const Duration(seconds: 15),
    );
  }

  @override
  Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    try {
      final response = await _client
          .delete(url, headers: headers, body: body)
          .timeout(timeout);

      appNetworkLogger(
        endpoint: url.toString(),
        payload: headers.toString(),
        response: response.toString(),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final errorMessage = json.decode(response.body);

        throw ApiErrorHandler.handlerError(
          statusCode: response.statusCode,
          message: errorMessage['message'] ?? response.body,
        );
      }

      return response;
    } on SocketException {
      throw NoInternetException();
    } on TimeoutException {
      throw ServerException();
    } catch (exception) {
      rethrow;
    }
  }

  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    try {
      final response = await _client
          .get(url, headers: headers)
          .timeout(timeout);
      appNetworkLogger(
        endpoint: url.toString(),
        payload: headers.toString(),
        response: response.toString(),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final errorMessage = json.decode(response.body);

        throw ApiErrorHandler.handlerError(
          statusCode: response.statusCode,
          message: errorMessage['message'] ?? response.body,
        );
      }

      return response;
    } on SocketException {
      throw NoInternetException();
    } on TimeoutException {
      throw ServerException();
    } catch (exception) {
      rethrow;
    }
  }

  @override
  Future<http.Response> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    try {
      final response = await _client
          .patch(url, headers: headers, body: body)
          .timeout(timeout);

      appNetworkLogger(
        endpoint: url.toString(),
        payload: body?.toString() ?? '',
        response: response.toString(),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final errorMessage = json.decode(response.body);

        throw ApiErrorHandler.handlerError(
          statusCode: response.statusCode,
          message: errorMessage['message'] ?? response.body,
        );
      }

      return response;
    } on SocketException {
      throw NoInternetException();
    } on TimeoutException {
      throw ServerException();
    } catch (exception) {
      rethrow;
    }
  }

  @override
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    try {
      final response = await _client
          .post(url, headers: headers, body: body)
          .timeout(timeout);

      appNetworkLogger(
        endpoint: url.toString(),
        payload: body?.toString() ?? '',
        response: response.toString(),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final errorMessage = json.decode(response.body);

        throw ApiErrorHandler.handlerError(
          statusCode: response.statusCode,
          message: errorMessage['message'] ?? response.body,
        );
      }

      return response;
    } on SocketException {
      throw NoInternetException();
    } on TimeoutException {
      throw ServerException();
    } catch (exception) {
      rethrow;
    }
  }

  @override
  Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    try {
      final response = await _client
          .put(url, headers: headers, body: body)
          .timeout(timeout);

      appNetworkLogger(
        endpoint: url.toString(),
        payload: body?.toString() ?? '',
        response: response.toString(),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final errorMessage = json.decode(response.body);

        throw ApiErrorHandler.handlerError(
          statusCode: response.statusCode,
          message: errorMessage['message'] ?? response.body,
        );
      }

      return response;
    } on SocketException {
      throw NoInternetException();
    } on TimeoutException {
      throw ServerException();
    } catch (exception) {
      rethrow;
    }
  }
}
