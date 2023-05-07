class Entry {
  int? id;
  String name = "";
  String photo = "";
  String no_bg = "";
  String model = "";

  Entry({
    int? id,
    String? name,
    String? photo,
    String? no_bg,
    String? model,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'photo': photo,
      'no_bg': no_bg,
      'model': model,
    };
  }

  Entry.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    photo = map['photo'];
    no_bg = map['no_bg'];
    model = map['model'];
  }
}
