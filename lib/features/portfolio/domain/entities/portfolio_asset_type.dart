enum PortfolioAssetType {
  stock,
  crypto,
  etf,
  fund,
  commodity,
  other;

  String get label => switch (this) {
        PortfolioAssetType.stock => 'Stock',
        PortfolioAssetType.crypto => 'Crypto',
        PortfolioAssetType.etf => 'ETF',
        PortfolioAssetType.fund => 'Fund',
        PortfolioAssetType.commodity => 'Commodity',
        PortfolioAssetType.other => 'Other',
      };
}
