import 'package:dio/dio.dart';
import '../http_response.dart';

mixin PutMethod {
  Dio get dio;

  Future<HttpResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    Options? options,
    void Function(int, int)? onSendProgress,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options:
            options?.copyWith(headers: headers) ?? Options(headers: headers),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );

      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e, stackTrace) {
      return HttpResponse.error(
        message: 'Unexpected error: $e',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // PUT with JSON data
  Future<HttpResponse<T>> putJson<T>(
    String path,
    Map<String, dynamic> data, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      headers: {
        'Content-Type': 'application/json',
        ...?headers,
      },
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      fromJson: fromJson != null
          ? (responseData) => fromJson(responseData as Map<String, dynamic>)
          : null,
    );
  }

  // PUT with form data
  Future<HttpResponse<T>> putForm<T>(
    String path,
    Map<String, dynamic> data, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    T Function(dynamic)? fromJson,
  }) async {
    return put<T>(
      path,
      data: FormData.fromMap(data),
      queryParameters: queryParameters,
      headers: headers,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      fromJson: fromJson,
    );
  }

  // PUT with raw string data
  Future<HttpResponse<T>> putRaw<T>(
    String path,
    String data, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    String contentType = 'text/plain',
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    T Function(dynamic)? fromJson,
  }) async {
    return put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      headers: {
        'Content-Type': contentType,
        ...?headers,
      },
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      fromJson: fromJson,
    );
  }

  HttpResponse<T> _handleResponse<T>(
      Response response, T Function(dynamic)? fromJson) {
    if (fromJson != null) {
      final data = fromJson(response.data);
      return HttpResponse.success(
        data: data,
        statusCode: response.statusCode,
        headers: response.headers.map,
      );
    } else {
      return HttpResponse.success(
        data: response.data as T,
        statusCode: response.statusCode,
        headers: response.headers.map,
      );
    }
  }

  HttpResponse<T> _handleError<T>(DioException error) {
    return HttpResponse.error(
      message: error.message ?? 'Request failed',
      statusCode: error.response?.statusCode,
      headers: error.response?.headers.map,
      originalError: error,
    );
  }
}
