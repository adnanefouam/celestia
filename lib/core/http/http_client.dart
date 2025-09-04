import 'package:dio/dio.dart';
import '../api/api_config.dart';

import 'http_response.dart';

class HttpClient {
  late final Dio _dio;

  HttpClient({
    String? baseUrl,
    Map<String, dynamic>? defaultQueryParameters,
    Map<String, String>? headers,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    List<Interceptor>? interceptors,
  }) {
    final baseOptions = BaseOptions(
      baseUrl: baseUrl ?? '',
      connectTimeout: connectTimeout ?? ApiConfig.connectTimeout,
      receiveTimeout: receiveTimeout ?? ApiConfig.receiveTimeout,
      sendTimeout: sendTimeout ?? ApiConfig.sendTimeout,
      queryParameters: defaultQueryParameters,
      headers: headers,
      responseType: ResponseType.json,
      contentType: Headers.jsonContentType,
      validateStatus: (status) {
        return status != null && status >= 200 && status < 300;
      },
    );

    _dio = Dio(baseOptions);

    // Add default interceptors
    _dio.interceptors.addAll(
      ApiConfig.createInterceptors(
        enableLogging: EnvironmentConfig.enableLogging,
      ),
    );

    // Add custom interceptors if provided
    if (interceptors != null) {
      _dio.interceptors.addAll(interceptors);
    }
  }

  // GET method
  Future<HttpResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
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

  // POST method
  Future<HttpResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
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

  // PUT method
  Future<HttpResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
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

  // PATCH method
  Future<HttpResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.patch(
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

  // DELETE method
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
      final response = await _dio.delete(
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

  // HEAD method
  Future<HttpResponse<void>> head(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    try {
      final response = await _dio.head(
        path,
        queryParameters: queryParameters,
        options:
            options?.copyWith(headers: headers) ?? Options(headers: headers),
        cancelToken: cancelToken,
      );

      return HttpResponse.success(
        data: null,
        statusCode: response.statusCode,
        headers: response.headers.map,
      );
    } on DioException catch (e) {
      return _handleError<void>(e);
    } catch (e, stackTrace) {
      return HttpResponse.error(
        message: 'Unexpected error: $e',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // File download
  Future<HttpResponse<void>> download(
    String urlPath,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    Options? options,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.download(
        urlPath,
        savePath,
        queryParameters: queryParameters,
        options:
            options?.copyWith(headers: headers) ?? Options(headers: headers),
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );

      return HttpResponse.success(
        data: null,
        statusCode: response.statusCode,
        headers: response.headers.map,
      );
    } on DioException catch (e) {
      return _handleError<void>(e);
    } catch (e, stackTrace) {
      return HttpResponse.error(
        message: 'Unexpected error: $e',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // File upload
  Future<HttpResponse<T>> upload<T>(
    String path,
    FormData formData, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    Options? options,
    void Function(int, int)? onSendProgress,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: formData,
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

  // Private helper methods
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
    final message = ApiErrorHandler.handleDioException(error);
    final statusCode = ApiErrorHandler.getStatusCode(error);
    final responseData = ApiErrorHandler.getResponseData(error);

    String? errorCode;
    if (responseData != null && responseData.containsKey('cod')) {
      errorCode = responseData['cod'].toString();
    }

    return HttpResponse.error(
      message: message,
      statusCode: statusCode,
      errorCode: errorCode,
      originalError: error,
      headers: error.response?.headers.map,
    );
  }

  // Utility methods
  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }

  void removeInterceptor(Interceptor interceptor) {
    _dio.interceptors.remove(interceptor);
  }

  void clearInterceptors() {
    _dio.interceptors.clear();
  }

  void updateBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  void updateHeaders(Map<String, String> headers) {
    _dio.options.headers.addAll(headers);
  }

  void updateQueryParameters(Map<String, dynamic> queryParameters) {
    _dio.options.queryParameters.addAll(queryParameters);
  }

  void setTimeout({
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
  }) {
    if (connectTimeout != null) _dio.options.connectTimeout = connectTimeout;
    if (receiveTimeout != null) _dio.options.receiveTimeout = receiveTimeout;
    if (sendTimeout != null) _dio.options.sendTimeout = sendTimeout;
  }

  CancelToken createCancelToken() {
    return CancelToken();
  }

  void cancelRequests([String? reason]) {
    _dio.close(force: true);
  }

  void dispose() {
    _dio.close();
  }
}
