class Banda {
  String id;
  String name;
  int votes;

  Banda({this.id, this.name, this.votes});

  factory Banda.fromMap(Map<String, dynamic> obj) =>
      Banda(id: obj['id'], name: obj['name'], votes: obj['votes']);
}
