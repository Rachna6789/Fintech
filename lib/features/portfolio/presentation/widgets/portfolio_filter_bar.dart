import 'package:flutter/material.dart';

import '../../domain/entities/portfolio_asset_type.dart';
import '../../domain/entities/portfolio_filters.dart';

class PortfolioFilterBar extends StatelessWidget {
  const PortfolioFilterBar({
    super.key,
    required this.filters,
    required this.onSearchChanged,
    required this.onTypeChanged,
    required this.onFavoritesChanged,
    required this.onSortChanged,
  });

  final PortfolioFilters filters;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<PortfolioAssetType?> onTypeChanged;
  final ValueChanged<bool> onFavoritesChanged;
  final ValueChanged<PortfolioSortField> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          onChanged: onSearchChanged,
          decoration: const InputDecoration(
            labelText: 'Search assets',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilterChip(
              label: const Text('Favorites'),
              selected: filters.favoritesOnly,
              onSelected: onFavoritesChanged,
            ),
            DropdownMenu<PortfolioAssetType?>(
              initialSelection: filters.type,
              label: const Text('Type'),
              onSelected: onTypeChanged,
              dropdownMenuEntries: [
                const DropdownMenuEntry(value: null, label: 'All'),
                for (final type in PortfolioAssetType.values)
                  DropdownMenuEntry(value: type, label: type.label),
              ],
            ),
            DropdownMenu<PortfolioSortField>(
              initialSelection: filters.sortField,
              label: const Text('Sort'),
              onSelected: (value) {
                if (value != null) onSortChanged(value);
              },
              dropdownMenuEntries: const [
                DropdownMenuEntry(
                    value: PortfolioSortField.updatedAt, label: 'Updated'),
                DropdownMenuEntry(
                    value: PortfolioSortField.symbol, label: 'Symbol'),
                DropdownMenuEntry(
                    value: PortfolioSortField.name, label: 'Name'),
                DropdownMenuEntry(
                    value: PortfolioSortField.currentValue, label: 'Value'),
                DropdownMenuEntry(
                    value: PortfolioSortField.profitLoss, label: 'Profit'),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
