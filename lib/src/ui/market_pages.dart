import 'package:brapi_market/src/core/app_colors.dart';
import 'package:brapi_market/src/core/formatters.dart';
import 'package:brapi_market/src/data/models.dart';
import 'package:brapi_market/src/state/providers.dart';
import 'package:brapi_market/src/ui/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CurrencyPage extends ConsumerWidget {
  const CurrencyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotes = ref.watch(currencyQuotesProvider);
    return ScreenScaffold(
      title: 'Câmbio',
      subtitle: 'Cotação de pares de moedas',
      showBack: true,
      onRefresh: () async => ref.invalidate(currencyQuotesProvider),
      children: [
        AsyncContent<List<CurrencyQuote>>(
          value: quotes,
          onRetry: () => ref.invalidate(currencyQuotesProvider),
          isEmpty: (items) => items.isEmpty,
          emptyMessage: 'Nenhum par de moedas foi retornado.',
          data: (items) => Column(
            children: [
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.pair,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14),
                                ),
                              ),
                              Text(
                                AppFormatters.currency(item.bid, symbol: ''),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800, fontSize: 15),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Text('Compra / venda',
                                  style: TextStyle(
                                      color: AppColors.muted, fontSize: 10)),
                              const Spacer(),
                              Text(
                                AppFormatters.percent(item.changePercent),
                                style: TextStyle(
                                  color: (item.changePercent ?? 0) >= 0
                                      ? AppColors.positive
                                      : AppColors.negative,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (items.isNotEmpty) ...[
                const SizedBox(height: 6),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.8,
                      children: [
                        MetricTile(
                            label: 'Compra',
                            value: AppFormatters.currency(items.first.bid,
                                symbol: '')),
                        MetricTile(
                            label: 'Venda',
                            value: AppFormatters.currency(items.first.ask,
                                symbol: '')),
                        MetricTile(
                            label: 'Máxima',
                            value: AppFormatters.currency(items.first.high,
                                symbol: '')),
                        MetricTile(
                            label: 'Mínima',
                            value: AppFormatters.currency(items.first.low,
                                symbol: '')),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class CryptoPage extends ConsumerWidget {
  const CryptoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotes = ref.watch(cryptoQuotesProvider);
    return ScreenScaffold(
      title: 'Criptomoedas',
      subtitle: 'Cotações em BRL',
      showBack: true,
      onRefresh: () async => ref.invalidate(cryptoQuotesProvider),
      children: [
        AsyncContent<List<CryptoQuote>>(
          value: quotes,
          onRetry: () => ref.invalidate(cryptoQuotesProvider),
          isEmpty: (items) => items.isEmpty,
          emptyMessage: 'Nenhuma criptomoeda foi retornada.',
          data: (items) => Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var index = 0; index < items.length; index++) ...[
                  ListTile(
                    leading: AssetLogo(
                      symbol: items[index].coin,
                      url: items[index].imageUrl,
                      size: 38,
                    ),
                    title: Text(
                      items[index].name ?? items[index].coin,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(items[index].coin,
                        style: const TextStyle(fontSize: 10)),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          AppFormatters.currency(items[index].price),
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          AppFormatters.percent(items[index].changePercent),
                          style: TextStyle(
                            color: (items[index].changePercent ?? 0) >= 0
                                ? AppColors.positive
                                : AppColors.negative,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (index != items.length - 1) const Divider(height: 1),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class MacroPage extends ConsumerWidget {
  const MacroPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final series = ref.watch(macroLatestProvider);
    return ScreenScaffold(
      title: 'Macroeconomia',
      subtitle: 'Acompanhe as principais séries.',
      showBack: true,
      onRefresh: () async => ref.invalidate(macroLatestProvider),
      children: [
        AsyncContent<List<MacroLatest>>(
          value: series,
          onRetry: () => ref.invalidate(macroLatestProvider),
          isEmpty: (items) => items.isEmpty,
          emptyMessage: 'Nenhuma série macroeconômica foi retornada.',
          data: (items) => Column(
            children: [
              for (var index = 0; index < items.length; index++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    color: index == 0 ? AppColors.primarySurface : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  items[index].name ??
                                      items[index].slug.toUpperCase(),
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  AppFormatters.date(items[index].date),
                                  style: const TextStyle(
                                      color: AppColors.muted, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${items[index].value?.toStringAsFixed(2) ?? '—'} ${items[index].unit ?? ''}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
