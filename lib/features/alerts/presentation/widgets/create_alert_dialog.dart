import 'package:flutter/material.dart';

import '../../domain/entities/price_alert_condition.dart';

class CreateAlertDialog extends StatefulWidget {
  const CreateAlertDialog({super.key, required this.onSubmit});

  final Future<bool> Function({
    required String symbol,
    required String assetName,
    required double targetPrice,
    required PriceAlertCondition condition,
    bool isEnabled,
  }) onSubmit;

  @override
  State<CreateAlertDialog> createState() => _CreateAlertDialogState();
}

class _CreateAlertDialogState extends State<CreateAlertDialog> {
  final _symbolController = TextEditingController();
  final _assetController = TextEditingController();
  final _priceController = TextEditingController();
  PriceAlertCondition _condition = PriceAlertCondition.above;
  bool _enabled = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _symbolController.dispose();
    _assetController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create price alert'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _symbolController,
              decoration: const InputDecoration(labelText: 'Symbol'),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _assetController,
              decoration: const InputDecoration(labelText: 'Asset name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Target price'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<PriceAlertCondition>(
              initialValue: _condition,
              decoration: const InputDecoration(labelText: 'Condition'),
              items: PriceAlertCondition.values
                  .map(
                    (condition) => DropdownMenuItem(
                      value: condition,
                      child: Text(condition.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _condition = value);
                }
              },
            ),
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              value: _enabled,
              onChanged: (value) => setState(() => _enabled = value),
              title: const Text('Enable alert immediately'),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final symbol = _symbolController.text.trim();
    final assetName = _assetController.text.trim();
    final price = double.tryParse(_priceController.text.trim());

    if (symbol.isEmpty || assetName.isEmpty || price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in every field.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final created = await widget.onSubmit(
      symbol: symbol,
      assetName: assetName,
      targetPrice: price,
      condition: _condition,
      isEnabled: _enabled,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (created) {
      Navigator.pop(context);
    }
  }
}
