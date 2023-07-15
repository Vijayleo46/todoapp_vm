import 'package:flutter/material.dart';
import 'package:todoapp_vm/TodoApp.dart';
main()
{
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.red,
            backgroundColor: Colors.lightBlueAccent
      ),
      home:TodoApp(),
    );
  }
}

