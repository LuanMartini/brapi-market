import 'package:brapi_market/src/data/brapi_repository.dart';
import 'package:brapi_market/src/data/models.dart';
import 'package:dio/dio.dart';

final class FakeMarketRepository implements MarketRepository {
  String? lastSearch;
  String? lastType;

  static const quote = StockQuote(
    symbol: 'PETR4',
    name: 'Petrobras PN',
    price: 31.42,
    changePercent: 1.34,
    open: 31.10,
    previousClose: 31,
    dayHigh: 31.90,
    dayLow: 30.84,
    volume: 28400000,
    marketCap: 410000000000,
    fiftyTwoWeekLow: 22.45,
    fiftyTwoWeekHigh: 41.80,
  );

  @override
  Future<List<TickerItem>> searchTickers(
    String query, {
    String? type,
    int page = 1,
    CancelToken? cancelToken,
  }) async {
    lastSearch = query;
    lastType = type;
    return const [
      TickerItem(symbol: 'PETR4', name: 'Petrobras PN', quote: quote)
    ];
  }

  @override
  Future<AssetCoverage> getCoverage(String symbol) async =>
      AssetCoverage(symbol: symbol);

  @override
  Future<List<StockQuote>> getQuotes(List<String> symbols) async {
    return symbols
        .map((symbol) => StockQuote(symbol: symbol, name: symbol, price: 31.42))
        .toList();
  }

  @override
  Future<StockQuote> getQuote(String symbol) async => quote;

  @override
  Future<List<HistoricalPoint>> getHistory(
          String symbol, ChartPeriod period) async =>
      [
        HistoricalPoint(
            date: DateTime.utc(2026, 1),
            open: 30,
            high: 32,
            low: 29,
            close: 31,
            volume: 10),
        HistoricalPoint(
            date: DateTime.utc(2026, 2),
            open: 31,
            high: 33,
            low: 30,
            close: 32,
            volume: 20),
      ];

  @override
  Future<List<Dividend>> getDividends(String symbol) async => const [];

  @override
  Future<CompanyProfile> getProfile(String symbol) async =>
      CompanyProfile(symbol: symbol, name: 'Petrobras PN', sector: 'Energia');

  @override
  Future<StockStatistics> getStatistics(String symbol) async =>
      const StockStatistics();

  @override
  Future<FinancialData> getFinancialData(String symbol) async =>
      const FinancialData({});

  @override
  Future<List<CurrencyQuote>> getCurrencies(List<String> pairs) async =>
      const [];

  @override
  Future<List<CryptoQuote>> getCrypto(List<String> coins) async => const [];

  @override
  Future<List<MacroLatest>> getMacro(List<String> symbols) async => const [];
}
