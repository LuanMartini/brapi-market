import 'dart:math' as math;

import 'package:brapi_market/src/core/app_colors.dart';
import 'package:brapi_market/src/core/formatters.dart';
import 'package:brapi_market/src/data/models.dart';
import 'package:brapi_market/src/state/providers.dart';
import 'package:brapi_market/src/ui/widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AssetDetailPage extends ConsumerWidget {
  const AssetDetailPage({required this.symbol, super.key});

  final String symbol;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quote = ref.watch(quoteProvider(symbol));
    final profile = ref.watch(profileProvider(symbol));
    final coverage = ref.watch(coverageProvider(symbol));
    final favorite =
        ref.watch(favoriteSymbolsProvider).contains(symbol.toUpperCase());
    return ScreenScaffold(
      title: symbol.toUpperCase(),
      subtitle: profile.asData?.value.name ??
          quote.asData?.value.name ??
          'Detalhes do ativo',
      showBack: true,
      actions: [
        IconButton(
          tooltip:
              favorite ? 'Remover dos favoritos' : 'Adicionar aos favoritos',
          onPressed: () =>
              ref.read(favoriteSymbolsProvider.notifier).toggle(symbol),
          icon: Icon(
            favorite ? Icons.star_rounded : Icons.star_border_rounded,
            color: favorite ? AppColors.warning : AppColors.muted,
          ),
        ),
      ],
      children: [
        AsyncContent<StockQuote>(
          value: quote,
          onRetry: () => ref.invalidate(quoteProvider(symbol)),
          data: (data) => Column(
            children: [
              Row(
                children: [
                  AssetLogo(symbol: data.symbol, url: data.logoUrl, size: 52),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppFormatters.currency(data.price),
                          style: const TextStyle(
                              fontSize: 27, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          '${AppFormatters.percent(data.changePercent)} hoje',
                          style: TextStyle(
                            color: (data.changePercent ?? 0) >= 0
                                ? AppColors.positive
                                : AppColors.negative,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.1,
                    children: [
                      MetricTile(
                          label: 'Abertura',
                          value: AppFormatters.currency(data.open)),
                      MetricTile(
                          label: 'Máxima',
                          value: AppFormatters.currency(data.dayHigh)),
                      MetricTile(
                          label: 'Mínima',
                          value: AppFormatters.currency(data.dayLow)),
                      MetricTile(
                        label: 'Fech. anterior',
                        value: AppFormatters.currency(data.previousClose),
                      ),
                      MetricTile(
                          label: 'Volume',
                          value: AppFormatters.compact(data.volume)),
                      MetricTile(
                        label: 'Market cap',
                        value: AppFormatters.compact(data.marketCap,
                            prefix: 'R\$ '),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _DetailTabs(symbol: symbol, coverage: coverage.asData?.value),
              const SizedBox(height: 22),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('52 semanas',
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              const SizedBox(height: 10),
              _RangeCard(
                  low: data.fiftyTwoWeekLow,
                  high: data.fiftyTwoWeekHigh,
                  current: data.price),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: coverage.asData?.value.financialData == false
                      ? null
                      : () => context.push('/asset/$symbol/financial'),
                  icon: const Icon(Icons.receipt_long_outlined),
                  label: const Text('Dados financeiros'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () =>
                      ref.read(favoriteSymbolsProvider.notifier).toggle(symbol),
                  icon: Icon(favorite ? Icons.star_rounded : Icons.add_rounded),
                  label: Text(favorite
                      ? 'Remover dos favoritos'
                      : 'Adicionar aos favoritos'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailTabs extends StatelessWidget {
  const _DetailTabs({required this.symbol, this.coverage});
  final String symbol;
  final AssetCoverage? coverage;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _TabButton(label: 'Resumo', selected: true, onTap: () {}),
            _TabButton(
              label: 'Gráfico',
              onTap: coverage?.historical == false
                  ? null
                  : () => context.push('/asset/$symbol/chart'),
            ),
            _TabButton(
              label: 'Proventos',
              onTap: coverage?.dividends == false
                  ? null
                  : () => context.push('/asset/$symbol/dividends'),
            ),
            _TabButton(
              label: 'Perfil',
              onTap: coverage?.profile == false
                  ? null
                  : () => context.push('/asset/$symbol/profile'),
            ),
            _TabButton(
              label: 'Múltiplos',
              onTap: coverage?.statistics == false
                  ? null
                  : () => context.push('/asset/$symbol/statistics'),
            ),
          ],
        ),
      );
}

class _TabButton extends StatelessWidget {
  const _TabButton(
      {required this.label, required this.onTap, this.selected = false});
  final String label;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: 6),
        child: TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: selected ? AppColors.primary : AppColors.muted,
            backgroundColor: selected ? AppColors.primarySurface : null,
          ),
          child: Text(label),
        ),
      );
}

class _RangeCard extends StatelessWidget {
  const _RangeCard(
      {required this.low, required this.high, required this.current});
  final double? low;
  final double? high;
  final double? current;

  @override
  Widget build(BuildContext context) {
    final range = (high ?? 0) - (low ?? 0);
    final value = range <= 0 || current == null || low == null
        ? 0.0
        : ((current! - low!) / range).clamp(0.0, 1.0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(AppFormatters.currency(low),
                    style: const TextStyle(fontSize: 11)),
                const Spacer(),
                Text(AppFormatters.currency(high),
                    style: const TextStyle(fontSize: 11)),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: value,
              minHeight: 6,
              borderRadius: BorderRadius.circular(4),
              color: AppColors.primary,
              backgroundColor: AppColors.border,
            ),
          ],
        ),
      ),
    );
  }
}

class ChartPage extends ConsumerStatefulWidget {
  const ChartPage({required this.symbol, super.key});
  final String symbol;

  @override
  ConsumerState<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends ConsumerState<ChartPage> {
  ChartPeriod _period = ChartPeriod.year;
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final request = (symbol: widget.symbol, period: _period);
    final history = ref.watch(historyProvider(request));
    return ScreenScaffold(
      title: 'Gráfico ${widget.symbol}',
      subtitle: 'Histórico de preços',
      showBack: true,
      children: [
        AsyncContent<List<HistoricalPoint>>(
          value: history,
          onRetry: () => ref.invalidate(historyProvider(request)),
          isEmpty: (items) => items.isEmpty,
          emptyMessage: 'Não há histórico para este período.',
          data: (items) {
            final selected = items[(_selectedIndex ?? items.length - 1)
                .clamp(0, items.length - 1)];
            final first = items.first.chartValue;
            final last = items.last.chartValue;
            final variation = first == null || first == 0 || last == null
                ? null
                : ((last - first) / first) * 100;
            final values =
                items.map((item) => item.chartValue!).toList(growable: false);
            final minValue = values.reduce(math.min);
            final maxValue = values.reduce(math.max);
            final padding = math.max((maxValue - minValue) * .12, 1);
            return Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppFormatters.currency(selected.chartValue),
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          '${AppFormatters.percent(variation)} em ${_period.label}',
                          style: TextStyle(
                            color: (variation ?? 0) >= 0
                                ? AppColors.positive
                                : AppColors.negative,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          height: 220,
                          child: LineChart(
                            LineChartData(
                              minY: minValue - padding,
                              maxY: maxValue + padding,
                              gridData: const FlGridData(show: false),
                              titlesData: const FlTitlesData(show: false),
                              borderData: FlBorderData(show: false),
                              lineTouchData: LineTouchData(
                                touchCallback: (_, response) {
                                  final spots = response?.lineBarSpots;
                                  final spot = spots == null || spots.isEmpty
                                      ? null
                                      : spots.first;
                                  if (spot != null) {
                                    setState(
                                      () => _selectedIndex = spot.spotIndex,
                                    );
                                  }
                                },
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: [
                                    for (var i = 0; i < items.length; i++)
                                      FlSpot(
                                          i.toDouble(), items[i].chartValue!),
                                  ],
                                  isCurved: true,
                                  color: AppColors.primary,
                                  barWidth: 2,
                                  dotData: const FlDotData(show: false),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: AppColors.primarySurface
                                        .withValues(alpha: .7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final period in ChartPeriod.values)
                      ChoiceChip(
                        label: Text(period.label),
                        selected: period == _period,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: period == _period
                              ? Colors.white
                              : AppColors.muted,
                          fontSize: 10,
                        ),
                        onSelected: (_) => setState(() {
                          _period = period;
                          _selectedIndex = null;
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 22),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _DataLine('Data', AppFormatters.date(selected.date)),
                        _DataLine('Abertura',
                            AppFormatters.currency(selected.open, symbol: '')),
                        _DataLine('Máxima',
                            AppFormatters.currency(selected.high, symbol: '')),
                        _DataLine('Mínima',
                            AppFormatters.currency(selected.low, symbol: '')),
                        _DataLine('Fechamento',
                            AppFormatters.currency(selected.close, symbol: '')),
                        _DataLine(
                            'Volume', AppFormatters.compact(selected.volume)),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class DividendsPage extends ConsumerWidget {
  const DividendsPage({required this.symbol, super.key});
  final String symbol;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dividends = ref.watch(dividendsProvider(symbol));
    return ScreenScaffold(
      title: 'Proventos',
      subtitle: '$symbol • Dividendos, JCP e eventos',
      showBack: true,
      children: [
        AsyncContent<List<Dividend>>(
          value: dividends,
          onRetry: () => ref.invalidate(dividendsProvider(symbol)),
          isEmpty: (items) => items.isEmpty,
          emptyMessage: 'Nenhum provento foi retornado para $symbol.',
          data: (items) => Card(
            child: Column(
              children: [
                for (var index = 0; index < items.length; index++) ...[
                  ListTile(
                    title: Text(
                      items[index].label ?? items[index].kind,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      'Ex: ${AppFormatters.date(items[index].exDate)} • Pagamento: ${AppFormatters.date(items[index].paymentDate)}',
                      style: const TextStyle(fontSize: 10),
                    ),
                    trailing: Text(
                      AppFormatters.currency(items[index].rate),
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700),
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

class ProfilePage extends ConsumerWidget {
  const ProfilePage({required this.symbol, super.key});
  final String symbol;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider(symbol));
    return ScreenScaffold(
      title: 'Sobre a empresa',
      subtitle: symbol,
      showBack: true,
      children: [
        AsyncContent<CompanyProfile>(
          value: profile,
          onRetry: () => ref.invalidate(profileProvider(symbol)),
          data: (data) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AssetLogo(symbol: symbol, url: data.logoUrl, size: 48),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          data.name ?? symbol,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _ProfileBlock('CNPJ', data.cnpj),
                  _ProfileBlock('Descrição', data.summary),
                  _ProfileBlock(
                      'Setor / indústria',
                      [data.sector, data.industry]
                          .whereType<String>()
                          .join(' • ')),
                  _ProfileBlock('Website', data.website),
                  _ProfileBlock('Localização',
                      [data.city, data.state].whereType<String>().join(' / ')),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileBlock extends StatelessWidget {
  const _ProfileBlock(this.label, this.value);
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 10, color: AppColors.muted)),
            const SizedBox(height: 4),
            Text(
              value == null || value!.isEmpty ? '—' : value!,
              style: const TextStyle(
                  fontSize: 12, height: 1.45, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
}

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({required this.symbol, super.key});
  final String symbol;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statistics = ref.watch(statisticsProvider(symbol));
    return ScreenScaffold(
      title: 'Indicadores',
      subtitle: '$symbol • Múltiplos e fundamentos',
      showBack: true,
      children: [
        AsyncContent<StockStatistics>(
          value: statistics,
          onRetry: () => ref.invalidate(statisticsProvider(symbol)),
          data: (data) => GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.55,
            children: [
              MetricTile(label: 'P/L', value: _decimal(data.priceEarnings)),
              MetricTile(label: 'P/VP', value: _decimal(data.priceToBook)),
              MetricTile(
                  label: 'LPA',
                  value: AppFormatters.currency(data.earningsPerShare)),
              MetricTile(
                label: 'Dividend yield',
                value: AppFormatters.percent(data.dividendYield),
                emphasis: AppColors.positive,
              ),
              MetricTile(
                  label: 'ROE',
                  value: AppFormatters.percent(data.returnOnEquity)),
              MetricTile(
                  label: 'Margem líquida',
                  value: AppFormatters.percent(data.netMargin)),
              MetricTile(label: 'Beta', value: _decimal(data.beta)),
              MetricTile(
                label: 'Market cap',
                value: AppFormatters.compact(data.marketCap, prefix: 'R\$ '),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _decimal(double? value) =>
      value == null ? '—' : '${value.toStringAsFixed(2)}x';
}

class FinancialDataPage extends ConsumerWidget {
  const FinancialDataPage({required this.symbol, super.key});
  final String symbol;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final financial = ref.watch(financialDataProvider(symbol));
    return ScreenScaffold(
      title: 'Dados financeiros',
      subtitle: '$symbol • Propriedades confirmadas pela resposta',
      showBack: true,
      children: [
        const InfoCard(
          icon: Icons.rule_rounded,
          title: 'Sem campos inventados',
          message:
              'Esta tela exibe apenas propriedades primitivas realmente presentes na resposta da API.',
          color: AppColors.warningSurface,
          borderColor: AppColors.warningBorder,
          iconColor: AppColors.warning,
        ),
        const SizedBox(height: 16),
        AsyncContent<FinancialData>(
          value: financial,
          onRetry: () => ref.invalidate(financialDataProvider(symbol)),
          isEmpty: (data) => data.values.isEmpty,
          emptyMessage:
              'A API não retornou propriedades financeiras para este ativo.',
          data: (data) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  for (final entry in data.values.entries)
                    _DataLine(_humanize(entry.key), _display(entry.value)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _humanize(String value) => value
      .replaceAllMapped(RegExp(r'([a-z])([A-Z])'),
          (match) => '${match.group(1)} ${match.group(2)}')
      .replaceAll('_', ' ');

  String _display(Object? value) {
    if (value is num) return AppFormatters.compact(value);
    if (value is bool) return value ? 'Sim' : 'Não';
    return value?.toString() ?? '—';
  }
}

class _DataLine extends StatelessWidget {
  const _DataLine(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            Expanded(
                child: Text(label,
                    style:
                        const TextStyle(color: AppColors.muted, fontSize: 11))),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
}
