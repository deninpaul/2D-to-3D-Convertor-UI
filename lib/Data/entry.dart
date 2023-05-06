class Entry {
  int? id;
  String name = "";
  String photo = "";

  Entry({
    int? id,
    String? name,
    String? photo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'photo': photo,
    };
  }

  Entry.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    photo = map['photo'];
  }
}
