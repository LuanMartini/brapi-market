import 'dart:io';

import 'package:dio/dio.dart';

enum FailureKind {
  missingToken,
  unauthorized,
  forbidden,
  notFound,
  rateLimited,
  server,
  timeout,
  offline,
  invalidResponse,
  unknown,
}

final class ApiFailure implements Exception {
  const ApiFailure(this.kind, this.message, {this.statusCode, this.retryAfter});

  factory ApiFailure.fromDio(DioException error) {
    final status = error.response?.statusCode;
    final retryHeader = error.response?.headers.value('retry-after');
    final retrySeconds = int.tryParse(retryHeader ?? '');
    final retryAfter =
        retrySeconds == null ? null : Duration(seconds: retrySeconds);

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const ApiFailure(
          FailureKind.timeout, 'A conexão demorou mais que o esperado.');
    }
    if (error.type == DioExceptionType.connectionError ||
        (error.type == DioExceptionType.unknown &&
            error.error is SocketException)) {
      return const ApiFailure(
          FailureKind.offline, 'Sem conexão com a internet.');
    }

    return switch (status) {
      401 => const ApiFailure(
          FailureKind.unauthorized,
          'Token ausente, inválido ou sem acesso ao recurso.',
          statusCode: 401,
        ),
      403 => const ApiFailure(
          FailureKind.forbidden,
          'Este recurso requer outro plano da brapi.dev.',
          statusCode: 403,
        ),
      404 => const ApiFailure(
          FailureKind.notFound,
          'Nenhum dado foi encontrado para esta consulta.',
          statusCode: 404,
        ),
      429 => ApiFailure(
          FailureKind.rateLimited,
          'O limite de consultas foi atingido. Tente novamente em instantes.',
          statusCode: 429,
          retryAfter: retryAfter,
        ),
      500 || 503 => ApiFailure(
          FailureKind.server,
          'A brapi.dev está temporariamente indisponível.',
          statusCode: status,
        ),
      _ => ApiFailure(
          FailureKind.unknown,
          error.message ?? 'Não foi possível concluir a consulta.',
          statusCode: status,
        ),
    };
  }

  final FailureKind kind;
  final String message;
  final int? statusCode;
  final Duration? retryAfter;

  @override
  String toString() => message;
}
