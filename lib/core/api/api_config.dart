import 'package:dio/dio.dart';
import 'endpoints.dart';

class ApiConfig {
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);

  static const bool enableLogging = true;
  static const bool validateStatus = true;

  static BaseOptions createBaseOptions({
    required String apiKey,
    Map<String, dynamic>? defaultQueryParameters,
    Map<String, String>? headers,
  }) {
    final queryParams = <String, dynamic>{
      ApiQueryParams.apiKey: apiKey,
      ...?defaultQueryParameters,
    };

    final requestHeaders = <String, String>{
      ...ApiHeaders.defaultHeaders,
      ...?headers,
    };

    return BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      queryParameters: queryParams,
      headers: requestHeaders,
      responseType: ResponseType.json,
      contentType: Headers.jsonContentType,
      validateStatus: (status) {
        return status != null && status >= 200 && status < 300;
      },
    );
  }

  static List<Interceptor> createInterceptors({
    bool enableLogging = true,
    List<Interceptor>? customInterceptors,
  }) {
    final interceptors = <Interceptor>[];

    if (enableLogging) {
      interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
          error: true,
          logPrint: (object) {
            // In debug mode, you can use print or a logging package
            // ignore: avoid_print
            print('[DIO] $object');
          },
        ),
      );
    }

    interceptors.add(RetryInterceptor());

    if (customInterceptors != null) {
      interceptors.addAll(customInterceptors);
    }

    return interceptors;
  }
}

class RetryInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (_shouldRetry(err) &&
        _getRetryCount(err.requestOptions) < ApiConfig.maxRetries) {
      _incrementRetryCount(err.requestOptions);

      Future.delayed(ApiConfig.retryDelay, () async {
        try {
          final response = await _retry(err.requestOptions);
          handler.resolve(response);
        } catch (e) {
          handler.reject(err);
        }
      });
    } else {
      super.onError(err, handler);
    }
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }

  int _getRetryCount(RequestOptions options) {
    return options.extra['retry_count'] as int? ?? 0;
  }

  void _incrementRetryCount(RequestOptions options) {
    final retryCount = _getRetryCount(options);
    options.extra['retry_count'] = retryCount + 1;
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) {
    final dio = Dio();
    return dio.fetch(requestOptions);
  }
}

class ApiErrorHandler {
  static String handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Response timeout. Please try again.';
      case DioExceptionType.badResponse:
        return _handleStatusCodeError(error.response?.statusCode);
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.connectionError:
        return 'Connection error. Please check your internet connection.';
      case DioExceptionType.badCertificate:
        return 'Certificate error. Please try again.';
      case DioExceptionType.unknown:
        return 'An unexpected error occurred: ${error.message}';
    }
  }

  static String _handleStatusCodeError(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized. Please check your API key.';
      case 403:
        return 'Forbidden. Access denied.';
      case 404:
        return 'Data not found.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Internal server error. Please try again later.';
      case 502:
        return 'Bad gateway. Please try again later.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return 'HTTP error $statusCode occurred.';
    }
  }

  static int? getStatusCode(DioException error) {
    return error.response?.statusCode;
  }

  static Map<String, dynamic>? getResponseData(DioException error) {
    try {
      return error.response?.data as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }
}

enum Environment {
  development,
  staging,
  production,
}

class EnvironmentConfig {
  static Environment _currentEnvironment = Environment.development;

  static Environment get currentEnvironment => _currentEnvironment;

  static void setEnvironment(Environment environment) {
    _currentEnvironment = environment;
  }

  static bool get isDevelopment =>
      _currentEnvironment == Environment.development;
  static bool get isStaging => _currentEnvironment == Environment.staging;
  static bool get isProduction => _currentEnvironment == Environment.production;

  static String get baseUrl {
    switch (_currentEnvironment) {
      case Environment.development:
      case Environment.staging:
      case Environment.production:
        return ApiEndpoints.baseUrl;
    }
  }

  static bool get enableLogging {
    return isDevelopment || isStaging;
  }
}
