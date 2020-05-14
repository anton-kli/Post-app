import 'package:flutter/material.dart';
import 'package:lightpost/entity/post.dart';
import 'package:lightpost/entity/user.dart';
import 'package:random_color/random_color.dart';

class PostView extends StatelessWidget {
  Post _post;
  User _user;

  PostView(this._post, this._user);

  Widget authRow(User user) {

    RandomColor _randomColor = RandomColor();
    Color avatarColor = _randomColor.randomColor();

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CircleAvatar(
          backgroundColor: avatarColor,
          radius: 18,
          child: Text(
            user.name.substring(0, 2),
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          width: 8,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              user.username,
            ),
            Text(
              user.email,
              style: TextStyle(
                color: Colors.black38,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        authRow(_user),
        SizedBox(
          height: 10,
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 5),
          child: Text(
            _post.title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
            _post.body
        ),
      ],
    );
  }
}
