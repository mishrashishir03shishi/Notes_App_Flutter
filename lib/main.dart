import 'package:flutter/material.dart';
import 'package:flutter_app2/screens/notelist.dart';
import 'package:flutter_app2/screens/notedetail.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: NoteList(),
    );
    throw UnimplementedError();
  }
}