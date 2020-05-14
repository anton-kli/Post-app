import 'package:flutter/material.dart';
import 'package:lightpost/entity/comments.dart';
import 'package:lightpost/entity/post.dart';
import 'package:lightpost/entity/user.dart';
import 'package:lightpost/service/dbHelper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:lightpost/view/parts/postView.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class CommentPage extends StatefulWidget {

  Post _post;
  User _user;

  CommentPage(this._post, this._user);

  @override
  _CommentPageState createState() => _CommentPageState(_post, _user);
}

class _CommentPageState extends State<CommentPage> {

  Post post;
  User user;
  List<Comment> comments;

  _CommentPageState(this.post, this.user);

  DatabaseHelper databaseHelper = DatabaseHelper();

  void updateViewList() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Comment>> futurePosts = databaseHelper.getCommentList(post.id);
      futurePosts.then((commentList) {
        setState(() {
          this.comments = commentList;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (comments == null) {
      comments = List();
      updateViewList();
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('Ligth Post'),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[100], Colors.blue[50]],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: PostView(post, user),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 12,
            ),
          ),
          SliverStaggeredGrid.countBuilder(
            crossAxisCount: 1,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
            itemCount: comments.length,
            itemBuilder: (context, index) {
              return CommentWidget(comments[index]);
            },
          ),
        ],
      ),
    );
  }
}

class CommentWidget extends StatelessWidget {

  Comment _comment;

  CommentWidget(this._comment);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Card(
        elevation: 4,
        child: Container(
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _comment.name,
              ),
              Text(
                _comment.email,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.black38,
                ),
              ),
              Center(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  height: 1,
                  color: Colors.blue[100],
                ),
              ),
              Text(
                _comment.body,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
