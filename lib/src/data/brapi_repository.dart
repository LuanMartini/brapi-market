import 'package:brapi_market/src/core/api_failure.dart';
import 'package:brapi_market/src/core/brapi_client.dart';
import 'package:brapi_market/src/data/models.dart';
import 'package:dio/dio.dart';

abstract interface class MarketRepository {
  Future<List<TickerItem>> searchTickers(
    String query, {
    String? type,
    int page = 1,
    CancelToken? cancelToken,
  });

  Future<AssetCoverage> getCoverage(String symbol);
  Future<List<StockQuote>> getQuotes(List<String> symbols);
  Future<StockQuote> getQuote(String symbol);
  Future<List<HistoricalPoint>> getHistory(String symbol, ChartPeriod period);
  Future<List<Dividend>> getDividends(String symbol);
  Future<CompanyProfile> getProfile(String symbol);
  Future<StockStatistics> getStatistics(String symbol);
  Future<FinancialData> getFinancialData(String symbol);
  Future<List<CurrencyQuote>> getCurrencies(List<String> pairs);
  Future<List<CryptoQuote>> getCrypto(List<String> coins);
  Future<List<MacroLatest>> getMacro(List<String> symbols);
}

final class BrapiRepository implements MarketRepository {
  const BrapiRepository(this._client);

  final BrapiClient _client;

  @override
  Future<AssetCoverage> getCoverage(String symbol) async {
    final body = await _client.getJson(
      '/v2/tickers/coverage',
      query: {'symbols': symbol},
    );
    return AssetCoverage.fromJson(_firstResult(body));
  }

  @override
  Future<List<TickerItem>> searchTickers(
    String query, {
    String? type,
    int page = 1,
    CancelToken? cancelToken,
  }) async {
    final body = await _client.getJson(
      '/v2/tickers',
      query: <String, Object?>{
        if (query.trim().isNotEmpty) 'search': query.trim(),
        if (type != null) 'type': type,
        'page': page,
        'limit': 30,
      },
      cancelToken: cancelToken,
    );
    return _items(body, const ['tickers', 'results', 'stocks'])
        .map((item) => TickerItem.fromJson(asMap(item)))
        .where((item) => item.symbol.isNotEmpty)
        .toList(growable: false);
  }

  @override
  Future<List<StockQuote>> getQuotes(List<String> symbols) async {
    if (symbols.isEmpty) return const [];
    final body = await _client.getJson(
      '/v2/stocks/quote',
      query: {'symbols': symbols.join(',')},
    );
    return _items(body, const ['results'])
        .map((item) => StockQuote.fromEnvelope(asMap(item)))
        .where((item) => item.symbol.isNotEmpty)
        .toList(growable: false);
  }

  @override
  Future<StockQuote> getQuote(String symbol) async {
    final quotes = await getQuotes([symbol]);
    if (quotes.isEmpty) {
      throw const ApiFailure(FailureKind.notFound, 'Ativo não encontrado.');
    }
    return quotes.first;
  }

  @override
  Future<List<HistoricalPoint>> getHistory(
      String symbol, ChartPeriod period) async {
    final body = await _client.getJson(
      '/v2/stocks/historical',
      query: {
        'symbols': symbol,
        'range': period.range,
        'interval': period.interval,
        'sortOrder': 'asc',
      },
    );
    final result = _firstResult(body);
    final data = asMap(result['data']);
    return asList(data['historicalDataPrice'])
        .map((item) => HistoricalPoint.fromJson(asMap(item)))
        .where((item) => item.chartValue != null)
        .toList(growable: false);
  }

  @override
  Future<List<Dividend>> getDividends(String symbol) async {
    final body = await _client.getJson(
      '/v2/stocks/dividends',
      query: {'symbols': symbol},
    );
    final data = asMap(_firstResult(body)['data']);
    final dividends = <Dividend>[];
    for (final entry in const <String, String>{
      'cashDividends': 'Dividendo/JCP',
      'stockDividends': 'Bonificação',
      'subscriptions': 'Subscrição',
    }.entries) {
      dividends.addAll(
        asList(data[entry.key]).map(
          (item) => Dividend.fromJson(asMap(item), kind: entry.value),
        ),
      );
    }
    dividends.sort((a, b) {
      final left = a.exDate ?? DateTime.fromMillisecondsSinceEpoch(0);
      final right = b.exDate ?? DateTime.fromMillisecondsSinceEpoch(0);
      return right.compareTo(left);
    });
    return dividends;
  }

  @override
  Future<CompanyProfile> getProfile(String symbol) async {
    final body = await _client.getJson(
      '/v2/stocks/profile',
      query: {'symbols': symbol},
    );
    final result = _firstResult(body);
    return CompanyProfile.fromJson(
      asString(result['symbol']) ?? symbol,
      asMap(result['data']).isEmpty ? result : asMap(result['data']),
    );
  }

  @override
  Future<StockStatistics> getStatistics(String symbol) async {
    final body = await _client.getJson(
      '/v2/stocks/statistics',
      query: {'symbols': symbol},
    );
    final result = _firstResult(body);
    return StockStatistics.fromJson(
      asMap(result['data']).isEmpty ? result : asMap(result['data']),
    );
  }

  @override
  Future<FinancialData> getFinancialData(String symbol) async {
    final body = await _client.getJson(
      '/v2/stocks/financial-data',
      query: {'symbols': symbol},
    );
    final result = _firstResult(body);
    return FinancialData.fromJson(
      asMap(result['data']).isEmpty ? result : asMap(result['data']),
    );
  }

  @override
  Future<List<CurrencyQuote>> getCurrencies(List<String> pairs) async {
    final body = await _client.getJson(
      '/v2/currency',
      query: {'currency': pairs.join(',')},
    );
    return _items(body, const ['currency', 'currencies', 'results'])
        .map((item) => CurrencyQuote.fromJson(asMap(item)))
        .toList(growable: false);
  }

  @override
  Future<List<CryptoQuote>> getCrypto(List<String> coins) async {
    final body = await _client.getJson(
      '/v2/crypto',
      query: {'coin': coins.join(','), 'currency': 'BRL'},
    );
    return _items(body, const ['coins', 'results'])
        .map((item) => CryptoQuote.fromJson(asMap(item)))
        .where((item) => item.coin.isNotEmpty)
        .toList(growable: false);
  }

  @override
  Future<List<MacroLatest>> getMacro(List<String> symbols) async {
    final body = await _client.getJson(
      '/v2/macro/latest',
      query: {'symbols': symbols.join(',')},
    );
    return _items(body, const ['results', 'series', 'data'])
        .map((item) => MacroLatest.fromJson(asMap(item)))
        .where((item) => item.slug.isNotEmpty)
        .toList(growable: false);
  }

  Map<String, dynamic> _firstResult(Map<String, dynamic> body) {
    final results = asList(body['results']);
    if (results.isEmpty) {
      throw const ApiFailure(
          FailureKind.notFound, 'Nenhum resultado retornado pela API.');
    }
    return asMap(results.first);
  }

  List<dynamic> _items(Map<String, dynamic> body, List<String> keys) {
    for (final key in keys) {
      final value = body[key];
      if (value is List) return value;
      final map = asMap(value);
      if (map.isNotEmpty) {
        for (final nested in const ['items', 'results', 'data']) {
          if (map[nested] is List) return map[nested] as List<dynamic>;
        }
      }
    }
    return const [];
  }
}
