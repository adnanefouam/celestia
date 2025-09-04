import 'package:equatable/equatable.dart';

abstract class ApiResponse<T> extends Equatable {
  const ApiResponse();
}

class ApiSuccess<T> extends ApiResponse<T> {
  final T data;
  final String? message;
  final int? statusCode;

  const ApiSuccess({
    required this.data,
    this.message,
    this.statusCode,
  });

  @override
  List<Object?> get props => [data, message, statusCode];
}

class ApiError<T> extends ApiResponse<T> {
  final String message;
  final int? statusCode;
  final String? errorCode;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const ApiError({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.originalError,
    this.stackTrace,
  });

  @override
  List<Object?> get props => [
        message,
        statusCode,
        errorCode,
        originalError,
        stackTrace,
      ];

  bool get isNetworkError => statusCode == null;
  bool get isServerError => statusCode != null && statusCode! >= 500;
  bool get isClientError =>
      statusCode != null && statusCode! >= 400 && statusCode! < 500;
  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isTooManyRequests => statusCode == 429;

  String get userFriendlyMessage {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input and try again.';
      case 401:
        return 'Authentication failed. Please check your API key.';
      case 403:
        return 'Access forbidden. You don\'t have permission to access this resource.';
      case 404:
        return 'The requested data was not found.';
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
        return message;
    }
  }
}

class ApiLoading<T> extends ApiResponse<T> {
  final String? message;
  final double? progress;

  const ApiLoading({
    this.message,
    this.progress,
  });

  @override
  List<Object?> get props => [message, progress];
}

extension ApiResponseExtensions<T> on ApiResponse<T> {
  bool get isSuccess => this is ApiSuccess<T>;
  bool get isError => this is ApiError<T>;
  bool get isLoading => this is ApiLoading<T>;

  T? get data => isSuccess ? (this as ApiSuccess<T>).data : null;
  String? get error => isError ? (this as ApiError<T>).message : null;
  String? get userFriendlyError =>
      isError ? (this as ApiError<T>).userFriendlyMessage : null;

  R when<R>({
    required R Function(T data) success,
    required R Function(String message, int? statusCode) error,
    required R Function() loading,
  }) {
    if (this is ApiSuccess<T>) {
      final successResponse = this as ApiSuccess<T>;
      return success(successResponse.data);
    } else if (this is ApiError<T>) {
      final errorResponse = this as ApiError<T>;
      return error(errorResponse.message, errorResponse.statusCode);
    } else if (this is ApiLoading<T>) {
      return loading();
    } else {
      throw Exception('Unknown ApiResponse type');
    }
  }

  R maybeWhen<R>({
    R Function(T data)? success,
    R Function(String message, int? statusCode)? error,
    R Function()? loading,
    required R Function() orElse,
  }) {
    if (this is ApiSuccess<T> && success != null) {
      final successResponse = this as ApiSuccess<T>;
      return success(successResponse.data);
    } else if (this is ApiError<T> && error != null) {
      final errorResponse = this as ApiError<T>;
      return error(errorResponse.message, errorResponse.statusCode);
    } else if (this is ApiLoading<T> && loading != null) {
      return loading();
    } else {
      return orElse();
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;
  final dynamic originalError;

  const ApiException({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.originalError,
  });

  @override
  String toString() {
    return 'ApiException: $message (Status: $statusCode, Code: $errorCode)';
  }
}

class NetworkException extends ApiException {
  const NetworkException({
    required super.message,
    super.originalError,
  }) : super(statusCode: null, errorCode: 'NETWORK_ERROR');
}

class TimeoutException extends ApiException {
  const TimeoutException({
    required super.message,
    super.originalError,
  }) : super(statusCode: null, errorCode: 'TIMEOUT_ERROR');
}

class ParseException extends ApiException {
  const ParseException({
    required super.message,
    super.originalError,
  }) : super(statusCode: null, errorCode: 'PARSE_ERROR');
}
