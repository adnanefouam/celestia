import 'package:dio/dio.dart';
import '../http_response.dart';

mixin PatchMethod {
  Dio get dio;

  Future<HttpResponse<T>> patch<T>(
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
      final response = await dio.patch(
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

  // PATCH with JSON data
  Future<HttpResponse<T>> patchJson<T>(
    String path,
    Map<String, dynamic> data, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return patch<T>(
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

  // PATCH with form data
  Future<HttpResponse<T>> patchForm<T>(
    String path,
    Map<String, dynamic> data, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    T Function(dynamic)? fromJson,
  }) async {
    return patch<T>(
      path,
      data: FormData.fromMap(data),
      queryParameters: queryParameters,
      headers: headers,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      fromJson: fromJson,
    );
  }

  // PATCH partial update (common pattern for updating specific fields)
  Future<HttpResponse<T>> patchPartial<T>(
    String path,
    Map<String, dynamic> updates, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    T Function(dynamic)? fromJson,
  }) async {
    // Remove null values for partial updates
    final cleanUpdates = Map<String, dynamic>.from(updates)
      ..removeWhere((key, value) => value == null);

    return patchJson<T>(
      path,
      cleanUpdates,
      queryParameters: queryParameters,
      headers: headers,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      fromJson: fromJson,
    );
  }

  // PATCH by ID (common pattern)
  Future<HttpResponse<T>> patchById<T>(
    String basePath,
    String id,
    Map<String, dynamic> data, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    T Function(dynamic)? fromJson,
  }) async {
    return patchJson<T>(
      '$basePath/$id',
      data,
      queryParameters: queryParameters,
      headers: headers,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      fromJson: fromJson,
    );
  }

  // PATCH with JSON Merge Patch (RFC 7396)
  Future<HttpResponse<T>> patchJsonMerge<T>(
    String path,
    Map<String, dynamic> data, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    T Function(dynamic)? fromJson,
  }) async {
    return patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      headers: {
        'Content-Type': 'application/merge-patch+json',
        ...?headers,
      },
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      fromJson: fromJson,
    );
  }

  // PATCH with JSON Patch (RFC 6902)
  Future<HttpResponse<T>> patchJsonPatch<T>(
    String path,
    List<Map<String, dynamic>> operations, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    T Function(dynamic)? fromJson,
  }) async {
    return patch<T>(
      path,
      data: operations,
      queryParameters: queryParameters,
      headers: {
        'Content-Type': 'application/json-patch+json',
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
