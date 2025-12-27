/// ページエンティティ
///
/// メモページの情報を表すエンティティです。
class PageEntity {
  /// ページID
  final String id;

  /// ページ名
  final String name;

  /// 表示順序
  final int order;

  /// コンストラクタ
  const PageEntity({required this.id, required this.name, required this.order});

  /// JSONからエンティティを作成
  factory PageEntity.fromJson(Map<String, dynamic> json) {
    return PageEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      order: json['order'] as int,
    );
  }

  /// エンティティをJSONに変換
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'order': order};
  }

  /// コピーを作成
  PageEntity copyWith({String? id, String? name, int? order}) {
    return PageEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      order: order ?? this.order,
    );
  }
}
