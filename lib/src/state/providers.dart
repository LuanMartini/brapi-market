import 'dart:async';

import 'package:brapi_market/src/core/app_config.dart';
import 'package:brapi_market/src/core/brapi_client.dart';
import 'package:brapi_market/src/data/brapi_repository.dart';
import 'package:brapi_market/src/data/models.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
      'SharedPreferences deve ser sobrescrito no main.'),
);

final apiKeyProvider = StateNotifierProvider<ApiKeyNotifier, String>((ref) {
  return ApiKeyNotifier(ref.watch(sharedPreferencesProvider));
});

final class ApiKeyNotifier extends StateNotifier<String> {
  ApiKeyNotifier(this._preferences)
      : super(
          (_preferences.getString(_key) ?? AppConfig.apiKey).trim(),
        );

  static const _key = 'brapi_api_key';
  final SharedPreferences _preferences;

  Future<void> save(String value) async {
    final normalized = value.trim();
    state = normalized;
    if (normalized.isEmpty) {
      await _preferences.remove(_key);
      return;
    }
    await _preferences.setString(_key, normalized);
  }

  Future<void> clear() => save('');
}

final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 10),
      responseType: ResponseType.json,
      validateStatus: (status) =>
          status != null && status >= 200 && status < 300,
    ),
  );
});

final brapiClientProvider = Provider<BrapiClient>((ref) {
  return BrapiClient(
    dio: ref.watch(dioProvider),
    apiKey: ref.watch(apiKeyProvider),
  );
});

final marketRepositoryProvider = Provider<MarketRepository>((ref) {
  return BrapiRepository(ref.watch(brapiClientProvider));
});

final favoriteSymbolsProvider =
    StateNotifierProvider<FavoritesNotifier, List<String>>((ref) {
  return FavoritesNotifier(ref.watch(sharedPreferencesProvider));
});

final class FavoritesNotifier extends StateNotifier<List<String>> {
  FavoritesNotifier(this._preferences)
      : super(
          _preferences.getStringList(_key) ??
              List<String>.of(AppConfig.defaultSymbols),
        );

  static const _key = 'favorite_symbols';
  final SharedPreferences _preferences;

  bool contains(String symbol) => state.contains(symbol.toUpperCase());

  Future<void> toggle(String symbol) async {
    final normalized = symbol.toUpperCase();
    state = contains(normalized)
        ? state.where((item) => item != normalized).toList(growable: false)
        : <String>[...state, normalized];
    await _preferences.setStringList(_key, state);
  }

  Future<void> remove(String symbol) async {
    state = state
        .where((item) => item != symbol.toUpperCase())
        .toList(growable: false);
    await _preferences.setStringList(_key, state);
  }
}

final homeQuotesProvider = FutureProvider<List<StockQuote>>((ref) {
  final symbols = ref.watch(favoriteSymbolsProvider);
  return ref.watch(marketRepositoryProvider).getQuotes(symbols);
});

final quoteProvider =
    FutureProvider.autoDispose.family<StockQuote, String>((ref, symbol) {
  return ref.watch(marketRepositoryProvider).getQuote(symbol);
});

final coverageProvider =
    FutureProvider.autoDispose.family<AssetCoverage, String>((ref, symbol) {
  return ref.watch(marketRepositoryProvider).getCoverage(symbol);
});

final profileProvider =
    FutureProvider.autoDispose.family<CompanyProfile, String>((ref, symbol) {
  return ref.watch(marketRepositoryProvider).getProfile(symbol);
});

final dividendsProvider =
    FutureProvider.autoDispose.family<List<Dividend>, String>((ref, symbol) {
  return ref.watch(marketRepositoryProvider).getDividends(symbol);
});

final statisticsProvider =
    FutureProvider.autoDispose.family<StockStatistics, String>((ref, symbol) {
  return ref.watch(marketRepositoryProvider).getStatistics(symbol);
});

final financialDataProvider =
    FutureProvider.autoDispose.family<FinancialData, String>((ref, symbol) {
  return ref.watch(marketRepositoryProvider).getFinancialData(symbol);
});

final historyProvider = FutureProvider.autoDispose
    .family<List<HistoricalPoint>, ({String symbol, ChartPeriod period})>(
        (ref, request) {
  return ref
      .watch(marketRepositoryProvider)
      .getHistory(request.symbol, request.period);
});

final currencyQuotesProvider =
    FutureProvider.autoDispose<List<CurrencyQuote>>((ref) {
  return ref
      .watch(marketRepositoryProvider)
      .getCurrencies(const ['USD-BRL', 'EUR-BRL', 'GBP-BRL']);
});

final cryptoQuotesProvider =
    FutureProvider.autoDispose<List<CryptoQuote>>((ref) {
  return ref
      .watch(marketRepositoryProvider)
      .getCrypto(const ['BTC', 'ETH', 'SOL']);
});

final macroLatestProvider =
    FutureProvider.autoDispose<List<MacroLatest>>((ref) {
  return ref
      .watch(marketRepositoryProvider)
      .getMacro(const ['selic', 'cdi', 'ipca', 'igpm']);
});

enum AssetFilter { all, stocks, funds, etfs }

extension AssetFilterLabel on AssetFilter {
  String get label => switch (this) {
        AssetFilter.all => 'Todos',
        AssetFilter.stocks => 'Ações',
        AssetFilter.funds => 'FIIs',
        AssetFilter.etfs => 'ETFs',
      };

  String? get apiType => switch (this) {
        AssetFilter.all => null,
        AssetFilter.stocks => 'stock',
        AssetFilter.funds => 'fund',
        AssetFilter.etfs => 'etf',
      };
}

final class SearchRequest {
  const SearchRequest(this.query, this.filter, {this.page = 1});

  final String query;
  final AssetFilter filter;
  final int page;

  @override
  bool operator ==(Object other) =>
      other is SearchRequest &&
      other.query == query &&
      other.filter == filter &&
      other.page == page;

  @override
  int get hashCode => Object.hash(query, filter, page);
}

final searchResultsProvider =
    FutureProvider.autoDispose.family<List<TickerItem>, SearchRequest>(
  (ref, request) async {
    final token = CancelToken();
    final repository = ref.watch(marketRepositoryProvider);
    ref.onDispose(() => token.cancel('Nova busca iniciada.'));
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return repository.searchTickers(
      request.query,
      type: request.filter.apiType,
      page: request.page,
      cancelToken: token,
    );
  },
);
