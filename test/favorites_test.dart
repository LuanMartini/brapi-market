import 'package:brapi_market/src/state/providers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('favoritos sao persistidos e removidos', () async {
    SharedPreferences.setMockInitialValues({
      'favorite_symbols': <String>['PETR4']
    });
    final preferences = await SharedPreferences.getInstance();
    final notifier = FavoritesNotifier(preferences);

    expect(notifier.state, ['PETR4']);
    await notifier.toggle('VALE3');
    expect(notifier.state, ['PETR4', 'VALE3']);
    await notifier.remove('PETR4');
    expect(notifier.state, ['VALE3']);
    expect(preferences.getStringList('favorite_symbols'), ['VALE3']);
  });

  test('chave da API e persistida e pode ser removida', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final notifier = ApiKeyNotifier(preferences);

    expect(notifier.state, isEmpty);
    await notifier.save(' token-teste ');
    expect(notifier.state, 'token-teste');
    expect(preferences.getString('brapi_api_key'), 'token-teste');

    await notifier.clear();
    expect(notifier.state, isEmpty);
    expect(preferences.containsKey('brapi_api_key'), isFalse);
  });
}
