import 'package:cryprice_frontend/features/portfolio/data/models/portfolio_response_model.dart';
import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio.dart';
import 'package:cryprice_frontend/features/portfolio/domain/entities/portfolio_price_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses full portfolio response', () {
    final portfolio = PortfolioResponseModel.fromJson(_fullResponse()).portfolio;

    expect(portfolio.summary.totalValueUsd, '5240.75');
    expect(portfolio.summary.walletsCount, 3);
    expect(portfolio.summary.assetsCount, 5);
    expect(portfolio.summary.networksCount, 2);
    expect(portfolio.summary.updatedAt, '2026-05-19T13:30:00.000Z');
    expect(portfolio.networks, hasLength(1));

    final network = portfolio.networks.single;
    expect(network.networkId, 1);
    expect(network.chainId, 1);
    expect(network.name, 'Ethereum');
    expect(network.nativeSymbol, 'ETH');
    expect(network.totalValueUsd, '4150.59');
    expect(network.assets, hasLength(1));

    final asset = network.assets.single;
    expect(asset.assetId, '10');
    expect(asset.symbol, 'USDC');
    expect(asset.address, '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48');
    expect(asset.decimals, 6);
    expect(asset.balanceRaw, '250000000');
    expect(asset.balance, '250.0');
    expect(asset.priceUsd, '1.0001');
    expect(asset.valueUsd, '250.03');
    expect(asset.priceStatus, PortfolioPriceStatus.ok);
    expect(asset.priceCalculatedAt, '2026-05-19T13:20:00.000Z');
    expect(asset.balanceSyncedAt, '2026-05-19T13:21:00.000Z');
    expect(asset.wallets, hasLength(1));

    final wallet = asset.wallets.single;
    expect(wallet.walletId, '1');
    expect(wallet.address, '0x111...');
    expect(wallet.label, 'Main wallet');
    expect(wallet.balanceRaw, '100000000');
    expect(wallet.balance, '100.0');
    expect(wallet.valueUsd, '100.01');
    expect(wallet.syncedAt, '2026-05-19T13:21:00.000Z');
    expect(wallet.blockNumber, 22500111);
  });

  test('parses empty networks', () {
    final portfolio = PortfolioResponseModel.fromJson({
      'summary': {
        'totalValueUsd': '0',
        'walletsCount': 0,
        'assetsCount': 0,
        'networksCount': 0,
        'updatedAt': '2026-05-19T13:30:00.000Z',
      },
      'networks': <Object?>[],
    }).portfolio;

    expect(portfolio.networks, isEmpty);
    expect(portfolio.isEmpty, isTrue);
    expect(portfolio.summary.totalValueUsd, '0');
  });

  test('parses missing price with null priceUsd and valueUsd', () {
    final asset = _parseSingleAsset({
      'priceStatus': 'missing',
      'priceUsd': null,
      'valueUsd': null,
    });

    expect(asset.priceStatus, PortfolioPriceStatus.missing);
    expect(asset.priceUsd, isNull);
    expect(asset.valueUsd, isNull);
  });

  test('parses stale price status', () {
    final asset = _parseSingleAsset({
      'priceStatus': 'stale',
      'priceUsd': '1.0000',
      'valueUsd': '100.00',
    });

    expect(asset.priceStatus, PortfolioPriceStatus.stale);
    expect(asset.priceUsd, '1.0000');
    expect(asset.valueUsd, '100.00');
  });

  test('maps unknown priceStatus to unknown', () {
    final asset = _parseSingleAsset({'priceStatus': 'delayed'});

    expect(asset.priceStatus, PortfolioPriceStatus.unknown);
  });

  test('parses numeric and string assetId and walletId as strings', () {
    final numericAsset = _parseSingleAsset({
      'assetId': 10,
      'wallets': [
        _walletJson({'walletId': 1}),
      ],
    });
    final stringAsset = _parseSingleAsset({
      'assetId': '9007199254740993',
      'wallets': [
        _walletJson({'walletId': '9007199254740995'}),
      ],
    });

    expect(numericAsset.assetId, '10');
    expect(numericAsset.wallets.single.walletId, '1');
    expect(stringAsset.assetId, '9007199254740993');
    expect(stringAsset.wallets.single.walletId, '9007199254740995');
  });

  test('keeps financial fields as strings instead of parsing doubles', () {
    final portfolio = PortfolioResponseModel.fromJson(_fullResponse()).portfolio;
    final asset = portfolio.networks.single.assets.single;
    final wallet = asset.wallets.single;

    expect(portfolio.summary.totalValueUsd, isA<String>());
    expect(portfolio.networks.single.totalValueUsd, isA<String>());
    expect(asset.balanceRaw, isA<String>());
    expect(asset.balance, isA<String>());
    expect(asset.priceUsd, isA<String>());
    expect(asset.valueUsd, isA<String>());
    expect(wallet.balanceRaw, isA<String>());
    expect(wallet.balance, isA<String>());
    expect(wallet.valueUsd, isA<String>());
    expect(asset.priceUsd, '1.0001');
    expect(asset.valueUsd, '250.03');
  });

  test('parses full new portfolio response', () {
    final portfolio = PortfolioResponseModel.fromJson(_newApiResponse()).portfolio;

    expect(portfolio.summary.totalValueUsd, '1000.00');
    expect(portfolio.summary.walletValueUsd, '600.00');
    expect(portfolio.summary.suppliedValueUsd, '500.00');
    expect(portfolio.summary.borrowedValueUsd, '100.00');
    expect(portfolio.summary.grossValueUsd, '1100.00');
    expect(portfolio.summary.netValueUsd, '1000.00');
    expect(portfolio.summary.healthFactor, '2.50');
    expect(portfolio.summary.healthFactorStatus, PortfolioHealthFactorStatus.safe);
    expect(portfolio.totals.netValueUsd, '1000.00');
    expect(portfolio.mainNetValueUsd, '1000.00');

    final holding = portfolio.walletHoldings.single;
    expect(holding.kind, 'wallet');
    expect(holding.networkId, 1);
    expect(holding.network, 'ethereum');
    expect(holding.networkName, 'Ethereum');
    expect(holding.chainId, 1);
    expect(holding.assetId, '10');
    expect(holding.assetSymbol, 'USDC');
    expect(holding.assetAddress, '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48');
    expect(holding.symbol, 'USDC');
    expect(holding.address, '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48');
    expect(holding.amount, '250.0');
    expect(holding.balanceRaw, '250000000');
    expect(holding.decimals, 6);
    expect(holding.priceUsd, '1.0000');
    expect(holding.valueUsd, '250.00');
    expect(holding.priceStatus, PortfolioPriceStatus.ok);

    final supplied = portfolio.protocolPositions.supplied.single;
    expect(supplied.protocol, 'aave-v3');
    expect(supplied.positionSide, PortfolioPositionSide.supplied);
    expect(supplied.debtType, isNull);
    expect(supplied.underlyingSymbol, 'USDC');
    expect(supplied.valueUsd, '500.00');

    final borrowed = portfolio.protocolPositions.borrowed.single;
    expect(borrowed.positionSide, PortfolioPositionSide.borrowed);
    expect(borrowed.debtType, PortfolioDebtType.variable);
    expect(borrowed.valueUsd, '100.00');

    final healthFactor = portfolio.defiRisk.healthFactor;
    expect(healthFactor, isNotNull);
    expect(healthFactor!.value, '2.50');
    expect(healthFactor.status, PortfolioHealthFactorStatus.safe);
    expect(healthFactor.statusLabel, 'Safe');
    expect(healthFactor.protocol, 'aave-v3');
    expect(healthFactor.protocolName, 'Aave V3');
    expect(healthFactor.stale, isFalse);

    final positionHealth = portfolio.defiRisk.positionsHealth.single;
    expect(positionHealth.walletId, '1');
    expect(positionHealth.walletAddress, '0x111...');
    expect(positionHealth.status, PortfolioHealthFactorStatus.watch);
    expect(positionHealth.threshold, '1.00');
    expect(positionHealth.stale, isTrue);
  });

  test('uses empty defaults when new response sections are missing', () {
    final portfolio = PortfolioResponseModel.fromJson(_fullResponse()).portfolio;

    expect(portfolio.walletHoldings, isEmpty);
    expect(portfolio.protocolPositions.supplied, isEmpty);
    expect(portfolio.protocolPositions.borrowed, isEmpty);
    expect(portfolio.defiRisk.healthFactor, isNull);
    expect(portfolio.defiRisk.positionsHealth, isEmpty);
    expect(portfolio.totals.netValueUsd, isNull);
    expect(portfolio.wallets, isEmpty);
    expect(portfolio.protocolSummaries, isEmpty);
    expect(portfolio.allocation, isNull);
    expect(portfolio.isEmpty, isFalse);
  });

  test('uses empty defaults when new response sections are null', () {
    final portfolio = PortfolioResponseModel.fromJson({
      ..._fullResponse(),
      'walletHoldings': null,
      'protocolPositions': null,
      'defiRisk': null,
      'totals': null,
      'wallets': null,
      'protocolSummaries': null,
    }).portfolio;

    expect(portfolio.walletHoldings, isEmpty);
    expect(portfolio.protocolPositions.supplied, isEmpty);
    expect(portfolio.protocolPositions.borrowed, isEmpty);
    expect(portfolio.defiRisk.healthFactor, isNull);
    expect(portfolio.defiRisk.positionsHealth, isEmpty);
    expect(portfolio.totals.grossValueUsd, isNull);
    expect(portfolio.wallets, isEmpty);
    expect(portfolio.protocolSummaries, isEmpty);
  });

  test('parses wallets array for wallet selector', () {
    final portfolio = PortfolioResponseModel.fromJson(
      _newApiResponse(wallets: [_walletSummaryJson()]),
    ).portfolio;

    expect(portfolio.wallets, hasLength(1));
    final wallet = portfolio.wallets.single;
    expect(wallet.walletId, '1');
    expect(wallet.walletAddress, '0xabc12345678901234567890123456789012345678');
    expect(wallet.walletLabel, 'Main wallet');
    expect(wallet.netValueUsd, '500.00');
    expect(wallet.healthFactor, '2.10');
    expect(wallet.healthFactorStatus, PortfolioHealthFactorStatus.safe);
    expect(wallet.healthFactorStatusLabel, 'Safe');
  });

  test('parses protocolSummaries with nested networks', () {
    final portfolio = PortfolioResponseModel.fromJson(
      _newApiResponse(protocolSummaries: [_protocolSummaryJson()]),
    ).portfolio;

    expect(portfolio.protocolSummaries, hasLength(1));
    final summary = portfolio.protocolSummaries.single;
    expect(summary.protocol, 'aave-v3');
    expect(summary.protocolName, 'Aave V3');
    expect(summary.category, 'lending');
    expect(summary.totalValueUsd, '800.00');
    expect(summary.networks, hasLength(1));

    final network = summary.networks.single;
    expect(network.networkId, 1);
    expect(network.networkName, 'Ethereum');
    expect(network.netValueUsd, '800.00');
    expect(network.healthFactorStatus, PortfolioHealthFactorStatus.watch);
    expect(network.healthFactorStatusLabel, 'Watch');
  });

  test('parses nested wallet aliases in walletHoldings', () {
    final response = _newApiResponse();
    response['walletHoldings'] = [
      _walletHoldingJson({
        'wallets': [
          {
            'walletId': 1,
            'address': '0xlegacy',
            'walletAddress': '0xalias',
            'label': 'Legacy label',
            'walletLabel': 'Alias label',
            'amount': '10.5',
            'valueUsd': '10.50',
          },
        ],
      }),
    ];
    final holding = PortfolioResponseModel.fromJson(response).portfolio.walletHoldings.single;

    expect(holding.wallets, hasLength(1));
    final nested = holding.wallets.single;
    expect(nested.walletAddress, '0xalias');
    expect(nested.address, '0xalias');
    expect(nested.walletLabel, 'Alias label');
    expect(nested.label, 'Alias label');
    expect(nested.amount, '10.5');
    expect(nested.balance, '10.5');
    expect(holding.priceUsd, '1.0000');
    expect(holding.priceStatus, PortfolioPriceStatus.ok);
  });

  test('falls back to legacy address and label when wallet aliases are missing', () {
    final nested = PortfolioWalletBreakdownModel.fromJson({
      'walletId': 1,
      'address': '0xlegacy',
      'label': 'Legacy label',
      'balance': '1.0',
      'balanceRaw': '1000000',
      'valueUsd': '1.00',
    }).toEntity();

    expect(nested.walletAddress, '0xlegacy');
    expect(nested.walletLabel, 'Legacy label');
  });

  test('parses nested wallet aliases in protocol positions', () {
    final response = _newApiResponse();
    response['protocolPositions'] = {
      'supplied': [
        _protocolPositionJson({
          'wallets': [
            {
              'walletId': '2',
              'walletAddress': '0xsupplied',
              'walletLabel': 'Supplied wallet',
              'amount': '100',
              'valueUsd': '100.00',
            },
          ],
        }),
      ],
      'borrowed': <Object?>[],
    };
    final supplied = PortfolioResponseModel.fromJson(response)
        .portfolio
        .protocolPositions
        .supplied
        .single;

    expect(supplied.wallets.single.walletAddress, '0xsupplied');
    expect(supplied.wallets.single.walletLabel, 'Supplied wallet');
    expect(supplied.priceStatus, PortfolioPriceStatus.ok);
  });

  test('parses walletLabel in positionsHealth', () {
    final portfolio = PortfolioResponseModel.fromJson(
      _newApiResponse(
        defiRisk: {
          'healthFactor': _healthFactorJson(),
          'positionsHealth': [
            _positionHealthJson({'walletLabel': 'Risk wallet'}),
          ],
        },
      ),
    ).portfolio;

    expect(portfolio.defiRisk.positionsHealth.single.walletLabel, 'Risk wallet');
  });

  test('parses health factor none status', () {
    final portfolio = PortfolioResponseModel.fromJson(
      _newApiResponse(
        wallets: [
          _walletSummaryJson({'healthFactorStatus': 'none'}),
        ],
      ),
    ).portfolio;

    expect(portfolio.wallets.single.healthFactorStatus, PortfolioHealthFactorStatus.none);
  });

  test('parses priceStatus stale in holdings and positions', () {
    final response = _newApiResponse();
    response['walletHoldings'] = [
      _walletHoldingJson({'priceStatus': 'stale', 'priceUsd': '1.00', 'valueUsd': '1.00'}),
    ];
    response['protocolPositions'] = {
      'supplied': [
        _protocolPositionJson({'priceStatus': 'stale', 'priceUsd': '1.00', 'valueUsd': '1.00'}),
      ],
      'borrowed': <Object?>[],
    };

    final portfolio = PortfolioResponseModel.fromJson(response).portfolio;

    expect(portfolio.walletHoldings.single.priceStatus, PortfolioPriceStatus.stale);
    expect(
      portfolio.protocolPositions.supplied.single.priceStatus,
      PortfolioPriceStatus.stale,
    );
  });

  test('keeps borrowed value as positive string', () {
    final borrowed = PortfolioResponseModel.fromJson(_newApiResponse())
        .portfolio
        .protocolPositions
        .borrowed
        .single;

    expect(borrowed.valueUsd, '100.00');
    expect(borrowed.valueUsd, isNot(startsWith('-')));
  });

  test('keeps zero price strings when price status is missing', () {
    final response = _newApiResponse();
    response['walletHoldings'] = [
      _walletHoldingJson({
        'priceStatus': 'missing',
        'priceUsd': '0',
        'valueUsd': '0',
      }),
    ];
    final holding = PortfolioResponseModel.fromJson(response).portfolio.walletHoldings.single;

    expect(holding.priceStatus, PortfolioPriceStatus.missing);
    expect(holding.priceUsd, '0');
    expect(holding.valueUsd, '0');
  });

  test('portfolio with only positionsHealth is not empty', () {
    final response = _newApiResponse(
      defiRisk: {
        'healthFactor': null,
        'positionsHealth': [_positionHealthJson()],
      },
    );
    response['walletHoldings'] = <Object?>[];
    response['protocolPositions'] = {
      'supplied': <Object?>[],
      'borrowed': <Object?>[],
    };

    final portfolio = PortfolioResponseModel.fromJson(response).portfolio;

    expect(portfolio.hasPositionsHealth, isTrue);
    expect(portfolio.isEmpty, isFalse);
  });

  test('parses missing price status in wallet holdings and positions', () {
    final response = _newApiResponse();
    response['walletHoldings'] = [
      _walletHoldingJson({
        'priceStatus': 'missing',
        'priceUsd': null,
        'valueUsd': null,
      }),
    ];
    response['protocolPositions'] = {
      'supplied': [
        _protocolPositionJson({
          'priceStatus': 'missing',
          'priceUsd': null,
          'valueUsd': null,
        }),
      ],
      'borrowed': <Object?>[],
    };

    final portfolio = PortfolioResponseModel.fromJson(response).portfolio;

    expect(portfolio.walletHoldings.single.priceStatus, PortfolioPriceStatus.missing);
    expect(portfolio.walletHoldings.single.priceUsd, isNull);
    expect(portfolio.walletHoldings.single.valueUsd, isNull);
    expect(
      portfolio.protocolPositions.supplied.single.priceStatus,
      PortfolioPriceStatus.missing,
    );
  });

  test('parses health factor no debt, stale, and unknown statuses', () {
    final noDebt = PortfolioResponseModel.fromJson(
      _newApiResponse(
        defiRisk: {
          'healthFactor': _healthFactorJson({'status': 'no_debt'}),
          'positionsHealth': <Object?>[],
        },
      ),
    ).portfolio;
    final stale = PortfolioResponseModel.fromJson(
      _newApiResponse(
        defiRisk: {
          'healthFactor': _healthFactorJson({
            'status': 'stale',
            'stale': true,
          }),
          'positionsHealth': <Object?>[],
        },
      ),
    ).portfolio;
    final unknown = PortfolioResponseModel.fromJson(
      _newApiResponse(
        defiRisk: {
          'healthFactor': _healthFactorJson({'status': 'paused'}),
          'positionsHealth': [
            _positionHealthJson({'status': 'paused'}),
          ],
        },
      ),
    ).portfolio;

    expect(noDebt.defiRisk.healthFactor!.status, PortfolioHealthFactorStatus.noDebt);
    expect(stale.defiRisk.healthFactor!.status, PortfolioHealthFactorStatus.stale);
    expect(stale.defiRisk.healthFactor!.stale, isTrue);
    expect(unknown.defiRisk.healthFactor!.status, PortfolioHealthFactorStatus.unknown);
    expect(unknown.defiRisk.positionsHealth.single.status, PortfolioHealthFactorStatus.unknown);
  });

  test('legacy-only response still parses and falls back to total value', () {
    final portfolio = PortfolioResponseModel.fromJson(_fullResponse()).portfolio;

    expect(portfolio.networks.single.assets.single.symbol, 'USDC');
    expect(portfolio.walletHoldings, isEmpty);
    expect(portfolio.mainNetValueUsd, '5240.75');
    expect(portfolio.isEmpty, isFalse);
  });

  test('parses global allocation block', () {
    final portfolio = PortfolioResponseModel.fromJson(
      _newApiResponse(allocation: _globalAllocationJson()),
    ).portfolio;

    expect(portfolio.allocation, isNotNull);
    expect(portfolio.allocation!.assets, hasLength(2));
    expect(portfolio.allocation!.assets.first.label, 'USDC');
    expect(portfolio.allocation!.assets.first.valueUsd, '600.00');
    expect(portfolio.allocation!.assets.first.percentage, '60');
    expect(portfolio.allocation!.debts, isEmpty);
    expect(portfolio.allocation!.protocols.single.protocol, 'aave-v3');
    expect(portfolio.allocation!.networks.single.networkName, 'Ethereum');
  });

  test('parses wallet-scoped allocation block', () {
    final portfolio = PortfolioResponseModel.fromJson(
      _newApiResponse(allocation: _walletAllocationJson()),
    ).portfolio;

    final wallet = portfolio.allocation!.wallets.single;
    expect(wallet.walletId, '4');
    expect(wallet.walletLabel, 'TW');
    expect(wallet.assets.single.label, 'ETH');
    expect(wallet.debts, isEmpty);
    expect(wallet.protocols.single.label, 'Aave V3');
    expect(wallet.networks.single.label, 'Ethereum');
  });

  test('parses Other allocation item', () {
    final portfolio = PortfolioResponseModel.fromJson(
      _newApiResponse(
        allocation: {
          'assets': [
            _allocationItemJson(label: 'USDC', percentage: '80'),
            _allocationItemJson(key: 'other', label: 'Other', percentage: '20'),
          ],
          'debts': <Object?>[],
          'protocols': <Object?>[],
          'networks': <Object?>[],
          'wallets': <Object?>[],
        },
      ),
    ).portfolio;

    expect(portfolio.allocation!.assets.last.label, 'Other');
    expect(portfolio.allocation!.assets.last.percentage, '20');
  });

  test('missing allocation does not crash parsing', () {
    final portfolio = PortfolioResponseModel.fromJson(_fullResponse()).portfolio;
    expect(portfolio.allocation, isNull);
  });

  test('empty allocation arrays parse as null allocation', () {
    final portfolio = PortfolioResponseModel.fromJson(
      _newApiResponse(
        allocation: {
          'assets': <Object?>[],
          'debts': <Object?>[],
          'protocols': <Object?>[],
          'networks': <Object?>[],
          'wallets': <Object?>[],
        },
      ),
    ).portfolio;

    expect(portfolio.allocation, isNull);
  });

  test('parses backend-relative logo_url on wallet holdings', () {
    const logoUrl =
        '/static/token-icons/42161/0xaf88d065e77c8cc2239327c5edb3a432268e5831.png?v=d2cc';
    final portfolio = PortfolioResponseModel.fromJson({
      ..._newApiResponse(),
      'walletHoldings': [
        _walletHoldingJson({'logo_url': logoUrl}),
      ],
    }).portfolio;

    expect(portfolio.walletHoldings.single.logoUrl, logoUrl);
  });

  test('parses logoUrl camelCase on wallet holdings and defi positions', () {
    const logoUrl = '/static/token-icons/1/0xabc.png?v=hash1';
    final portfolio = PortfolioResponseModel.fromJson({
      ..._newApiResponse(),
      'walletHoldings': [
        _walletHoldingJson({'logoUrl': logoUrl}),
      ],
      'protocolPositions': {
        'supplied': [
          _protocolPositionJson({'logoUrl': logoUrl}),
        ],
        'borrowed': [
          _protocolPositionJson({
            'positionSide': 'borrowed',
            'tokenRole': 'debt',
            'debtType': 'variable',
            'logoUrl': null,
          }),
        ],
      },
    }).portfolio;

    expect(portfolio.walletHoldings.single.logoUrl, logoUrl);
    expect(portfolio.protocolPositions.supplied.single.logoUrl, logoUrl);
    expect(portfolio.protocolPositions.borrowed.single.logoUrl, isNull);
  });

  test('prefers logo_url over logoUrl when both are present', () {
    final portfolio = PortfolioResponseModel.fromJson({
      ..._newApiResponse(),
      'walletHoldings': [
        _walletHoldingJson({
          'logo_url': 'https://api.cryprice.dev/a.png',
          'logoUrl': 'https://api.cryprice.dev/b.png',
        }),
      ],
    }).portfolio;

    expect(
      portfolio.walletHoldings.single.logoUrl,
      'https://api.cryprice.dev/a.png',
    );
  });

  test('parses logo_url on wallet holdings and defi positions', () {
    const logoUrl = 'https://api.cryprice.dev/static/token-icons/1/0xabc.png';
    final portfolio = PortfolioResponseModel.fromJson({
      ..._newApiResponse(),
      'walletHoldings': [
        _walletHoldingJson({'logo_url': logoUrl}),
      ],
      'protocolPositions': {
        'supplied': [
          _protocolPositionJson({'logo_url': logoUrl}),
        ],
        'borrowed': [
          _protocolPositionJson({
            'positionSide': 'borrowed',
            'tokenRole': 'debt',
            'debtType': 'variable',
            'logo_url': null,
          }),
        ],
      },
    }).portfolio;

    expect(portfolio.walletHoldings.single.logoUrl, logoUrl);
    expect(portfolio.protocolPositions.supplied.single.logoUrl, logoUrl);
    expect(portfolio.protocolPositions.borrowed.single.logoUrl, isNull);
  });

  test('parses logo_url on legacy network assets and allocation items', () {
    const logoUrl = 'https://api.cryprice.dev/static/token-icons/1/0xabc.png';
    final portfolio = PortfolioResponseModel.fromJson({
      ..._newApiResponse(
        allocation: {
          'assets': [
            _allocationItemJson(overrides: {'logo_url': logoUrl}),
          ],
          'debts': <Object?>[],
          'protocols': <Object?>[],
          'networks': <Object?>[],
          'wallets': <Object?>[],
        },
      ),
      'networks': [
        {
          'networkId': 1,
          'chainId': 1,
          'name': 'Ethereum',
          'nativeSymbol': 'ETH',
          'totalValueUsd': '600.00',
          'assets': [_assetJson({'logo_url': logoUrl})],
        },
      ],
    }).portfolio;

    expect(portfolio.allocation!.assets.single.logoUrl, logoUrl);
    expect(portfolio.networks.single.assets.single.logoUrl, logoUrl);
  });

  test('missing logo_url defaults to null without breaking parse', () {
    final portfolio = PortfolioResponseModel.fromJson(_newApiResponse()).portfolio;

    expect(portfolio.walletHoldings.single.logoUrl, isNull);
    expect(portfolio.protocolPositions.supplied.single.logoUrl, isNull);
  });
}

Map<String, Object?> _fullResponse() {
  return {
    'summary': {
      'totalValueUsd': '5240.75',
      'walletsCount': 3,
      'assetsCount': 5,
      'networksCount': 2,
      'updatedAt': '2026-05-19T13:30:00.000Z',
    },
    'networks': [
      {
        'networkId': 1,
        'chainId': 1,
        'name': 'Ethereum',
        'nativeSymbol': 'ETH',
        'totalValueUsd': '4150.59',
        'assets': [_assetJson()],
      },
    ],
  };
}

Map<String, Object?> _newApiResponse({
  Map<String, Object?>? defiRisk,
  List<Map<String, Object?>>? wallets,
  List<Map<String, Object?>>? protocolSummaries,
  Map<String, Object?>? allocation,
}) {
  return {
    'summary': {
      'totalValueUsd': '1000.00',
      'walletValueUsd': '600.00',
      'suppliedValueUsd': '500.00',
      'borrowedValueUsd': '100.00',
      'grossValueUsd': '1100.00',
      'netValueUsd': '1000.00',
      'healthFactor': '2.50',
      'healthFactorStatus': 'safe',
      'walletsCount': 2,
      'assetsCount': 3,
      'networksCount': 1,
      'updatedAt': '2026-05-19T13:30:00.000Z',
    },
    'walletHoldings': [_walletHoldingJson()],
    'protocolPositions': {
      'supplied': [_protocolPositionJson()],
      'borrowed': [
        _protocolPositionJson({
          'positionSide': 'borrowed',
          'tokenRole': 'debt',
          'debtType': 'variable',
          'amount': '100.0',
          'balanceRaw': '100000000',
          'valueUsd': '100.00',
        }),
      ],
    },
    'wallets': wallets ?? <Map<String, Object?>>[],
    'protocolSummaries': protocolSummaries ?? <Map<String, Object?>>[],
    'defiRisk': defiRisk ??
        {
          'healthFactor': _healthFactorJson(),
          'positionsHealth': [_positionHealthJson()],
        },
    'totals': {
      'walletValueUsd': '600.00',
      'suppliedValueUsd': '500.00',
      'borrowedValueUsd': '100.00',
      'grossValueUsd': '1100.00',
      'netValueUsd': '1000.00',
    },
    'networks': [
      {
        'networkId': 1,
        'chainId': 1,
        'name': 'Ethereum',
        'nativeSymbol': 'ETH',
        'totalValueUsd': '600.00',
        'assets': [_assetJson()],
      },
    ],
    if (allocation != null) 'allocation': allocation,
  };
}

Map<String, Object?> _allocationItemJson({
  String key = 'usdc',
  String label = 'USDC',
  String valueUsd = '600.00',
  String percentage = '60',
  Map<String, Object?> overrides = const {},
}) {
  return {
    'key': key,
    'label': label,
    'valueUsd': valueUsd,
    'percentage': percentage,
    ...overrides,
  };
}

Map<String, Object?> _globalAllocationJson() {
  return {
    'assets': [
      _allocationItemJson(),
      _allocationItemJson(
        key: 'eth',
        label: 'ETH',
        valueUsd: '400.00',
        percentage: '40',
      ),
    ],
    'debts': <Object?>[],
    'protocols': [
      _allocationItemJson(
        key: 'aave-v3',
        label: 'Aave V3',
        valueUsd: '700.00',
        percentage: '70',
        overrides: {'protocol': 'aave-v3', 'protocolName': 'Aave V3'},
      ),
    ],
    'networks': [
      _allocationItemJson(
        key: 'ethereum',
        label: 'Ethereum',
        valueUsd: '900.00',
        percentage: '90',
        overrides: {'network': 'ethereum', 'networkName': 'Ethereum', 'networkId': 1},
      ),
    ],
    'wallets': <Object?>[],
  };
}

Map<String, Object?> _walletAllocationJson() {
  return {
    'assets': [_allocationItemJson()],
    'debts': <Object?>[],
    'protocols': [_allocationItemJson(key: 'aave-v3', label: 'Aave V3')],
    'networks': [_allocationItemJson(key: 'ethereum', label: 'Ethereum')],
    'wallets': [
      {
        'walletId': 4,
        'walletAddress': '0xabc',
        'walletLabel': 'TW',
        'assets': [
          _allocationItemJson(
            key: 'eth',
            label: 'ETH',
            valueUsd: '400.00',
            percentage: '100',
          ),
        ],
        'debts': <Object?>[],
        'protocols': [
          _allocationItemJson(
            key: 'aave-v3',
            label: 'Aave V3',
            valueUsd: '400.00',
            percentage: '100',
          ),
        ],
        'networks': [
          _allocationItemJson(
            key: 'ethereum',
            label: 'Ethereum',
            valueUsd: '400.00',
            percentage: '100',
          ),
        ],
      },
    ],
  };
}

Map<String, Object?> _walletHoldingJson([Map<String, Object?> overrides = const {}]) {
  return {
    'kind': 'wallet',
    'networkId': 1,
    'network': 'ethereum',
    'networkName': 'Ethereum',
    'chainId': 1,
    'assetId': 10,
    'assetSymbol': 'USDC',
    'assetAddress': '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48',
    'symbol': 'USDC',
    'address': '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48',
    'amount': '250.0',
    'balanceRaw': '250000000',
    'decimals': 6,
    'priceUsd': '1.0000',
    'valueUsd': '250.00',
    'priceStatus': 'ok',
    ...overrides,
  };
}

Map<String, Object?> _protocolPositionJson([Map<String, Object?> overrides = const {}]) {
  return {
    'kind': 'protocol',
    'protocol': 'aave-v3',
    'protocolName': 'Aave V3',
    'networkId': 1,
    'network': 'ethereum',
    'networkName': 'Ethereum',
    'chainId': 1,
    'positionSide': 'supplied',
    'tokenRole': 'collateral',
    'debtType': null,
    'underlyingSymbol': 'USDC',
    'underlyingAddress': '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48',
    'tokenSymbol': 'aEthUSDC',
    'tokenAddress': '0x98c23e9d8f34fefb1b7bd6a91b7ff122f4e16f5c',
    'amount': '500.0',
    'balanceRaw': '500000000',
    'decimals': 6,
    'priceUsd': '1.0000',
    'valueUsd': '500.00',
    'priceStatus': 'ok',
    ...overrides,
  };
}

Map<String, Object?> _healthFactorJson([Map<String, Object?> overrides = const {}]) {
  return {
    'value': '2.50',
    'status': 'safe',
    'statusLabel': 'Safe',
    'protocol': 'aave-v3',
    'protocolName': 'Aave V3',
    'updatedAt': '2026-05-19T13:30:00.000Z',
    'stale': false,
    ...overrides,
  };
}

Map<String, Object?> _positionHealthJson([Map<String, Object?> overrides = const {}]) {
  return {
    'protocol': 'aave-v3',
    'protocolName': 'Aave V3',
    'networkId': 1,
    'network': 'ethereum',
    'networkName': 'Ethereum',
    'walletId': 1,
    'walletAddress': '0x111...',
    'healthFactor': '1.80',
    'status': 'watch',
    'statusLabel': 'Watch',
    'threshold': '1.00',
    'updatedAt': '2026-05-19T13:30:00.000Z',
    'stale': true,
    ...overrides,
  };
}

PortfolioAsset _parseSingleAsset(Map<String, Object?> overrides) {
  final portfolio = PortfolioResponseModel.fromJson({
    'summary': {
      'totalValueUsd': '100.00',
      'walletsCount': 1,
      'assetsCount': 1,
      'networksCount': 1,
      'updatedAt': '2026-05-19T13:30:00.000Z',
    },
    'networks': [
      {
        'networkId': 1,
        'chainId': 1,
        'name': 'Ethereum',
        'nativeSymbol': 'ETH',
        'totalValueUsd': '100.00',
        'assets': [_assetJson(overrides)],
      },
    ],
  }).portfolio;
  return portfolio.networks.single.assets.single;
}

Map<String, Object?> _assetJson([Map<String, Object?> overrides = const {}]) {
  return {
    'assetId': 10,
    'symbol': 'USDC',
    'address': '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48',
    'decimals': 6,
    'balanceRaw': '250000000',
    'balance': '250.0',
    'priceUsd': '1.0001',
    'valueUsd': '250.03',
    'priceStatus': 'ok',
    'priceCalculatedAt': '2026-05-19T13:20:00.000Z',
    'balanceSyncedAt': '2026-05-19T13:21:00.000Z',
    'wallets': [_walletJson()],
    ...overrides,
  };
}

Map<String, Object?> _walletJson([Map<String, Object?> overrides = const {}]) {
  return {
    'walletId': 1,
    'address': '0x111...',
    'label': 'Main wallet',
    'balanceRaw': '100000000',
    'balance': '100.0',
    'valueUsd': '100.01',
    'syncedAt': '2026-05-19T13:21:00.000Z',
    'blockNumber': 22500111,
    ...overrides,
  };
}

Map<String, Object?> _walletSummaryJson([Map<String, Object?> overrides = const {}]) {
  return {
    'walletId': 1,
    'walletAddress': '0xabc12345678901234567890123456789012345678',
    'walletLabel': 'Main wallet',
    'walletValueUsd': '200.00',
    'suppliedValueUsd': '400.00',
    'borrowedValueUsd': '100.00',
    'grossValueUsd': '600.00',
    'netValueUsd': '500.00',
    'healthFactor': '2.10',
    'healthFactorStatus': 'safe',
    'healthFactorStatusLabel': 'Safe',
    ...overrides,
  };
}

Map<String, Object?> _protocolSummaryJson([Map<String, Object?> overrides = const {}]) {
  return {
    'protocol': 'aave-v3',
    'protocolName': 'Aave V3',
    'category': 'lending',
    'walletValueUsd': '0',
    'suppliedValueUsd': '700.00',
    'borrowedValueUsd': '100.00',
    'grossValueUsd': '800.00',
    'netValueUsd': '700.00',
    'totalValueUsd': '800.00',
    'healthFactor': '1.90',
    'healthFactorStatus': 'watch',
    'healthFactorStatusLabel': 'Watch',
    'networks': [
      {
        'networkId': 1,
        'network': 'ethereum',
        'networkName': 'Ethereum',
        'netValueUsd': '800.00',
        'healthFactor': '1.90',
        'healthFactorStatus': 'watch',
        'healthFactorStatusLabel': 'Watch',
      },
    ],
    ...overrides,
  };
}
