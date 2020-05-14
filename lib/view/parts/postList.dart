import 'package:flutter/material.dart';
import 'package:lightpost/entity/post.dart';
import 'package:lightpost/entity/user.dart';
import 'package:lightpost/service/dbHelper.dart';
import 'package:lightpost/view/commentsPage.dart';
import 'package:lightpost/view/parts/postView.dart';
import 'package:sqflite/sqflite.dart';

class PostList extends StatefulWidget {

  @override
  _PostListState createState() => _PostListState();
}

class _PostListState extends State<PostList> {

  DatabaseHelper databaseHelper = DatabaseHelper();

  List<Post> _posts;
  List<User> _users;

  User userWithId (int id) => _users[id - 1];

  void updateViewList() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Post>> futurePosts = databaseHelper.getPostList();
      futurePosts.then((postList) {
        setState(() {
          this._posts = postList;
        });
      });
      Future<List<User>> futureUsers = databaseHelper.getUserList();
      futureUsers.then((userList) {
        setState(() {
          this._users = userList;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_posts == null || _users == null) {
      _users = List();
      _posts = List();
      updateViewList();
    }

    return ListView.builder(
      itemCount: _posts.length,
      padding: EdgeInsets.all(10),
      itemBuilder: (BuildContext context, int i) {
        return PostWidget(_posts[i], userWithId(_posts[i].userId));
      },
    );
  }
}

class PostWidget extends StatelessWidget {

  Post _post;
  User _user;

  PostWidget(this._post, this._user);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) {
          return CommentPage(_post, _user);
        }));
      },
      child: Card(
        elevation: 4,
        margin: EdgeInsets.all(8),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: PostView(_post, _user)
        ),
      ),
    );
  }
}

