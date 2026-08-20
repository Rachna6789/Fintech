import 'package:flutter/material.dart';

import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/portfolio_asset.dart';
import '../../domain/entities/portfolio_asset_input.dart';
import '../../domain/entities/portfolio_asset_type.dart';

class PortfolioAssetForm extends StatefulWidget {
  const PortfolioAssetForm({
    super.key,
    required this.onSubmit,
    this.initialAsset,
    this.isLoading = false,
  });

  final PortfolioAsset? initialAsset;
  final bool isLoading;
  final Future<void> Function(PortfolioAssetInput input) onSubmit;

  @override
  State<PortfolioAssetForm> createState() => _PortfolioAssetFormState();
}

class _PortfolioAssetFormState extends State<PortfolioAssetForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _symbolController;
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _averagePriceController;
  late final TextEditingController _currentPriceController;
  late final TextEditingController _notesController;
  late PortfolioAssetType _type;
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    final asset = widget.initialAsset;
    _symbolController = TextEditingController(text: asset?.symbol ?? '');
    _nameController = TextEditingController(text: asset?.name ?? '');
    _quantityController =
        TextEditingController(text: asset?.quantity.toString() ?? '');
    _averagePriceController =
        TextEditingController(text: asset?.averageBuyPrice.toString() ?? '');
    _currentPriceController =
        TextEditingController(text: asset?.currentPrice.toString() ?? '');
    _notesController = TextEditingController(text: asset?.notes ?? '');
    _type = asset?.type ?? PortfolioAssetType.stock;
    _isFavorite = asset?.isFavorite ?? false;
  }

  @override
  void dispose() {
    _symbolController.dispose();
    _nameController.dispose();
    _quantityController.dispose();
    _averagePriceController.dispose();
    _currentPriceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppTextField(
            controller: _symbolController,
            label: 'Symbol',
            textInputAction: TextInputAction.next,
            validator: (value) =>
                Validators.required(value, fieldName: 'Symbol'),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _nameController,
            label: 'Asset name',
            textInputAction: TextInputAction.next,
            validator: (value) =>
                Validators.required(value, fieldName: 'Asset name'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<PortfolioAssetType>(
            initialValue: _type,
            decoration: const InputDecoration(labelText: 'Asset type'),
            items: [
              for (final type in PortfolioAssetType.values)
                DropdownMenuItem(value: type, child: Text(type.label)),
            ],
            onChanged: (value) => setState(() => _type = value ?? _type),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _quantityController,
            label: 'Quantity',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            validator: Validators.positiveAmount,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _averagePriceController,
            label: 'Average buy price',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            validator: Validators.positiveAmount,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _currentPriceController,
            label: 'Current price',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            validator: Validators.positiveAmount,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _notesController,
            label: 'Notes',
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: _isFavorite,
            onChanged: (value) => setState(() => _isFavorite = value),
            title: const Text('Favorite'),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: widget.initialAsset == null ? 'Add asset' : 'Save changes',
            isLoading: widget.isLoading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await widget.onSubmit(
      PortfolioAssetInput(
        symbol: _symbolController.text,
        name: _nameController.text,
        type: _type,
        quantity: double.parse(_quantityController.text.trim()),
        averageBuyPrice: double.parse(_averagePriceController.text.trim()),
        currentPrice: double.parse(_currentPriceController.text.trim()),
        isFavorite: _isFavorite,
        notes:
            _notesController.text.trim().isEmpty ? null : _notesController.text,
      ),
    );
  }
}
