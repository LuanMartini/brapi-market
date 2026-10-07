import 'package:brapi_market/src/core/app_theme.dart';
import 'package:brapi_market/src/ui/app_shell.dart';
import 'package:brapi_market/src/ui/detail_pages.dart';
import 'package:brapi_market/src/ui/market_pages.dart';
import 'package:brapi_market/src/ui/primary_pages.dart';
import 'package:brapi_market/src/ui/support_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

GoRouter _createRouter() => GoRouter(
      initialLocation: '/',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              AppShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(path: '/', builder: (_, __) => const HomePage())
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: '/search', builder: (_, __) => const SearchPage())
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: '/markets', builder: (_, __) => const MarketsPage())
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                  path: '/favorites', builder: (_, __) => const FavoritesPage())
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: '/account', builder: (_, __) => const AccountPage())
            ]),
          ],
        ),
        GoRoute(
          path: '/asset/:symbol',
          builder: (_, state) => AssetDetailPage(
              symbol: state.pathParameters['symbol']!.toUpperCase()),
          routes: [
            GoRoute(
              path: 'chart',
              builder: (_, state) => ChartPage(
                  symbol: state.pathParameters['symbol']!.toUpperCase()),
            ),
            GoRoute(
              path: 'dividends',
              builder: (_, state) => DividendsPage(
                  symbol: state.pathParameters['symbol']!.toUpperCase()),
            ),
            GoRoute(
              path: 'profile',
              builder: (_, state) => ProfilePage(
                  symbol: state.pathParameters['symbol']!.toUpperCase()),
            ),
            GoRoute(
              path: 'statistics',
              builder: (_, state) => StatisticsPage(
                  symbol: state.pathParameters['symbol']!.toUpperCase()),
            ),
            GoRoute(
              path: 'financial',
              builder: (_, state) => FinancialDataPage(
                  symbol: state.pathParameters['symbol']!.toUpperCase()),
            ),
          ],
        ),
        GoRoute(path: '/currency', builder: (_, __) => const CurrencyPage()),
        GoRoute(path: '/crypto', builder: (_, __) => const CryptoPage()),
        GoRoute(path: '/macro', builder: (_, __) => const MacroPage()),
        GoRoute(
          path: '/pro/fiis',
          builder: (_, __) => const ProFeaturePage(feature: ProFeature.fiis),
        ),
        GoRoute(
          path: '/pro/treasury',
          builder: (_, __) =>
              const ProFeaturePage(feature: ProFeature.treasury),
        ),
        GoRoute(
          path: '/pro/options',
          builder: (_, __) => const ProFeaturePage(feature: ProFeature.options),
        ),
        GoRoute(
          path: '/pro/futures',
          builder: (_, __) => const ProFeaturePage(feature: ProFeature.futures),
        ),
        GoRoute(path: '/api-states', builder: (_, __) => const ApiStatesPage()),
      ],
    );

class BrapiMarketApp extends StatefulWidget {
  const BrapiMarketApp({super.key});

  @override
  State<BrapiMarketApp> createState() => _BrapiMarketAppState();
}

class _BrapiMarketAppState extends State<BrapiMarketApp> {
  late final GoRouter _router = _createRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'brapi Market',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: _router,
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      );
}
