import 'package:dio/dio.dart';
import '../http_response.dart';

mixin DeleteMethod {
  Dio get dio;

  Future<HttpResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options:
            options?.copyWith(headers: headers) ?? Options(headers: headers),
        cancelToken: cancelToken,
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

  // DELETE with JSON data
  Future<HttpResponse<T>> deleteJson<T>(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      headers: {
        'Content-Type': 'application/json',
        ...?headers,
      },
      cancelToken: cancelToken,
      fromJson: fromJson != null
          ? (responseData) => fromJson(responseData as Map<String, dynamic>)
          : null,
    );
  }

  // DELETE by ID (common pattern)
  Future<HttpResponse<T>> deleteById<T>(
    String basePath,
    String id, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    T Function(dynamic)? fromJson,
  }) async {
    return delete<T>(
      '$basePath/$id',
      queryParameters: queryParameters,
      headers: headers,
      cancelToken: cancelToken,
      fromJson: fromJson,
    );
  }

  // DELETE multiple items
  Future<HttpResponse<T>> deleteMultiple<T>(
    String path,
    List<String> ids, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    T Function(dynamic)? fromJson,
  }) async {
    return delete<T>(
      path,
      data: {'ids': ids},
      queryParameters: queryParameters,
      headers: {
        'Content-Type': 'application/json',
        ...?headers,
      },
      cancelToken: cancelToken,
      fromJson: fromJson,
    );
  }

  // Soft delete (common pattern)
  Future<HttpResponse<T>> softDelete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    T Function(dynamic)? fromJson,
  }) async {
    return delete<T>(
      path,
      data: {'deleted': true, 'deleted_at': DateTime.now().toIso8601String()},
      queryParameters: queryParameters,
      headers: {
        'Content-Type': 'application/json',
        ...?headers,
      },
      cancelToken: cancelToken,
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
