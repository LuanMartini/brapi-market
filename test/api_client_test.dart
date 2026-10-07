import 'package:brapi_market/src/core/api_failure.dart';
import 'package:brapi_market/src/core/brapi_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('monta URL e headers autenticados', () {
    final client = BrapiClient(dio: Dio(), apiKey: 'token-teste');
    final uri = client.buildUri('/v2/stocks/quote', {'symbols': 'PETR4,VALE3'});

    expect(uri.toString(), contains('/api/v2/stocks/quote'));
    expect(uri.queryParameters['symbols'], 'PETR4,VALE3');
    expect(client.defaultHeaders['Authorization'], 'Bearer token-teste');
    expect(client.defaultHeaders['Accept'], 'application/json');
  });

  for (final status in [403, 404, 429, 500, 503]) {
    test('converte HTTP $status em erro tipado', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response<Object?>(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: status,
          headers: Headers.fromMap({
            'retry-after': ['2']
          }),
        ),
      );
      final failure = ApiFailure.fromDio(error);
      expect(failure.statusCode, status);
      if (status == 429) expect(failure.retryAfter, const Duration(seconds: 2));
    });
  }
}
