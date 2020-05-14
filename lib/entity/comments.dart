class Comment {
  int id;
  int postId;
  String name;
  String email;
  String body;

  Comment({this.id, this.postId, this.name, this.email, this.body});

  //Convert json to Comment obj
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int,
      postId: json['postId'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      body: json['body'] as String,
    );
  }

  //Convert Comment obj to map
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['id'] = id;
    map['postId'] = postId;
    map['name'] = name;
    map['email'] = email;
    map['body'] = body;
    return map;
  }
}