class RecentHistory {
  final int? id;
  final int itemId;
  final String type;
  final DateTime openedAt;

  RecentHistory({
    this.id,
    required this.itemId,
    required this.type,
    required this.openedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemId': itemId,
      'type': type,
      'openedAt': openedAt.toIso8601String(),
    };
  }

  factory RecentHistory.fromMap(
    Map<String, dynamic> map,
  ) {
    return RecentHistory(
      id: map['id'],
      itemId: map['itemId'],
      type: map['type'],
      openedAt: DateTime.parse(
        map['openedAt'],
      ),
    );
  }
}