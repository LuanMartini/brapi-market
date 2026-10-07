import 'package:brapi_market/src/core/formatters.dart';

Map<String, dynamic> asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const <String, dynamic>{};
}

List<dynamic> asList(Object? value) =>
    value is List ? value : const <dynamic>[];

String? asString(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

final class TickerItem {
  const TickerItem({
    required this.symbol,
    this.name,
    this.assetType,
    this.subType,
    this.sector,
    this.logoUrl,
    this.quote,
  });

  factory TickerItem.fromJson(Map<String, dynamic> json) {
    final quoteMap = asMap(json['quote']);
    return TickerItem(
      symbol: asString(json['symbol']) ?? '',
      name: asString(json['name'] ?? json['shortName']),
      assetType: asString(json['assetType'] ?? json['type']),
      subType: asString(json['subType']),
      sector: asString(json['sector']),
      logoUrl: asString(json['logoUrl'] ?? json['logourl']),
      quote: quoteMap.isEmpty
          ? null
          : StockQuote.fromData(
              asString(json['symbol']) ?? '',
              quoteMap,
            ),
    );
  }

  final String symbol;
  final String? name;
  final String? assetType;
  final String? subType;
  final String? sector;
  final String? logoUrl;
  final StockQuote? quote;
}

final class StockQuote {
  const StockQuote({
    required this.symbol,
    this.requestedSymbol,
    this.changed = false,
    this.name,
    this.longName,
    this.currency,
    this.price,
    this.change,
    this.changePercent,
    this.open,
    this.previousClose,
    this.dayHigh,
    this.dayLow,
    this.volume,
    this.marketCap,
    this.fiftyTwoWeekLow,
    this.fiftyTwoWeekHigh,
    this.logoUrl,
  });

  factory StockQuote.fromEnvelope(Map<String, dynamic> json) {
    final symbol =
        asString(json['symbol']) ?? asString(json['requestedSymbol']) ?? '';
    return StockQuote.fromData(
      symbol,
      asMap(json['data']),
      requestedSymbol: asString(json['requestedSymbol']),
      changed: json['changed'] == true,
    );
  }

  factory StockQuote.fromData(
    String symbol,
    Map<String, dynamic> json, {
    String? requestedSymbol,
    bool changed = false,
  }) {
    return StockQuote(
      symbol: symbol,
      requestedSymbol: requestedSymbol,
      changed: changed,
      name: asString(json['shortName'] ?? json['name']),
      longName: asString(json['longName']),
      currency: asString(json['currency']),
      price: asDouble(json['regularMarketPrice'] ?? json['price']),
      change: asDouble(json['regularMarketChange']),
      changePercent:
          asDouble(json['regularMarketChangePercent'] ?? json['changePercent']),
      open: asDouble(json['regularMarketOpen'] ?? json['open']),
      previousClose:
          asDouble(json['regularMarketPreviousClose'] ?? json['previousClose']),
      dayHigh: asDouble(json['regularMarketDayHigh'] ?? json['high']),
      dayLow: asDouble(json['regularMarketDayLow'] ?? json['low']),
      volume: asInt(json['regularMarketVolume'] ?? json['volume']),
      marketCap: asDouble(json['marketCap']),
      fiftyTwoWeekLow: asDouble(json['fiftyTwoWeekLow']),
      fiftyTwoWeekHigh: asDouble(json['fiftyTwoWeekHigh']),
      logoUrl: asString(json['logourl'] ?? json['logoUrl']),
    );
  }

  final String symbol;
  final String? requestedSymbol;
  final bool changed;
  final String? name;
  final String? longName;
  final String? currency;
  final double? price;
  final double? change;
  final double? changePercent;
  final double? open;
  final double? previousClose;
  final double? dayHigh;
  final double? dayLow;
  final int? volume;
  final double? marketCap;
  final double? fiftyTwoWeekLow;
  final double? fiftyTwoWeekHigh;
  final String? logoUrl;
}

final class HistoricalPoint {
  const HistoricalPoint({
    required this.date,
    this.open,
    this.high,
    this.low,
    this.close,
    this.adjustedClose,
    this.volume,
  });

  factory HistoricalPoint.fromJson(Map<String, dynamic> json) =>
      HistoricalPoint(
        date: parseFlexibleDate(json['date']) ??
            DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        open: asDouble(json['open']),
        high: asDouble(json['high']),
        low: asDouble(json['low']),
        close: asDouble(json['close']),
        adjustedClose: asDouble(json['adjustedClose']),
        volume: asInt(json['volume']),
      );

  final DateTime date;
  final double? open;
  final double? high;
  final double? low;
  final double? close;
  final double? adjustedClose;
  final int? volume;

  double? get chartValue => adjustedClose ?? close;
}

final class Dividend {
  const Dividend({
    required this.kind,
    this.label,
    this.rate,
    this.exDate,
    this.paymentDate,
  });

  factory Dividend.fromJson(Map<String, dynamic> json,
          {required String kind}) =>
      Dividend(
        kind: kind,
        label: asString(json['label'] ?? json['type'] ?? json['event']),
        rate: asDouble(json['rate'] ?? json['value']),
        exDate: parseFlexibleDate(json['exDate'] ?? json['lastDatePrior']),
        paymentDate: parseFlexibleDate(
            json['paymentDate'] ?? json['paymentDateFormatted']),
      );

  final String kind;
  final String? label;
  final double? rate;
  final DateTime? exDate;
  final DateTime? paymentDate;
}

final class CompanyProfile {
  const CompanyProfile({
    required this.symbol,
    this.name,
    this.cnpj,
    this.sector,
    this.industry,
    this.summary,
    this.website,
    this.city,
    this.state,
    this.logoUrl,
  });

  factory CompanyProfile.fromJson(String symbol, Map<String, dynamic> json) =>
      CompanyProfile(
        symbol: symbol,
        name: asString(json['name'] ?? json['longName'] ?? json['shortName']),
        cnpj: asString(json['cnpj']),
        sector: asString(json['sector']),
        industry: asString(json['industry']),
        summary: asString(json['summary'] ?? json['longBusinessSummary']),
        website: asString(json['website']),
        city: asString(json['city']),
        state: asString(json['state']),
        logoUrl: asString(json['logoUrl'] ?? json['logourl']),
      );

  final String symbol;
  final String? name;
  final String? cnpj;
  final String? sector;
  final String? industry;
  final String? summary;
  final String? website;
  final String? city;
  final String? state;
  final String? logoUrl;
}

final class StockStatistics {
  const StockStatistics({
    this.priceEarnings,
    this.priceToBook,
    this.earningsPerShare,
    this.dividendYield,
    this.returnOnEquity,
    this.netMargin,
    this.beta,
    this.marketCap,
    this.raw = const {},
  });

  factory StockStatistics.fromJson(Map<String, dynamic> json) =>
      StockStatistics(
        priceEarnings:
            asDouble(json['priceEarnings'] ?? json['trailingPE'] ?? json['pE']),
        priceToBook: asDouble(
            json['priceToBook'] ?? json['priceToBookRatio'] ?? json['pVp']),
        earningsPerShare: asDouble(
            json['earningsPerShare'] ?? json['epsTrailingTwelveMonths']),
        dividendYield: asDouble(json['dividendYield']),
        returnOnEquity: asDouble(json['returnOnEquity']),
        netMargin: asDouble(json['netMargin'] ?? json['profitMargins']),
        beta: asDouble(json['beta']),
        marketCap: asDouble(json['marketCap']),
        raw: Map<String, dynamic>.unmodifiable(json),
      );

  final double? priceEarnings;
  final double? priceToBook;
  final double? earningsPerShare;
  final double? dividendYield;
  final double? returnOnEquity;
  final double? netMargin;
  final double? beta;
  final double? marketCap;
  final Map<String, dynamic> raw;
}

final class FinancialData {
  const FinancialData(this.values);

  factory FinancialData.fromJson(Map<String, dynamic> json) {
    final values = <String, Object?>{};
    for (final entry in json.entries) {
      if (entry.value == null ||
          entry.value is num ||
          entry.value is String ||
          entry.value is bool) {
        values[entry.key] = entry.value;
      }
    }
    return FinancialData(Map<String, Object?>.unmodifiable(values));
  }

  final Map<String, Object?> values;
}

final class CurrencyQuote {
  const CurrencyQuote({
    required this.pair,
    this.fromCurrency,
    this.toCurrency,
    this.bid,
    this.ask,
    this.high,
    this.low,
    this.changePercent,
  });

  factory CurrencyQuote.fromJson(Map<String, dynamic> json) => CurrencyQuote(
        pair: asString(json['currency'] ?? json['name']) ??
            '${asString(json['fromCurrency']) ?? ''}-${asString(json['toCurrency']) ?? ''}',
        fromCurrency: asString(json['fromCurrency']),
        toCurrency: asString(json['toCurrency']),
        bid: asDouble(json['bidPrice'] ?? json['bid']),
        ask: asDouble(json['askPrice'] ?? json['ask']),
        high: asDouble(json['high']),
        low: asDouble(json['low']),
        changePercent: asDouble(
            json['percentageChange'] ?? json['regularMarketChangePercent']),
      );

  final String pair;
  final String? fromCurrency;
  final String? toCurrency;
  final double? bid;
  final double? ask;
  final double? high;
  final double? low;
  final double? changePercent;
}

final class CryptoQuote {
  const CryptoQuote({
    required this.coin,
    this.name,
    this.currency,
    this.imageUrl,
    this.price,
    this.changePercent,
    this.high,
    this.low,
    this.volume,
    this.marketCap,
  });

  factory CryptoQuote.fromJson(Map<String, dynamic> json) => CryptoQuote(
        coin: asString(json['coin']) ?? '',
        name: asString(json['coinName']),
        currency: asString(json['currency']),
        imageUrl: asString(json['coinImageUrl']),
        price: asDouble(json['regularMarketPrice']),
        changePercent: asDouble(json['regularMarketChangePercent']),
        high: asDouble(json['regularMarketDayHigh']),
        low: asDouble(json['regularMarketDayLow']),
        volume: asDouble(json['regularMarketVolume']),
        marketCap: asDouble(json['marketCap']),
      );

  final String coin;
  final String? name;
  final String? currency;
  final String? imageUrl;
  final double? price;
  final double? changePercent;
  final double? high;
  final double? low;
  final double? volume;
  final double? marketCap;
}

final class MacroLatest {
  const MacroLatest({
    required this.slug,
    this.name,
    this.unit,
    this.date,
    this.value,
  });

  factory MacroLatest.fromJson(Map<String, dynamic> json) {
    final series = asMap(json['series']);
    final latest = asMap(json['latest']);
    return MacroLatest(
      slug: asString(series['slug'] ?? json['slug'] ?? json['symbol']) ?? '',
      name: asString(series['name'] ?? json['name']),
      unit: asString(series['unit'] ?? json['unit']),
      date: parseFlexibleDate(latest['date'] ?? json['date']),
      value: asDouble(latest['value'] ?? json['value']),
    );
  }

  final String slug;
  final String? name;
  final String? unit;
  final DateTime? date;
  final double? value;
}

final class AssetCoverage {
  const AssetCoverage({
    required this.symbol,
    this.quote = true,
    this.historical = true,
    this.dividends = true,
    this.profile = true,
    this.statistics = true,
    this.financialData = true,
  });

  factory AssetCoverage.fromJson(Map<String, dynamic> json) {
    final data = asMap(json['availableData']);
    bool available(String key, {bool fallback = false}) =>
        data[key] is bool ? data[key] as bool : fallback;
    return AssetCoverage(
      symbol: asString(json['symbol'] ?? json['requestedSymbol']) ?? '',
      quote: available('quote', fallback: true),
      historical: available('historical'),
      dividends: available('stockDividends') || available('fiiDividends'),
      profile: available('profile'),
      statistics: available('statistics') || available('fiiIndicators'),
      financialData: available('financialStatements'),
    );
  }

  final String symbol;
  final bool quote;
  final bool historical;
  final bool dividends;
  final bool profile;
  final bool statistics;
  final bool financialData;
}

enum ChartPeriod {
  day('1D', '1d', '5m'),
  fiveDays('5D', '5d', '60m'),
  month('1M', '1mo', '1d'),
  sixMonths('6M', '6mo', '1d'),
  year('1A', '1y', '1d');

  const ChartPeriod(this.label, this.range, this.interval);
  final String label;
  final String range;
  final String interval;
}
