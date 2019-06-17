import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Map<String, dynamic> dictionary;

void main() async {
  var str = await rootBundle.loadString('assets/pinyin.json');
  dictionary = jsonDecode(str);
  runApp(MyApp());
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
      home: MyHomePage(title: '拼音字典'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class Word {
  String text;
  List<String> pinyins;
  int index = 0;

  Word(this.text, this.pinyins);

  String get pinyin => pinyins[index];

  Map toJson() {
    Map map = new Map();
    map["text"] = text;
    map["index"] = index;
    return map;
  }
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController controller = TextEditingController();
  List<Word> words = [];
  List<List<Word>> history = [];

  _read() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/history.json');
      String text = await file.readAsString();
      var lis = jsonDecode(text);

      history = [];
      for (var line in lis) {
        var phrase = [];
        for (var word in line) {
          phrase.add(Word(word['text'], dictionary[word['text']]));
        }
        history.add(phrase);
      }
    } catch (e) {
      print("Couldn't read file");
    }
  }

  _save() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/history.json');
    final text = jsonEncode(history);
    print('saving');
    await file.writeAsString(text);
    print('saved');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    controller.addListener(() {
      this.setState(() {
        var cs = controller.text.split('');
        words = [];
        for (var c in cs) {
          if (dictionary.containsKey(c)) {
            List<String> t = [];
            for (var x in dictionary[c]) {
              t.add(x as String);
            }
            words.add(Word(c, t));
          }
        }
      });
    });

    // read history from file
    _read();
  }

  save() {
    setState(() {
      history.add(words);
      _save();
    });
  }

  Widget buildWords(BuildContext context, List<Word> words) {
    return Row(
      children: words.map((word) {
        return Container(
          padding: EdgeInsets.all(5.0),
          child: Column(
            children: <Widget>[
              Text(word.pinyin, textAlign: TextAlign.left),
              Text(word.text, textAlign: TextAlign.left),
            ],
          )
        );
      }).toList()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: [
                  Expanded(child: TextField(controller: controller)),
                  FlatButton(child: Text('save'),
                    color: Colors.blue,
                    textColor: Colors.white,
                    onPressed: save,
                  )
                ]
              )
            ),
            buildWords(context, words),
            Divider(),
            Column(
              children: history.reversed.map((words) {
                return Row(
                  children: [
                    Expanded(child: buildWords(context, words)),
                    FlatButton(child: Text('X')),
                  ]
                );
              }).toList(),
            )
          ],
        ),
      ),
    );
  }
}
