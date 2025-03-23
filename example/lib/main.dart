import 'package:flutter/material.dart';
import 'package:dartimg/dartimg.dart' as dartimg;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Dart Image Example'),
        ),
        body: Center(
          child: Text('Sum of 2 and 3 is: ${dartimg.sum(2, 3)}'),
        ),
      ),
    );
  }
}
