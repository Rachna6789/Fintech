class OfflineAction {
  const OfflineAction({
    required this.action,
    required this.entity,
    required this.payload,
    required this.createdAt,
  });

  final String action;
  final String entity;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'entity': entity,
      'payload': payload,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory OfflineAction.fromJson(Map<String, dynamic> json) {
    final payload = json['payload'];
    return OfflineAction(
      action: json['action'] as String? ?? '',
      entity: json['entity'] as String? ?? '',
      payload: payload is Map
          ? Map<String, dynamic>.from(payload)
          : const <String, dynamic>{},
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class OfflineEntities {
  const OfflineEntities._();

  static const portfolio = 'portfolio';
  static const settings = 'settings';
}

class OfflineActions {
  const OfflineActions._();

  static const add = 'add';
  static const update = 'update';
  static const delete = 'delete';
  static const toggleFavorite = 'toggle_favorite';
  static const patch = 'patch';
}
