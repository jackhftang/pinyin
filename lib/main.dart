import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import './screen/home_screen.dart';
import './widget/dictionary_widget.dart';

void main() async {
  var str = await rootBundle.loadString('assets/pinyin.json');
  Map<String, List<String>> dictionary = {};
  jsonDecode(str).forEach((k, v) {
    dictionary[k] = List.from(v);
  });
  runApp(Dictionary(
    dictionary: dictionary,
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '拼音字典',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(body: HomeScreen(title: '拼音字典')),
    );
  }
}
