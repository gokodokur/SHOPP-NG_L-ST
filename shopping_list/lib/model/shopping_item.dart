class ShoppingItem {
  int? id;
  int listId; // Hangi listeye ait olduğunu gösterir
  String title;
  bool isDone;

  ShoppingItem({this.id, required this.listId, required this.title, this.isDone = false});

  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      id: map['id'],
      listId: map['listId'],
      title: map['title'],
      isDone: map['isDone'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'listId': listId,
      'title': title,
      'isDone': isDone ? 1 : 0,
    };
  }
}
