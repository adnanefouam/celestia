import 'package:dio/dio.dart';
import '../http_response.dart';

mixin PostMethod {
  Dio get dio;

  Future<HttpResponse<T>> post<T>(
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
      final response = await dio.post(
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

  // POST with JSON data
  Future<HttpResponse<T>> postJson<T>(
    String path,
    Map<String, dynamic> data, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return post<T>(
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

  // POST with form data
  Future<HttpResponse<T>> postForm<T>(
    String path,
    Map<String, dynamic> data, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    T Function(dynamic)? fromJson,
  }) async {
    return post<T>(
      path,
      data: FormData.fromMap(data),
      queryParameters: queryParameters,
      headers: headers,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      fromJson: fromJson,
    );
  }

  // POST multipart (file upload)
  Future<HttpResponse<T>> postMultipart<T>(
    String path,
    FormData formData, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    T Function(dynamic)? fromJson,
  }) async {
    return post<T>(
      path,
      data: formData,
      queryParameters: queryParameters,
      headers: headers,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      fromJson: fromJson,
    );
  }

  // POST with raw string data
  Future<HttpResponse<T>> postRaw<T>(
    String path,
    String data, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    String contentType = 'text/plain',
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    T Function(dynamic)? fromJson,
  }) async {
    return post<T>(
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

  // POST with file upload from path
  Future<HttpResponse<T>> postFile<T>(
    String path,
    String filePath, {
    String? filename,
    String? fieldName = 'file',
    Map<String, dynamic>? additionalData,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    T Function(dynamic)? fromJson,
  }) async {
    final formData = FormData.fromMap({
      if (additionalData != null) ...additionalData,
      fieldName!: await MultipartFile.fromFile(
        filePath,
        filename: filename,
      ),
    });

    return postMultipart<T>(
      path,
      formData,
      queryParameters: queryParameters,
      headers: headers,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      fromJson: fromJson,
    );
  }

  // POST with multiple files
  Future<HttpResponse<T>> postFiles<T>(
    String path,
    List<String> filePaths, {
    List<String>? filenames,
    String fieldName = 'files',
    Map<String, dynamic>? additionalData,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    T Function(dynamic)? fromJson,
  }) async {
    final formDataMap = <String, dynamic>{
      if (additionalData != null) ...additionalData,
    };

    for (int i = 0; i < filePaths.length; i++) {
      final file = await MultipartFile.fromFile(
        filePaths[i],
        filename: filenames?[i],
      );
      formDataMap['${fieldName}[$i]'] = file;
    }

    final formData = FormData.fromMap(formDataMap);

    return postMultipart<T>(
      path,
      formData,
      queryParameters: queryParameters,
      headers: headers,
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
