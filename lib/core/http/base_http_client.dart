import 'package:dio/dio.dart';
import '../api/api_config.dart';
import '../api/endpoints.dart';
import 'methods/get_method.dart';
import 'methods/post_method.dart';
import 'methods/put_method.dart';
import 'methods/patch_method.dart';
import 'methods/delete_method.dart';

class BaseHttpClient
    with GetMethod, PostMethod, PutMethod, PatchMethod, DeleteMethod {
  @override
  late final Dio dio;

  BaseHttpClient({
    String? baseUrl,
    Map<String, dynamic>? defaultQueryParameters,
    Map<String, String>? headers,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    List<Interceptor>? interceptors,
    bool enableLogging = true,
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

    dio = Dio(baseOptions);

    // Add default interceptors
    dio.interceptors.addAll(
      ApiConfig.createInterceptors(
        enableLogging: enableLogging,
      ),
    );

    // Add custom interceptors if provided
    if (interceptors != null) {
      dio.interceptors.addAll(interceptors);
    }
  }

  // Factory constructors for common configurations
  factory BaseHttpClient.api({
    required String baseUrl,
    required String apiKey,
    Map<String, dynamic>? defaultQueryParameters,
    Map<String, String>? headers,
    Duration? timeout,
  }) {
    return BaseHttpClient(
      baseUrl: baseUrl,
      defaultQueryParameters: {
        ApiQueryParams.apiKey: apiKey,
        ...?defaultQueryParameters,
      },
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        ...?headers,
      },
      connectTimeout: timeout,
      receiveTimeout: timeout,
      sendTimeout: timeout,
    );
  }

  factory BaseHttpClient.json({
    String? baseUrl,
    Map<String, String>? headers,
    Duration? timeout,
  }) {
    return BaseHttpClient(
      baseUrl: baseUrl,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        ...?headers,
      },
      connectTimeout: timeout,
      receiveTimeout: timeout,
      sendTimeout: timeout,
    );
  }

  factory BaseHttpClient.formData({
    String? baseUrl,
    Map<String, String>? headers,
    Duration? timeout,
  }) {
    return BaseHttpClient(
      baseUrl: baseUrl,
      headers: {
        'Content-Type': 'multipart/form-data',
        ...?headers,
      },
      connectTimeout: timeout,
      receiveTimeout: timeout,
      sendTimeout: timeout,
    );
  }

  // Configuration methods
  void updateBaseUrl(String baseUrl) {
    dio.options.baseUrl = baseUrl;
  }

  void updateHeaders(Map<String, String> headers) {
    dio.options.headers.addAll(headers);
  }

  void setHeader(String key, String value) {
    dio.options.headers[key] = value;
  }

  void removeHeader(String key) {
    dio.options.headers.remove(key);
  }

  void updateQueryParameters(Map<String, dynamic> queryParameters) {
    dio.options.queryParameters.addAll(queryParameters);
  }

  void setQueryParameter(String key, dynamic value) {
    dio.options.queryParameters[key] = value;
  }

  void removeQueryParameter(String key) {
    dio.options.queryParameters.remove(key);
  }

  void setTimeout({
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
  }) {
    if (connectTimeout != null) dio.options.connectTimeout = connectTimeout;
    if (receiveTimeout != null) dio.options.receiveTimeout = receiveTimeout;
    if (sendTimeout != null) dio.options.sendTimeout = sendTimeout;
  }

  void addInterceptor(Interceptor interceptor) {
    dio.interceptors.add(interceptor);
  }

  void removeInterceptor(Interceptor interceptor) {
    dio.interceptors.remove(interceptor);
  }

  void clearInterceptors() {
    dio.interceptors.clear();
  }

  CancelToken createCancelToken() {
    return CancelToken();
  }

  void cancelRequests([String? reason]) {
    dio.close(force: true);
  }

  void dispose() {
    dio.close();
  }

  // Utility methods for common headers
  void setAuthorizationHeader(String token, {String type = 'Bearer'}) {
    setHeader('Authorization', '$type $token');
  }

  void setApiKeyHeader(String apiKey, {String headerName = 'X-API-Key'}) {
    setHeader(headerName, apiKey);
  }

  void setUserAgent(String userAgent) {
    setHeader('User-Agent', userAgent);
  }

  void setContentType(String contentType) {
    setHeader('Content-Type', contentType);
  }

  void setAccept(String accept) {
    setHeader('Accept', accept);
  }

  // Common authentication patterns
  void setBearerToken(String token) {
    setAuthorizationHeader(token, type: 'Bearer');
  }

  void setBasicAuth(String username, String password) {
    final credentials = '$username:$password';
    final encoded = credentials; // In real implementation, use base64 encoding
    setAuthorizationHeader(encoded, type: 'Basic');
  }

  void clearAuth() {
    removeHeader('Authorization');
  }
}
