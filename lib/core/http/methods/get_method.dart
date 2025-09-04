import 'package:dio/dio.dart';
import '../http_response.dart';

mixin GetMethod {
  Dio get dio;

  Future<HttpResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await dio.get(
        path,
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

  // GET with automatic JSON parsing
  Future<HttpResponse<T>> getJson<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
  }) async {
    return get<T>(
      path,
      queryParameters: queryParameters,
      headers: headers,
      cancelToken: cancelToken,
      fromJson: (data) => fromJson(data as Map<String, dynamic>),
    );
  }

  // GET list with automatic JSON parsing
  Future<HttpResponse<List<T>>> getList<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
  }) async {
    return get<List<T>>(
      path,
      queryParameters: queryParameters,
      headers: headers,
      cancelToken: cancelToken,
      fromJson: (data) {
        final list = data as List<dynamic>;
        return list
            .map((item) => fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
  }

  // GET raw data (bytes)
  Future<HttpResponse<List<int>>> getBytes(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
          responseType: ResponseType.bytes,
        ),
        cancelToken: cancelToken,
      );

      return HttpResponse.success(
        data: response.data as List<int>,
        statusCode: response.statusCode,
        headers: response.headers.map,
      );
    } on DioException catch (e) {
      return _handleError<List<int>>(e);
    } catch (e, stackTrace) {
      return HttpResponse.error(
        message: 'Unexpected error: $e',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // GET stream
  Future<HttpResponse<ResponseBody>> getStream(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
          responseType: ResponseType.stream,
        ),
        cancelToken: cancelToken,
      );

      return HttpResponse.success(
        data: response.data as ResponseBody,
        statusCode: response.statusCode,
        headers: response.headers.map,
      );
    } on DioException catch (e) {
      return _handleError<ResponseBody>(e);
    } catch (e, stackTrace) {
      return HttpResponse.error(
        message: 'Unexpected error: $e',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
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
