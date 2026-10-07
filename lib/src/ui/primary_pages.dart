import 'package:brapi_market/src/core/app_colors.dart';
import 'package:brapi_market/src/data/models.dart';
import 'package:brapi_market/src/state/providers.dart';
import 'package:brapi_market/src/ui/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotes = ref.watch(homeQuotesProvider);
    return ScreenScaffold(
      title: 'Mercado',
      subtitle: 'Acompanhe seus ativos e o mercado.',
      onRefresh: () async => ref.invalidate(homeQuotesProvider),
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.go('/search'),
          child: const IgnorePointer(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar ticker, empresa ou fundo',
                prefixIcon: Icon(Icons.search_rounded, size: 19),
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),
        SectionHeader(
          'Seus favoritos',
          actionLabel: 'Ver todos',
          onAction: () => context.go('/favorites'),
        ),
        AsyncContent<List<StockQuote>>(
          value: quotes,
          onRetry: () => ref.invalidate(homeQuotesProvider),
          isEmpty: (items) => items.isEmpty,
          emptyMessage:
              'Adicione ativos pela busca para acompanhar suas cotações.',
          data: (items) => Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var index = 0; index < items.length; index++) ...[
                  StockRow(
                    quote: items[index],
                    onTap: () => context.push('/asset/${items[index].symbol}'),
                  ),
                  if (index != items.length - 1) const Divider(height: 1),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        const SectionHeader('Mercados'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Row(
              children: [
                Expanded(
                  child: _MarketShortcut(
                    icon: Icons.trending_up_rounded,
                    label: 'Ações',
                    selected: true,
                    onTap: () => context.go('/search'),
                  ),
                ),
                Expanded(
                  child: _MarketShortcut(
                    icon: Icons.attach_money_rounded,
                    label: 'Câmbio',
                    onTap: () => context.push('/currency'),
                  ),
                ),
                Expanded(
                  child: _MarketShortcut(
                    icon: Icons.currency_bitcoin_rounded,
                    label: 'Cripto',
                    onTap: () => context.push('/crypto'),
                  ),
                ),
                Expanded(
                  child: _MarketShortcut(
                    icon: Icons.percent_rounded,
                    label: 'Macro',
                    onTap: () => context.push('/macro'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MarketShortcut extends StatelessWidget {
  const _MarketShortcut({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 104,
          decoration: BoxDecoration(
            color: selected ? AppColors.primarySurface : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: selected ? AppColors.primary : AppColors.muted,
                  size: 25),
              const SizedBox(height: 10),
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      );
}

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _controller = TextEditingController();
  String _query = '';
  AssetFilter _filter = AssetFilter.all;
  int _page = 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = SearchRequest(_query, _filter, page: _page);
    final results = ref.watch(searchResultsProvider(request));
    return ScreenScaffold(
      title: 'Buscar ativos',
      subtitle: 'Encontre ações, FIIs, ETFs e BDRs.',
      children: [
        TextField(
          controller: _controller,
          autofocus: false,
          textInputAction: TextInputAction.search,
          onChanged: (value) => setState(() {
            _query = value.trim();
            _page = 1;
          }),
          decoration: InputDecoration(
            hintText: 'Digite um ticker ou empresa',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Limpar busca',
                    onPressed: () {
                      _controller.clear();
                      setState(() {
                        _query = '';
                        _page = 1;
                      });
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final filter in AssetFilter.values)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter.label),
                    selected: _filter == filter,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                        color:
                            _filter == filter ? Colors.white : AppColors.ink),
                    onSelected: (_) => setState(() {
                      _filter = filter;
                      _page = 1;
                    }),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const SectionHeader('Resultados'),
        AsyncContent<List<TickerItem>>(
          value: results,
          onRetry: () => ref.invalidate(searchResultsProvider(request)),
          isEmpty: (items) => items.isEmpty,
          emptyMessage: _query.isEmpty
              ? 'Digite um nome ou ticker para pesquisar.'
              : 'Nenhum ativo encontrado para “$_query”.',
          data: (items) => Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var index = 0; index < items.length; index++) ...[
                  StockRow(
                    quote: items[index].quote ??
                        StockQuote(
                          symbol: items[index].symbol,
                          name: items[index].name,
                          logoUrl: items[index].logoUrl,
                        ),
                    onTap: () => context.push('/asset/${items[index].symbol}'),
                  ),
                  if (index != items.length - 1) const Divider(height: 1),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: 'Página anterior',
              onPressed: _page == 1 ? null : () => setState(() => _page--),
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Text('Página $_page',
                style:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            IconButton(
              tooltip: 'Próxima página',
              onPressed: () => setState(() => _page++),
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const InfoCard(
          icon: Icons.fact_check_outlined,
          title: 'Cobertura por ativo',
          message:
              'As abas do detalhe são carregadas de forma independente. Recursos sem cobertura exibem um estado vazio.',
        ),
      ],
    );
  }
}

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotes = ref.watch(homeQuotesProvider);
    return ScreenScaffold(
      title: 'Favoritos',
      subtitle: 'Sua lista acompanhada.',
      onRefresh: () async => ref.invalidate(homeQuotesProvider),
      children: [
        AsyncContent<List<StockQuote>>(
          value: quotes,
          onRetry: () => ref.invalidate(homeQuotesProvider),
          isEmpty: (items) => items.isEmpty,
          emptyMessage: 'Você ainda não adicionou ativos aos favoritos.',
          data: (items) => Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var index = 0; index < items.length; index++) ...[
                  StockRow(
                    quote: items[index],
                    onTap: () => context.push('/asset/${items[index].symbol}'),
                    trailing: IconButton(
                      tooltip: 'Remover ${items[index].symbol}',
                      onPressed: () => ref
                          .read(favoriteSymbolsProvider.notifier)
                          .remove(items[index].symbol),
                      icon: const Icon(Icons.close_rounded, size: 18),
                    ),
                  ),
                  if (index != items.length - 1) const Divider(height: 1),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const InfoCard(
          icon: Icons.info_outline_rounded,
          title: 'Atualização eficiente',
          message:
              'Os ativos desta tela são atualizados juntos em uma única chamada de cotação.',
          color: AppColors.warningSurface,
          borderColor: AppColors.warningBorder,
          iconColor: AppColors.warning,
        ),
      ],
    );
  }
}

class MarketsPage extends StatelessWidget {
  const MarketsPage({super.key});

  @override
  Widget build(BuildContext context) => ScreenScaffold(
        title: 'Mercados',
        subtitle: 'Explore outras classes e indicadores.',
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: [
              _MarketCard(
                icon: Icons.attach_money_rounded,
                title: 'Câmbio',
                subtitle: 'USD, EUR e GBP',
                onTap: () => context.push('/currency'),
              ),
              _MarketCard(
                icon: Icons.currency_bitcoin_rounded,
                title: 'Cripto',
                subtitle: 'Bitcoin e outros',
                onTap: () => context.push('/crypto'),
              ),
              _MarketCard(
                icon: Icons.percent_rounded,
                title: 'Macro',
                subtitle: 'Selic, CDI, IPCA',
                onTap: () => context.push('/macro'),
              ),
              _MarketCard(
                icon: Icons.apartment_rounded,
                title: 'FIIs',
                subtitle: 'Fundos imobiliários',
                isPro: true,
                onTap: () => context.push('/pro/fiis'),
              ),
              _MarketCard(
                icon: Icons.savings_outlined,
                title: 'Tesouro',
                subtitle: 'Títulos públicos',
                isPro: true,
                onTap: () => context.push('/pro/treasury'),
              ),
              _MarketCard(
                icon: Icons.account_tree_outlined,
                title: 'Opções',
                subtitle: 'Calls e puts',
                isPro: true,
                onTap: () => context.push('/pro/options'),
              ),
              _MarketCard(
                icon: Icons.stacked_line_chart_rounded,
                title: 'Futuros',
                subtitle: 'Contratos futuros',
                isPro: true,
                onTap: () => context.push('/pro/futures'),
              ),
            ],
          ),
        ],
      );
}

class _MarketCard extends StatelessWidget {
  const _MarketCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isPro = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isPro;

  @override
  Widget build(BuildContext context) => Card(
        color: isPro ? AppColors.proSurface : Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon,
                        color: isPro ? AppColors.pro : AppColors.primary),
                    const Spacer(),
                    if (isPro) const ProBadge(),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(subtitle,
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key});

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  final _apiKeyController = TextEditingController();
  bool _obscureApiKey = true;

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _saveApiKey() async {
    final value = _apiKeyController.text.trim();
    if (value.isEmpty) return;
    await ref.read(apiKeyProvider.notifier).save(value);
    _apiKeyController.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chave salva. Consultas atualizadas.')),
    );
  }

  Future<void> _clearApiKey() async {
    await ref.read(apiKeyProvider.notifier).clear();
    _apiKeyController.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chave removida deste dispositivo.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final apiKey = ref.watch(apiKeyProvider);
    final configured = apiKey.isNotEmpty;
    final suffix = configured && apiKey.length >= 4
        ? apiKey.substring(apiKey.length - 4)
        : null;

    return ScreenScaffold(
      title: 'Minha conta',
      subtitle: 'Acesso à API e preferências.',
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      configured
                          ? Icons.verified_user_outlined
                          : Icons.key_outlined,
                      color:
                          configured ? AppColors.positive : AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        configured
                            ? 'Chave configurada${suffix == null ? '' : ' ••••$suffix'}'
                            : 'Conectar à brapi.dev',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _apiKeyController,
                  obscureText: _obscureApiKey,
                  enableSuggestions: false,
                  autocorrect: false,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _saveApiKey(),
                  decoration: InputDecoration(
                    labelText:
                        configured ? 'Substituir chave da API' : 'Chave da API',
                    hintText: 'Cole sua chave da brapi.dev',
                    prefixIcon: const Icon(Icons.vpn_key_outlined),
                    suffixIcon: IconButton(
                      tooltip:
                          _obscureApiKey ? 'Mostrar chave' : 'Ocultar chave',
                      onPressed: () => setState(
                        () => _obscureApiKey = !_obscureApiKey,
                      ),
                      icon: Icon(
                        _obscureApiKey
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _saveApiKey,
                        icon: const Icon(Icons.link_rounded),
                        label: Text(configured ? 'Atualizar' : 'Conectar'),
                      ),
                    ),
                    if (configured) ...[
                      const SizedBox(width: 10),
                      OutlinedButton(
                        onPressed: _clearApiKey,
                        child: const Text('Remover'),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'A chave fica somente neste navegador ou dispositivo. Ao salvar, todas as consultas são refeitas com o header Authorization: Bearer.',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 10,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _AccountTile(
                icon: Icons.query_stats_rounded,
                label: 'Estados da API',
                onTap: () => context.push('/api-states'),
              ),
              const Divider(height: 1),
              const _AccountTile(
                  icon: Icons.palette_outlined, label: 'Tema: claro'),
              const Divider(height: 1),
              const _AccountTile(
                  icon: Icons.info_outline_rounded,
                  label: 'Sobre o aplicativo'),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const InfoCard(
          icon: Icons.security_rounded,
          title: 'Segurança',
          message:
              'Para demonstração, a chave é mantida localmente. Em produção, use um backend intermediário para não distribuir o segredo no aplicativo.',
          color: AppColors.warningSurface,
          borderColor: AppColors.warningBorder,
          iconColor: AppColors.warning,
        ),
      ],
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({required this.icon, required this.label, this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      );
}
