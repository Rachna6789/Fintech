import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/portfolio_asset.dart';
import '../../domain/entities/portfolio_asset_input.dart';
import '../../domain/entities/portfolio_asset_type.dart';

class PortfolioAssetModel extends PortfolioAsset {
  const PortfolioAssetModel({
    required super.id,
    required super.symbol,
    required super.name,
    required super.type,
    required super.quantity,
    required super.averageBuyPrice,
    required super.currentPrice,
    required super.isFavorite,
    required super.createdAt,
    required super.updatedAt,
    super.notes,
  });

  factory PortfolioAssetModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};
    return PortfolioAssetModel(
      id: document.id,
      symbol: data['symbol'] as String? ?? '',
      name: data['name'] as String? ?? '',
      type: _type(data['type']),
      quantity: _double(data['quantity']),
      averageBuyPrice: _double(data['averageBuyPrice']),
      currentPrice: _double(data['currentPrice']),
      isFavorite: data['isFavorite'] as bool? ?? false,
      createdAt: _date(data['createdAt']),
      updatedAt: _date(data['updatedAt']),
      notes: data['notes'] as String?,
    );
  }

  factory PortfolioAssetModel.fromJson(Map<String, dynamic> json) {
    return PortfolioAssetModel(
      id: json['id'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: _type(json['type']),
      quantity: _double(json['quantity']),
      averageBuyPrice: _double(json['averageBuyPrice']),
      currentPrice: _double(json['currentPrice']),
      isFavorite: json['isFavorite'] as bool? ?? false,
      createdAt: _date(json['createdAt']),
      updatedAt: _date(json['updatedAt']),
      notes: json['notes'] as String?,
    );
  }

  factory PortfolioAssetModel.fromEntity(PortfolioAsset asset) {
    return PortfolioAssetModel(
      id: asset.id,
      symbol: asset.symbol,
      name: asset.name,
      type: asset.type,
      quantity: asset.quantity,
      averageBuyPrice: asset.averageBuyPrice,
      currentPrice: asset.currentPrice,
      isFavorite: asset.isFavorite,
      createdAt: asset.createdAt,
      updatedAt: asset.updatedAt,
      notes: asset.notes,
    );
  }

  factory PortfolioAssetModel.fromInput({
    required String id,
    required PortfolioAssetInput input,
  }) {
    final now = DateTime.now();
    return PortfolioAssetModel(
      id: id,
      symbol: input.symbol.trim().toUpperCase(),
      name: input.name.trim(),
      type: input.type,
      quantity: input.quantity,
      averageBuyPrice: input.averageBuyPrice,
      currentPrice: input.currentPrice,
      isFavorite: input.isFavorite,
      createdAt: now,
      updatedAt: now,
      notes: input.notes?.trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'name': name,
      'type': type.name,
      'quantity': quantity,
      'averageBuyPrice': averageBuyPrice,
      'currentPrice': currentPrice,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'notes': notes,
    };
  }

  static Map<String, dynamic> inputToJson(PortfolioAssetInput input) {
    return {
      'symbol': input.symbol.trim().toUpperCase(),
      'name': input.name.trim(),
      'type': input.type.name,
      'quantity': input.quantity,
      'averageBuyPrice': input.averageBuyPrice,
      'currentPrice': input.currentPrice,
      'isFavorite': input.isFavorite,
      'notes': input.notes?.trim(),
    };
  }

  static Map<String, dynamic> createJson(PortfolioAssetInput input) {
    return {
      ..._inputJson(input),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static Map<String, dynamic> updateJson(PortfolioAssetInput input) {
    return {
      ..._inputJson(input),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static Map<String, dynamic> _inputJson(PortfolioAssetInput input) {
    return {
      'symbol': input.symbol.trim().toUpperCase(),
      'name': input.name.trim(),
      'type': input.type.name,
      'quantity': input.quantity,
      'averageBuyPrice': input.averageBuyPrice,
      'currentPrice': input.currentPrice,
      'isFavorite': input.isFavorite,
      'notes': input.notes?.trim(),
    };
  }

  static PortfolioAssetType _type(Object? value) {
    final name = value as String?;
    return PortfolioAssetType.values.firstWhere(
      (type) => type.name == name,
      orElse: () => PortfolioAssetType.other,
    );
  }

  static double _double(Object? value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime _date(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
