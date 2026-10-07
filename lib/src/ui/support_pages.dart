import 'package:brapi_market/src/core/api_failure.dart';
import 'package:brapi_market/src/core/app_colors.dart';
import 'package:brapi_market/src/ui/widgets.dart';
import 'package:flutter/material.dart';

enum ProFeature { fiis, treasury, options, futures }

extension ProFeatureInfo on ProFeature {
  String get title => switch (this) {
        ProFeature.fiis => 'FIIs',
        ProFeature.treasury => 'Tesouro Direto',
        ProFeature.options => 'Opções',
        ProFeature.futures => 'Futuros',
      };

  String get subtitle => switch (this) {
        ProFeature.fiis => 'Fundos imobiliários',
        ProFeature.treasury => 'Taxas e preços de títulos públicos',
        ProFeature.options => 'Cadeias de calls e puts',
        ProFeature.futures => 'Contratos e estrutura a termo',
      };

  IconData get icon => switch (this) {
        ProFeature.fiis => Icons.apartment_rounded,
        ProFeature.treasury => Icons.savings_outlined,
        ProFeature.options => Icons.account_tree_outlined,
        ProFeature.futures => Icons.stacked_line_chart_rounded,
      };
}

class ProFeaturePage extends StatelessWidget {
  const ProFeaturePage({required this.feature, super.key});
  final ProFeature feature;

  @override
  Widget build(BuildContext context) => ScreenScaffold(
        title: feature.title,
        subtitle: feature.subtitle,
        showBack: true,
        actions: const [
          Padding(padding: EdgeInsets.only(top: 8), child: ProBadge())
        ],
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.proSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.proBorder),
            ),
            child: Column(
              children: [
                Icon(feature.icon, color: AppColors.pro, size: 42),
                const SizedBox(height: 14),
                Text(
                  'Recurso disponível no plano PRO',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: AppColors.pro),
                ),
                const SizedBox(height: 8),
                const Text(
                  'A interface está preparada, mas nenhuma chamada é feita sem um contrato de API validado para o plano configurado.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppColors.muted, fontSize: 12, height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const InfoCard(
            icon: Icons.verified_outlined,
            title: 'Sem dados fictícios',
            message:
                'Valores de demonstração do wireframe não são apresentados como se fossem cotações reais.',
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Estado da integração',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  const _StatusLine(
                      label: 'Tela e navegação', value: 'Prontas', ready: true),
                  const _StatusLine(
                      label: 'Tratamento de plano',
                      value: 'Pronto',
                      ready: true),
                  const _StatusLine(
                      label: 'Contrato autenticado',
                      value: 'Pendente',
                      ready: false),
                ],
              ),
            ),
          ),
        ],
      );
}

class _StatusLine extends StatelessWidget {
  const _StatusLine(
      {required this.label, required this.value, required this.ready});
  final String label;
  final String value;
  final bool ready;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              ready
                  ? Icons.check_circle_outline_rounded
                  : Icons.schedule_rounded,
              color: ready ? AppColors.positive : AppColors.warning,
              size: 18,
            ),
            const SizedBox(width: 9),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
            Text(value,
                style:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
          ],
        ),
      );
}

class ApiStatesPage extends StatelessWidget {
  const ApiStatesPage({super.key});

  @override
  Widget build(BuildContext context) => ScreenScaffold(
        title: 'Estados da API',
        subtitle: 'Variações reutilizáveis',
        showBack: true,
        children: [
          Text('Loading', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const LoadingCard(),
          const SizedBox(height: 18),
          Text('404 / vazio', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const EmptyCard(
              message: 'Nenhum dado encontrado para esta consulta.'),
          const SizedBox(height: 18),
          Text('403 / PRO', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ErrorCard(
            error: const ApiFailure(
              FailureKind.forbidden,
              'Recurso disponível no plano PRO.',
              statusCode: 403,
            ),
            onRetry: () {},
          ),
          const SizedBox(height: 18),
          Text('429 / limite', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ErrorCard(
            error: const ApiFailure(
              FailureKind.rateLimited,
              'Limite de consultas atingido. Aguarde o Retry-After.',
              statusCode: 429,
            ),
            onRetry: () {},
          ),
          const SizedBox(height: 18),
          Text('500 / 503', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ErrorCard(
            error: const ApiFailure(
              FailureKind.server,
              'Não foi possível carregar os dados.',
              statusCode: 503,
            ),
            onRetry: () {},
          ),
        ],
      );
}
