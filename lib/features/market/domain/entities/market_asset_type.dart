enum MarketAssetType {
  stock,
  crypto;

  String get label => switch (this) {
        MarketAssetType.stock => 'Stock',
        MarketAssetType.crypto => 'Crypto',
      };
}
