import 'package:brapi_market/src/core/api_failure.dart';
import 'package:brapi_market/src/core/app_colors.dart';
import 'package:brapi_market/src/core/formatters.dart';
import 'package:brapi_market/src/data/models.dart';
import 'package:brapi_market/src/state/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ScreenScaffold extends ConsumerWidget {
  const ScreenScaffold({
    required this.title,
    required this.subtitle,
    required this.children,
    this.actions = const [],
    this.onRefresh,
    this.showBack = false,
    super.key,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final List<Widget> actions;
  final Future<void> Function()? onRefresh;
  final bool showBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasApiKey = ref.watch(apiKeyProvider).isNotEmpty;
    final content = ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showBack)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: IconButton(
                  tooltip: 'Voltar',
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 2),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            ...actions,
          ],
        ),
        const SizedBox(height: 20),
        if (!hasApiKey) ...[
          const ApiKeyBanner(),
          const SizedBox(height: 16),
        ],
        ...children,
      ],
    );
    return Scaffold(
      body: SafeArea(
        child: onRefresh == null
            ? content
            : RefreshIndicator(onRefresh: onRefresh!, child: content),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {this.actionLabel, this.onAction, super.key});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Expanded(
                child: Text(title,
                    style: Theme.of(context).textTheme.titleMedium)),
            if (actionLabel != null)
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ),
      );
}

class ApiKeyBanner extends StatelessWidget {
  const ApiKeyBanner({super.key});

  @override
  Widget build(BuildContext context) => InfoCard(
        icon: Icons.key_off_outlined,
        title: 'Chave não configurada',
        message:
            'Os ativos públicos ainda podem funcionar. Configure sua chave da brapi.dev para liberar as demais consultas.',
        color: AppColors.warningSurface,
        borderColor: AppColors.warningBorder,
        iconColor: AppColors.warning,
        actionLabel: 'Configurar agora',
        onAction: () => context.go('/account'),
      );
}

class InfoCard extends StatelessWidget {
  const InfoCard({
    required this.icon,
    required this.title,
    required this.message,
    this.color = AppColors.primarySurface,
    this.borderColor = AppColors.primaryBorder,
    this.iconColor = AppColors.primary,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color color;
  final Color borderColor;
  final Color iconColor;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 3),
                  Text(message,
                      style: const TextStyle(
                          color: AppColors.muted, fontSize: 11, height: 1.35)),
                  if (actionLabel != null) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: onAction,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(actionLabel!),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
}

class StockRow extends StatelessWidget {
  const StockRow({
    required this.quote,
    required this.onTap,
    this.trailing,
    super.key,
  });

  final StockQuote quote;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final positive = (quote.changePercent ?? 0) >= 0;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            AssetLogo(symbol: quote.symbol, url: quote.logoUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(quote.symbol,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(
                    quote.name ?? 'Nome indisponível',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(color: AppColors.muted, fontSize: 11),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppFormatters.currency(quote.price),
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  AppFormatters.percent(quote.changePercent),
                  style: TextStyle(
                    color: positive ? AppColors.positive : AppColors.negative,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            if (trailing != null) ...[const SizedBox(width: 4), trailing!],
          ],
        ),
      ),
    );
  }
}

class AssetLogo extends StatelessWidget {
  const AssetLogo({required this.symbol, this.url, this.size = 38, super.key});

  final String symbol;
  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fallback = Center(
      child: Text(
        symbol.length > 4 ? symbol.substring(0, 4) : symbol,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: size * .25,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * .26),
      child: Container(
        width: size,
        height: size,
        color: AppColors.primarySurface,
        child: url == null
            ? fallback
            : Image.network(
                url!,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => fallback,
              ),
      ),
    );
  }
}

class AsyncContent<T> extends StatelessWidget {
  const AsyncContent({
    required this.value,
    required this.data,
    required this.onRetry,
    this.emptyMessage = 'Nenhum dado disponível.',
    this.isEmpty,
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback onRetry;
  final String emptyMessage;
  final bool Function(T data)? isEmpty;

  @override
  Widget build(BuildContext context) => value.when(
        loading: () => const LoadingCard(),
        error: (error, _) => ErrorCard(error: error, onRetry: onRetry),
        data: (result) {
          if (isEmpty?.call(result) ?? false) {
            return EmptyCard(message: emptyMessage);
          }
          return data(result);
        },
      );
}

class LoadingCard extends StatelessWidget {
  const LoadingCard({super.key});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: List.generate(
              3,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: index == 2 ? 0 : 12),
                child: const LinearProgressIndicator(
                  minHeight: 10,
                  color: AppColors.primaryBorder,
                  backgroundColor: AppColors.surfaceTint,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
            ),
          ),
        ),
      );
}

class EmptyCard extends StatelessWidget {
  const EmptyCard({required this.message, super.key});
  final String message;

  @override
  Widget build(BuildContext context) => InfoCard(
        icon: Icons.inbox_outlined,
        title: 'Nada por aqui',
        message: message,
      );
}

class ErrorCard extends StatelessWidget {
  const ErrorCard({required this.error, required this.onRetry, super.key});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final failure = error is ApiFailure ? error as ApiFailure : null;
    final needsApiKey = failure?.kind == FailureKind.unauthorized ||
        failure?.kind == FailureKind.missingToken;
    final color = failure?.kind == FailureKind.forbidden
        ? AppColors.pro
        : AppColors.negative;
    final background = failure?.kind == FailureKind.forbidden
        ? AppColors.proSurface
        : const Color(0xFFFFECEE);
    final icon = switch (failure?.kind) {
      FailureKind.offline => Icons.wifi_off_rounded,
      FailureKind.rateLimited => Icons.timer_outlined,
      FailureKind.forbidden => Icons.workspace_premium_outlined,
      _ => Icons.error_outline_rounded,
    };
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: .35)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            failure?.message ?? 'Não foi possível carregar os dados.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: needsApiKey ? () => context.go('/account') : onRetry,
            icon: Icon(
              needsApiKey ? Icons.vpn_key_outlined : Icons.refresh_rounded,
              size: 18,
            ),
            label: Text(needsApiKey ? 'Configurar chave' : 'Tentar novamente'),
          ),
        ],
      ),
    );
  }
}

class MetricTile extends StatelessWidget {
  const MetricTile(
      {required this.label, required this.value, this.emphasis, super.key});

  final String label;
  final String value;
  final Color? emphasis;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: emphasis == null
              ? Colors.white
              : emphasis!.withValues(alpha: .09),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(color: AppColors.muted, fontSize: 10)),
            const SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: emphasis ?? AppColors.ink),
            ),
          ],
        ),
      );
}

class ProBadge extends StatelessWidget {
  const ProBadge({super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.pro,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'PRO',
          style: TextStyle(
              color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
        ),
      );
}
