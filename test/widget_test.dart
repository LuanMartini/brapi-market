import 'package:brapi_market/src/app.dart';
import 'package:brapi_market/src/data/brapi_repository.dart';
import 'package:brapi_market/src/state/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('home exibe cotacoes e navega para busca', (tester) async {
    SharedPreferences.setMockInitialValues({
      'favorite_symbols': <String>['PETR4'],
    });
    final preferences = await SharedPreferences.getInstance();
    final repository = FakeMarketRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          marketRepositoryProvider
              .overrideWithValue(repository as MarketRepository),
        ],
        child: const BrapiMarketApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mercado'), findsOneWidget);
    expect(find.text('PETR4'), findsWidgets);

    await tester.tap(find.text('Buscar').last);
    await tester.pumpAndSettle();
    expect(find.text('Buscar ativos'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('busca aplica debounce e mostra resultado', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = FakeMarketRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          marketRepositoryProvider.overrideWithValue(repository),
        ],
        child: const BrapiMarketApp(),
      ),
    );
    await tester.tap(find.text('Buscar').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'PETR');
    await tester.pump(const Duration(milliseconds: 399));
    expect(repository.lastSearch, isNot('PETR'));
    await tester.pump(const Duration(milliseconds: 2));
    await tester.pumpAndSettle();
    expect(repository.lastSearch, 'PETR');
    expect(find.text('Petrobras PN'), findsOneWidget);
  });
}
