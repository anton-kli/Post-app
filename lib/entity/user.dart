class User {
  int id;
  String name;
  String username;
  String email;

  User({this.id, this.name, this.username, this.email});

  //Convert User to Post obj
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
    );
  }

  //Convert User obj to map
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['id'] = id;
    map['name'] = name;
    map['username'] = username;
    map['email'] = email;
    return map;
  }
}