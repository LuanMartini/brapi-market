import 'package:brapi_market/src/core/formatters.dart';
import 'package:brapi_market/src/data/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StockQuote', () {
    test('aceita numeros inteiros, decimais, nulos e logourl', () {
      final quote = StockQuote.fromEnvelope({
        'requestedSymbol': 'PETR4',
        'symbol': 'PETR4',
        'changed': false,
        'data': {
          'shortName': 'PETROBRAS PN',
          'regularMarketPrice': 31,
          'regularMarketChangePercent': 1.34,
          'regularMarketVolume': 1000.0,
          'regularMarketDayHigh': null,
          'logourl': 'https://example.com/petr.png',
        },
      });

      expect(quote.symbol, 'PETR4');
      expect(quote.price, 31.0);
      expect(quote.volume, 1000);
      expect(quote.dayHigh, isNull);
      expect(quote.logoUrl, 'https://example.com/petr.png');
    });

    test('aceita logoUrl como variante', () {
      final quote = StockQuote.fromData(
          'VALE3', {'logoUrl': 'https://example.com/vale.png'});
      expect(quote.logoUrl, 'https://example.com/vale.png');
    });
  });

  group('datas flexiveis', () {
    test('converte timestamp Unix em segundos', () {
      expect(parseFlexibleDate(1704067200), DateTime.utc(2024));
    });

    test('converte ISO e YYYY-MM-DD', () {
      expect(parseFlexibleDate('2026-10-07')?.year, 2026);
      expect(parseFlexibleDate('2026-10-07T12:00:00Z')?.hour, 12);
    });
  });

  test('FinancialData conserva apenas propriedades primitivas presentes', () {
    final data = FinancialData.fromJson({
      'revenue': 100,
      'period': '2026',
      'nested': {'ignored': true},
      'list': [1, 2],
    });
    expect(data.values, {'revenue': 100, 'period': '2026'});
  });

  test('MacroLatest interpreta series e latest aninhados', () {
    final macro = MacroLatest.fromJson({
      'series': {
        'slug': 'selic',
        'name': 'Taxa Selic',
        'unit': 'percentPerYear'
      },
      'latest': {'date': '2026-04-30', 'value': 14.5},
    });
    expect(macro.slug, 'selic');
    expect(macro.value, 14.5);
    expect(macro.date, DateTime(2026, 4, 30));
  });

  test('AssetCoverage converte availableData em capacidades', () {
    final coverage = AssetCoverage.fromJson({
      'symbol': 'PETR4',
      'availableData': {
        'quote': true,
        'historical': true,
        'stockDividends': false,
        'fiiDividends': false,
        'profile': true,
        'statistics': true,
        'financialStatements': false,
      },
    });
    expect(coverage.historical, isTrue);
    expect(coverage.dividends, isFalse);
    expect(coverage.financialData, isFalse);
  });
}
