// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ShoppingList {
  int? id;
  String name;
  String uniqueCode; // Listeye özel benzersiz string kod
  List<int> userIdList;

  ShoppingList({
    this.id,
    required this.name,
    required this.uniqueCode,
    required this.userIdList,
  });

  factory ShoppingList.fromMap(Map<String, dynamic> map) {
    return ShoppingList(
      id: map['id'] != null ? map['id'] as int : null,
      name: map['name'] as String,
      uniqueCode: map['uniqueCode'] as String,
      userIdList: (map['userIdList'] as String)
          .split(",")
          .map((e) => int.parse(e))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'uniqueCode': uniqueCode,
      'userIdList': userIdList.join(","),
    };
  }

  ShoppingList copyWith({
    int? id,
    String? name,
    String? uniqueCode,
    List<int>? userIdList,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      name: name ?? this.name,
      uniqueCode: uniqueCode ?? this.uniqueCode,
      userIdList: userIdList ?? this.userIdList,
    );
  }

  String toJson() => json.encode(toMap());

  factory ShoppingList.fromJson(String source) =>
      ShoppingList.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ShoppingList(id: $id, name: $name, uniqueCode: $uniqueCode, userIdList: $userIdList)';
  }

  @override
  bool operator ==(covariant ShoppingList other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.uniqueCode == uniqueCode &&
        other.userIdList == userIdList;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        uniqueCode.hashCode ^
        userIdList.hashCode;
  }
}
