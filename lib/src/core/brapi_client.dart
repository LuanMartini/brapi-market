import 'dart:async';
import 'dart:io';

import 'package:brapi_market/src/core/api_failure.dart';
import 'package:brapi_market/src/core/app_config.dart';
import 'package:dio/dio.dart';

final class BrapiClient {
  BrapiClient({required Dio dio, required String apiKey})
      : _dio = dio,
        _apiKey = apiKey.trim();

  final Dio _dio;
  final String _apiKey;

  Map<String, String> get defaultHeaders => <String, String>{
        'Accept': 'application/json',
        if (_apiKey.isNotEmpty) 'Authorization': 'Bearer $_apiKey',
      };

  Uri buildUri(String path, [Map<String, Object?> query = const {}]) {
    return Uri.parse('${AppConfig.apiBaseUrl}$path').replace(
      queryParameters: query.map(
        (key, value) => MapEntry(key, value?.toString()),
      )..removeWhere((_, value) => value == null || value.isEmpty),
    );
  }

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, Object?> query = const {},
    CancelToken? cancelToken,
  }) async {
    const retryableStatuses = <int>{429, 500, 503};
    DioException? lastError;

    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final response = await _dio.get<Object?>(
          path,
          queryParameters: query,
          cancelToken: cancelToken,
          options: Options(headers: defaultHeaders),
        );
        final data = response.data;
        if (data is Map<String, dynamic>) return data;
        if (data is Map) return Map<String, dynamic>.from(data);
        throw const ApiFailure(
          FailureKind.invalidResponse,
          'A API retornou uma resposta em formato inesperado.',
        );
      } on DioException catch (error) {
        if (CancelToken.isCancel(error)) rethrow;
        lastError = error;
        final status = error.response?.statusCode;
        final transient = retryableStatuses.contains(status) ||
            error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.connectionError ||
            (error.type == DioExceptionType.unknown &&
                error.error is SocketException);
        if (!transient || attempt == 2) throw ApiFailure.fromDio(error);

        final retryHeader = error.response?.headers.value('retry-after');
        final retrySeconds = int.tryParse(retryHeader ?? '');
        final delay = retrySeconds == null
            ? Duration(milliseconds: 400 * (attempt + 1))
            : Duration(seconds: retrySeconds.clamp(1, 10).toInt());
        await Future<void>.delayed(delay);
      }
    }
    throw ApiFailure.fromDio(lastError!);
  }
}
