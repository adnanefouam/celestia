import 'package:equatable/equatable.dart';

class HttpResponse<T> extends Equatable {
  final T? data;
  final String? message;
  final int? statusCode;
  final String? errorCode;
  final Map<String, List<String>>? headers;
  final dynamic originalError;
  final StackTrace? stackTrace;
  final bool isSuccess;

  const HttpResponse._({
    this.data,
    this.message,
    this.statusCode,
    this.errorCode,
    this.headers,
    this.originalError,
    this.stackTrace,
    required this.isSuccess,
  });

  // Success constructor
  factory HttpResponse.success({
    required T data,
    int? statusCode,
    String? message,
    Map<String, List<String>>? headers,
  }) {
    return HttpResponse._(
      data: data,
      message: message,
      statusCode: statusCode,
      headers: headers,
      isSuccess: true,
    );
  }

  // Error constructor
  factory HttpResponse.error({
    required String message,
    int? statusCode,
    String? errorCode,
    Map<String, List<String>>? headers,
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return HttpResponse._(
      message: message,
      statusCode: statusCode,
      errorCode: errorCode,
      headers: headers,
      originalError: originalError,
      stackTrace: stackTrace,
      isSuccess: false,
    );
  }

  // Loading constructor
  factory HttpResponse.loading({
    String? message,
  }) {
    return HttpResponse._(
      message: message,
      isSuccess: false,
    );
  }

  @override
  List<Object?> get props => [
        data,
        message,
        statusCode,
        errorCode,
        headers,
        originalError,
        stackTrace,
        isSuccess,
      ];

  // Convenience getters
  bool get isError => !isSuccess;
  bool get isLoading => !isSuccess && statusCode == null;

  bool get isNetworkError => statusCode == null && originalError != null;
  bool get isServerError => statusCode != null && statusCode! >= 500;
  bool get isClientError =>
      statusCode != null && statusCode! >= 400 && statusCode! < 500;
  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isTooManyRequests => statusCode == 429;

  String get userFriendlyMessage {
    if (isSuccess) return message ?? 'Request successful';

    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input and try again.';
      case 401:
        return 'Authentication failed. Please check your credentials.';
      case 403:
        return 'Access forbidden. You don\'t have permission to access this resource.';
      case 404:
        return 'The requested resource was not found.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
        return 'Bad gateway. The server is temporarily unavailable.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        if (isNetworkError) {
          return 'Network error. Please check your internet connection.';
        }
        return message ?? 'An error occurred';
    }
  }

  // Transform the data
  HttpResponse<R> map<R>(R Function(T) transform) {
    if (isSuccess && data != null) {
      try {
        final transformedData = transform(data as T);
        return HttpResponse.success(
          data: transformedData,
          statusCode: statusCode,
          message: message,
          headers: headers,
        );
      } catch (e, stackTrace) {
        return HttpResponse.error(
          message: 'Failed to transform data: $e',
          statusCode: statusCode,
          errorCode: errorCode,
          headers: headers,
          originalError: e,
          stackTrace: stackTrace,
        );
      }
    } else {
      return HttpResponse.error(
        message: message ?? 'No data to transform',
        statusCode: statusCode,
        errorCode: errorCode,
        headers: headers,
        originalError: originalError,
        stackTrace: stackTrace,
      );
    }
  }

  // Async transform
  Future<HttpResponse<R>> mapAsync<R>(Future<R> Function(T) transform) async {
    if (isSuccess && data != null) {
      try {
        final transformedData = await transform(data as T);
        return HttpResponse.success(
          data: transformedData,
          statusCode: statusCode,
          message: message,
          headers: headers,
        );
      } catch (e, stackTrace) {
        return HttpResponse.error(
          message: 'Failed to transform data: $e',
          statusCode: statusCode,
          errorCode: errorCode,
          headers: headers,
          originalError: e,
          stackTrace: stackTrace,
        );
      }
    } else {
      return HttpResponse.error(
        message: message ?? 'No data to transform',
        statusCode: statusCode,
        errorCode: errorCode,
        headers: headers,
        originalError: originalError,
        stackTrace: stackTrace,
      );
    }
  }

  // Pattern matching
  R when<R>({
    required R Function(T data) success,
    required R Function(String message, int? statusCode) error,
    R Function()? loading,
  }) {
    if (isSuccess && data != null) {
      return success(data as T);
    } else if (isLoading && loading != null) {
      return loading();
    } else {
      return error(message ?? 'Unknown error', statusCode);
    }
  }

  // Optional pattern matching
  R maybeWhen<R>({
    R Function(T data)? success,
    R Function(String message, int? statusCode)? error,
    R Function()? loading,
    required R Function() orElse,
  }) {
    if (isSuccess && data != null && success != null) {
      return success(data as T);
    } else if (isLoading && loading != null) {
      return loading();
    } else if (isError && error != null) {
      return error(message ?? 'Unknown error', statusCode);
    } else {
      return orElse();
    }
  }

  // Fold operation
  R fold<R>(
    R Function(String message, int? statusCode) onError,
    R Function(T data) onSuccess,
  ) {
    if (isSuccess && data != null) {
      return onSuccess(data as T);
    } else {
      return onError(message ?? 'Unknown error', statusCode);
    }
  }

  // Get data or throw
  T get dataOrThrow {
    if (isSuccess && data != null) {
      return data as T;
    } else {
      throw Exception(message ?? 'Request failed');
    }
  }

  // Get data or return default
  T dataOr(T defaultValue) {
    return isSuccess && data != null ? data as T : defaultValue;
  }

  // Chain operations
  HttpResponse<R> chain<R>(HttpResponse<R> Function(T) nextOperation) {
    if (isSuccess && data != null) {
      return nextOperation(data as T);
    } else {
      return HttpResponse.error(
        message: message ?? 'Previous operation failed',
        statusCode: statusCode,
        errorCode: errorCode,
        headers: headers,
        originalError: originalError,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'HttpResponse.success(data: $data, statusCode: $statusCode)';
    } else {
      return 'HttpResponse.error(message: $message, statusCode: $statusCode)';
    }
  }
}
