import 'dart:developer';
import 'package:dio/dio.dart';
import '../api/endpoints.dart';

class MyHttp {
  static var token;
  static var refreshToken;
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      receiveDataWhenStatusError: true,
      followRedirects: true,
      contentType: "application/json",
      headers: _setHeaders(),
    ),
  );

  static Map<String, dynamic> _setHeaders() {
    return {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };
  }

  _getToken() async {
    try {
      // For now, we'll use a simple approach without SharedPreferences
      // In a real app, you would store tokens in secure storage
      token = null;
      refreshToken = null;
    } catch (error) {
      throw Exception(error);
    }
  }

  _setToken(String token, String refreshToken) async {
    try {
      // For now, we'll use a simple approach without SharedPreferences
      // In a real app, you would store tokens in secure storage
      MyHttp.token = token;
      MyHttp.refreshToken = refreshToken;
    } catch (error) {
      log(error.toString());
      throw Exception(error);
    }
  }

  Future<Response> get(String url) async {
    await _getToken();

    try {
      return await dio.get(url, options: Options(headers: _setHeaders()));
    } on DioException catch (error) {
      if (error.response != null && error.response!.statusCode == 401) {
        // If the error is due to unauthorized access (401), try refreshing the token
        await _refreshToken();

        // Retry the original request with the new token
        return await dio.get(url, options: Options(headers: _setHeaders()));
      } else {
        return await dio.get(url, options: Options(headers: _setHeaders()));
        // For other errors, log and handle them appropriately
      }
    }
  }

  Future<Response> getWithoutToken(String url) async {
    try {
      return await dio.get(url);
    } on DioException {
      rethrow;
    }
  }

  Future<void> _refreshToken() async {
    try {
      final response = await dio.get(
        "/profile/refresh-token",
        options: Options(headers: {'Authorization': 'Bearer $refreshToken'}),
      );

      final newToken = response.data['token'];
      final newRefreshToken = response.data['refresh_token'];

      token = newToken;
      refreshToken = newRefreshToken;

      log("new token is $token ");

      await _setToken(token, refreshToken);

      dio.options.headers['Authorization'] = 'Bearer $token';
    } catch (error) {
      // Handle session expired
      log('Error refreshing token: $error');
      rethrow;
    }
  }

  Future<Response> post(String url, dynamic data) async {
    await _getToken();
    try {
      return await dio.post(url,
          data: data,
          options: Options(
            headers: _setHeaders(),
          ));
    } on DioException catch (error) {
      if (error.response != null && error.response!.statusCode == 401) {
        await _refreshToken();

        return await dio.post(url, options: Options(headers: _setHeaders()));
      } else {
        log(error.toString());
        return await dio.post(url, options: Options(headers: _setHeaders()));
      }
    }
  }

  Future<Response> postWithoutToken(String url, dynamic data) async {
    try {
      return await dio.post(url, data: data, options: Options());
    } on DioException catch (error) {
      if (error.response != null && error.response!.statusCode == 401) {
        // If the error is due to unauthorized access (401), try refreshing the token
        await _refreshToken();

        // Retry the original request with the new token
        return await dio.post(url, options: Options(headers: _setHeaders()));
      }
      // Handle other errors
      rethrow;
    }
  }

  Future<Response> delete(String url) async {
    await _getToken();
    try {
      return await dio.delete(url, options: Options(headers: _setHeaders()));
    } on DioException catch (error) {
      if (error.response != null && error.response!.statusCode == 401) {
        // If the error is due to unauthorized access (401), try refreshing the token
        await _refreshToken();

        return await dio.delete(url, options: Options(headers: _setHeaders()));
      } else {
        // For other errors, log and handle them appropriately
        log(error.toString());
        rethrow;
      }
    }
  }

  Future<Response> put(String url, dynamic data) async {
    await _getToken();
    try {
      return await dio.put(url,
          data: data,
          options: Options(
            headers: _setHeaders(),
          ));
    } on DioException catch (error) {
      if (error.response != null && error.response!.statusCode == 401) {
        // If the error is due to unauthorized access (401), try refreshing the token
        await _refreshToken();

        return await dio.put(url, options: Options(headers: _setHeaders()));
      } else {
        // For other errors, log and handle them appropriately
        log(error.toString());
        rethrow;
      }
    }
  }

  setHostString(String host) {
    dio.options.baseUrl = host;
  }

  static String getFileGetterUrl(String url) {
    return url;
  }

  Future<Response> getImage(String url) async {
    return dio.get(
      getFileGetterUrl(url),
      options: Options(
        responseType: ResponseType.bytes,
      ),
    );
  }

  Dio get dioInstance => dio;

  static final MyHttp _instance = MyHttp();
  static MyHttp get instance => _instance;
}

Dio get dioInstance => MyHttp.instance.dioInstance;
