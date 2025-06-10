class User {
  int? id;
  String username;
  String password;

  User({this.id, required this.username, required this.password});

  Map<String, dynamic> toMap() => {
    'id': id,
    'username': username,
    'password': password,
  };

  factory User.fromMap(Map<String, dynamic> map) =>
      User(id: map['id'], username: map['username'], password: map['password']);
}
