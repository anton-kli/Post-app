import 'dart:convert';

import 'package:lightpost/entity/comments.dart';
import 'package:lightpost/entity/post.dart';
import 'package:lightpost/entity/user.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart';

class DatabaseHelper {

  // Singleton DatabaseHelper
  static DatabaseHelper _databaseHelper;

  // Singleton Database
  static Database _database;

  // Tables names
  String dbName = 'ligth_post_app.db';
  String postTable = 'Posts';
  String commentTable = 'Comments';
  String userTable = 'Users';

  // Columns Posts table
  String colPId = 'id';
  String colPUserId = 'userId';
  String colPTitle = 'title';
  String colPBody = 'body';

  // Columns Comments table
  String colCId = 'id';
  String colCPostId = 'postId';
  String colCName = 'name';
  String colCEmail = 'email';
  String colCBody = 'body';

  // Columns Users table
  String colUId = 'id';
  String colUName = 'name';
  String colUUsername = 'username';
  String colUEmail = 'email';

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {

    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + dbName;

    // Open/create the database at a given path
    var looksDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    return looksDatabase;
  }

  // Create tables in database
  void _createDb(Database db, int newVersion) async {
    await db.execute('CREATE TABLE $postTable('
        '$colPId INTEGER PRIMARY KEY, '
        '$colPUserId INTEGER, $colPTitle TEXT, $colPBody TEXT)'
    );

    await db.execute('CREATE TABLE $commentTable('
        '$colCId INTEGER PRIMARY KEY, '
        '$colCPostId INTEGER, $colCName TEXT, $colCEmail TEXT, $colCBody TEXT)'
    );

    await db.execute('CREATE TABLE $userTable('
        '$colUId INTEGER PRIMARY KEY, '
        '$colUUsername TEXT, $colUName TEXT, $colUEmail TEXT)'
    );
  }

  // Insert a Post object to database
  Future<int> insertPost(Post post) async {
    Database db = await this.database;
    var result = await db.insert(postTable, post.toMap());
    return result;
  }

  // Insert a Comment object to database
  Future<int> insertComment(Comment comment) async {
    Database db = await this.database;
    var result = await db.insert(commentTable, comment.toMap());
    return result;
  }

  // Insert a User object to database
  Future<int> insertUser(User user) async {
    Database db = await this.database;
    var result = await db.insert(userTable, user.toMap());
    return result;
  }

  // Update a Post object and save it to database
  Future<int> updatePost(Post post) async {
    var db = await this.database;
    var result = await db.update(postTable, post.toMap(), where: '$colPId = ?', whereArgs: [post.id]);
    return result;
  }

  // Update a Comment object and save it to database
  Future<int> updateComment(Comment comment) async {
    var db = await this.database;
    var result = await db.update(commentTable, comment.toMap(), where: '$colCId = ?', whereArgs: [comment.id]);
    return result;
  }

  // Update a User object and save it to database
  Future<int> updateUser(User user) async {
    var db = await this.database;
    var result = await db.update(userTable, user.toMap(), where: '$colUId = ?', whereArgs: [user.id]);
    return result;
  }

  // Delete a Post object from database
  Future<int> deletePost(int id) async {
    var db = await this.database;
    int result = await db.rawDelete('DELETE FROM $postTable WHERE $colPId = $id');
    return result;
  }

  // Delete a Comment object from database
  Future<int> deleteComment(int id) async {
    var db = await this.database;
    int result = await db.rawDelete('DELETE FROM $commentTable WHERE $colCId = $id');
    return result;
  }

  // Delete a User object from database
  Future<int> deleteUser(int id) async {
    var db = await this.database;
    int result = await db.rawDelete('DELETE FROM $userTable WHERE $colUId = $id');
    return result;
  }

  // Fetch Operation: Get all Post objects from database
  Future<List<Map<String, dynamic>>> getPostMapList() async {
    Database db = await this.database;
    var result = await db.query(postTable);
    return result;
  }

  // Get all Post objects from database as list
  Future<List<Post>> getPostList() async {
    var postMapList = await getPostMapList();
    int count = postMapList.length;

    if (postMapList == null || count == 0) {
      return uploadPosts();
    } else {
      List<Post> posts = List<Post>();
      for (int i = 0; i < count; i++) {
        posts.add(Post.fromJson(postMapList[i]));
      }

      return posts;
    }
  }

  // Fetch Operation: Get all Comment objects from database
  Future<List<Map<String, dynamic>>> getCommentMapList(int postId) async {
    Database db = await this.database;
    var result = await db.query(commentTable, where: '$colCPostId = ?', whereArgs: [postId]);
    return result;
  }

  // Get all Comment objects from database as list
  Future<List<Comment>> getCommentList(int postId) async {
    var commentMapList = await getCommentMapList(postId);
    int count = commentMapList.length;

    if (commentMapList == null || count == 0) {
      return uploadComments(postId);
    } else {
      List<Comment> comments = List();
      for (int i = 0; i < count; i++) {
        comments.add(Comment.fromJson(commentMapList[i]));
      }

      return comments;
    }
  }

  // Fetch Operation: Get all User objects from database
  Future<List<Map<String, dynamic>>> getUserMapList() async {
    Database db = await this.database;
    var result = await db.query(userTable);
    return result;
  }

  // Get all User objects from database as list
  Future<List<User>> getUserList() async {
    var userMapList = await getUserMapList();
    int count = userMapList.length;

    if (userMapList == null || count == 0) {
      return uploadUsers();
    } else {
      List<User> users = List();
      for (int i = 0; i < count; i++) {
        users.add(User.fromJson(userMapList[i]));
      }

      return users;
    }
  }

  // Loading and saving posts JSON object
  Future<List<Post>> uploadPosts() async {
    Client client = Client();
    final response = await client.get('https://jsonplaceholder.typicode.com/posts');
    final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
    List<Post> posts = parsed.map<Post>((json) => Post.fromJson(json)).toList();

    int count = posts.length;

    for (int i = 0; i < count; i++) {
      await insertPost(posts[i]);
    }
    return posts;
  }

  // Loading and saving comments JSON object
  Future<List<Comment>> uploadComments(int postId) async {
    Client client = Client();
    final response = await client.get('https://jsonplaceholder.typicode.com/comments?postId=$postId');
    final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
    List<Comment> comments = parsed.map<Comment>((json) => Comment.fromJson(json)).toList();

    int count = comments.length;

    for (int i = 0; i < count; i++) {
      await insertComment(comments[i]);
    }
    return comments;
  }

  // Loading and saving users JSON object
  Future<List<User>> uploadUsers() async {
    Client client = Client();
    final response = await client.get('https://jsonplaceholder.typicode.com/users');
    final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
    List<User> users = parsed.map<User>((json) => User.fromJson(json)).toList();

    int count = users.length;

    for (int i = 0; i < count; i++) {
      await insertUser(users[i]);
    }
    return users;
  }

}