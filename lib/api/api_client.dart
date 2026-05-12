import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/endpoints.dart';
import '../utils/api_exception.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio dio;
  final _storage = const FlutterSecureStorage();

  factory ApiClient() => _instance;

  ApiClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: Endpoints.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    dio.interceptors.add(_buildAuthInterceptor());

    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: false,
        responseHeader: false,
      ));
    }
  }

  InterceptorsWrapper _buildAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          await _storage.delete(key: 'auth_token');
        }
        handler.next(e);
      },
    );
  }

  // ─── HTTP helpers ────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.get(path, queryParameters: queryParameters);
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Map<String, dynamic>> post(String path, {dynamic data}) async {
    try {
      final response = await dio.post(path, data: data);
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Map<String, dynamic>> put(String path, {dynamic data}) async {
    try {
      final response = await dio.put(path, data: data);
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Map<String, dynamic>> patch(String path, {dynamic data}) async {
    try {
      final response = await dio.patch(path, data: data);
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Map<String, dynamic>> delete(String path) async {
    try {
      final response = await dio.delete(path);
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  // ─── Response parsing ────────────────────────────────────────────────────────

  Map<String, dynamic> _parseResponse(Response response) {
    final body = response.data;
    if (body is Map<String, dynamic>) {
      if (body['success'] == false) {
        throw ApiException(
          message: body['message'] as String? ?? 'حدث خطأ غير متوقع',
          statusCode: response.statusCode,
          errors: body['errors'] as Map<String, dynamic>?,
        );
      }
      return body;
    }
    return {'success': true, 'data': body, 'message': ''};
  }

  ApiException _mapError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          message: 'انتهت مهلة الاتصال بالخادم، تحقق من اتصالك بالإنترنت',
          statusCode: 408,
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          message: 'لا يوجد اتصال بالإنترنت',
          statusCode: 0,
        );
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode ?? 500;
        final body = e.response?.data;
        final message = body is Map
            ? (body['message'] as String? ?? _statusMessage(code))
            : _statusMessage(code);
        final errors =
            body is Map ? body['errors'] as Map<String, dynamic>? : null;
        return ApiException(message: message, statusCode: code, errors: errors);
      default:
        return const ApiException(message: 'حدث خطأ غير متوقع');
    }
  }

  String _statusMessage(int code) {
    switch (code) {
      case 401:
        return 'غير مصرح لك، يرجى تسجيل الدخول مجدداً';
      case 403:
        return 'ليس لديك صلاحية الوصول';
      case 404:
        return 'لم يتم العثور على البيانات المطلوبة';
      case 422:
        return 'بيانات غير صحيحة، يرجى مراجعة المدخلات';
      case 500:
      case 502:
      case 503:
        return 'حدث خطأ في الخادم، يرجى المحاولة لاحقاً';
      default:
        return 'حدث خطأ غير متوقع (كود: $code)';
    }
  }
}
