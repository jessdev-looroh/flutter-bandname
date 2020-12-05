class Banda {
  String id;
  String name;
  int votes;

  Banda({this.id, this.name, this.votes});

  factory Banda.fromMap(Map<String, dynamic> obj) => Banda(
      id: obj.containsKey('id') ? obj['id'] : 'no-id',
      name: obj.containsKey("name") ? obj['name'] : 'no-name',
      votes: obj.containsKey("vote") ? obj['vote'] : 'no-votes');
}
