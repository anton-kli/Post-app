import 'package:flutter/material.dart';
import 'package:lightpost/view/parts/postList.dart';


class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ligth Post'),
        centerTitle: true,
      ),
      body: PostList(),
    );
  }
}
