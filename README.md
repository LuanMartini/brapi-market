# brapi Market

Aplicativo Flutter para acompanhar ativos do mercado brasileiro usando a API REST da [brapi.dev](https://brapi.dev/docs). A interface segue o wireframe fornecido no Figma, com navegação inferior, cards, busca, detalhes, gráfico, favoritos, mercados e estados completos de carregamento e erro.

## Funcionalidades

- Home com atualização em lote dos favoritos.
- Busca paginável de tickers, debounce de 400 ms, cancelamento da consulta anterior e filtros.
- Detalhe do ativo com preço, variação, OHLC, volume, market cap e faixa de 52 semanas.
- Histórico 1D, 5D, 1M, 6M e 1A com gráfico interativo e inspeção de OHLCV.
- Proventos, perfil da empresa, múltiplos e dados financeiros.
- Favoritos persistidos com `shared_preferences`.
- Câmbio, criptomoedas e indicadores macroeconômicos.
- Telas informativas PRO para FIIs, Tesouro, opções e futuros.
- Estados tipados para falta de conexão, timeout, 401, 403, 404, 429, 500 e 503.
- Retry limitado para falhas transitórias e respeito ao header `Retry-After`.

## Pré-requisitos

- Flutter estável com Dart 3.4 ou superior.
- Android Studio/SDK para Android.
- Xcode para compilar no iOS, quando estiver no macOS.

O ambiente em que este projeto foi produzido não possuía Flutter, Dart ou Java instalados. Por isso, os diretórios nativos devem ser gerados uma vez em uma máquina com Flutter:

```sh
flutter create --platforms=android,ios .
```

Esse comando preserva os arquivos existentes em `lib/`, `test/` e as dependências do projeto, acrescentando os runners nativos.

## Configuração da API

Não grave tokens em arquivos versionados. Execute o aplicativo com:

```sh
flutter pub get
flutter run --dart-define=BRAPI_API_KEY=SUA_CHAVE
```

Sem chave, a aplicação ainda consulta os símbolos públicos disponibilizados pela brapi.dev. Para liberar as demais rotas, abra **Conta > Conectar à brapi.dev**, cole a chave e toque em **Conectar**. A aplicação atualiza os providers automaticamente e mantém a chave apenas no armazenamento local do navegador ou dispositivo.

`--dart-define` evita deixar o token em texto no repositório, mas o valor ainda pode ser extraído de um aplicativo distribuído. Para produção, coloque a chave em um backend intermediário e faça o app conversar apenas com esse backend.

## Verificação

```sh
dart format .
flutter analyze
flutter test
flutter build apk --debug --dart-define=BRAPI_API_KEY=SUA_CHAVE
```

Os testes não acessam a API real. Eles cobrem parsing anulável, datas, aliases de logotipo, URL e headers, erros HTTP, favoritos, busca com debounce, carregamento da Home e navegação.

## Arquitetura

```text
lib/
├── main.dart
└── src/
    ├── app.dart                 # rotas e MaterialApp
    ├── core/                    # tema, configuração, HTTP, erros e formatação
    ├── data/                    # modelos, contrato e repositório brapi
    ├── state/                   # providers, favoritos e consultas assíncronas
    └── ui/                      # shell, páginas e componentes compartilhados
```

- `BrapiClient` concentra autenticação, timeout e retry.
- `MarketRepository` permite trocar a fonte real por fakes nos testes.
- Riverpod mantém carregamento e erros independentes por seção.
- `go_router` implementa os cinco destinos principais e as rotas de detalhe.
- Modelos aceitam campos ausentes, números inteiros/decimais e datas em ISO, data simples ou Unix.

## Endpoints usados

- `/v2/tickers`
- `/v2/tickers/coverage`
- `/v2/stocks/quote`
- `/v2/stocks/historical`
- `/v2/stocks/dividends`
- `/v2/stocks/profile`
- `/v2/stocks/statistics`
- `/v2/stocks/financial-data`
- `/v2/currency`
- `/v2/crypto`
- `/v2/macro/latest`

O endpoint `/v2/tickers/coverage`, confirmado pela documentação oficial atual, controla a disponibilidade das abas do detalhe. A documentação também possui endpoints PRO adicionais, mas eles não foram ligados às telas sem um contrato autenticado e validado para o plano do usuário.

## Decisões de produto

- PETR4, VALE3 e ITUB4 entram como favoritos iniciais de onboarding; as cotações continuam vindo da API, não de fixtures.
- Dados fictícios do wireframe não aparecem como informação real.
- A tela de conta não exibe plano ou consumo inventados; mostra `—` até existir uma fonte confirmada.
- Dados financeiros são apresentados dinamicamente apenas quando a propriedade realmente existe na resposta.
- Recursos PRO mantêm o fluxo e a identidade visual do wireframe, sem chamadas para rotas não validadas neste escopo.

## Referências visuais

O design foi baseado no frame `Brapi — Wireframe API v2`, viewport 390 × 844. Tokens principais extraídos:

- Texto: `#131C2B`
- Texto secundário: `#616E80`
- Azul: `#144F99`
- Superfície azul: `#E5F0FF`
- Borda: `#E0E5F0`
- Alta: `#0F8C57`
- Baixa: `#D12933`
- Raios principais: 14 px

O layout usa widgets responsivos e não incorpora screenshots do Figma.
