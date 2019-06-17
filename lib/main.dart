import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Map<String, List<String>> dictionary = {};

void main() async {
  var str = await rootBundle.loadString('assets/pinyin.json');
  jsonDecode(str).forEach((k, v) {
    dictionary[k] = List.from(v);
  });
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

      // rebuild history
      history = [];
      for (var line in lis) {
        List<Word> phrase = [];
        for (var word in line) {
          phrase.add(Word(word['text'], dictionary[word['text']]));
        }
        history.add(phrase);
      }
    } catch (e) {
      print("Couldn't read file $e");
    }
  }

  _save() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/history.json');
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

  delete(int i) {
    setState(() {
      history.removeAt(i);
      _save();
    });
  }

  Widget buildWords(BuildContext context, List<Word> words) {
    return Row(
      children: words.map((word) {
        return Container(
          padding: EdgeInsets.all(5.0),
          child: GestureDetector(
            child: Column(
              children: <Widget>[
                Text(word.pinyin, textAlign: TextAlign.left),
                Text(word.text, textAlign: TextAlign.left),
              ],
            ),
            onTap: () async {
              if (word.pinyins.length == 1) {
                final snackBar = SnackBar(
                  content: Text('${word.text} 并無其他拼音'),
                  duration: Duration(seconds: 1)
                );
                Scaffold.of(context).showSnackBar(snackBar);
              } else {
                int i = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return SimpleDialog(
                      title: Text('選擇拼音', textAlign: TextAlign.center),
                      children: List.generate(word.pinyins.length, (int i) {
                        var w = word.pinyins[i];
                        return SimpleDialogOption(
                          child: Text(w),
                          onPressed: () {
                            Navigator.pop(context, i);
                          },
                        );
                      })
                    );
                  }
                );
                setState(() {
                  word.index = i;
                  _save();
                });
              }
            }
          ));
      }).toList()
    );
  }

  Widget buildHistory(context) {
    List<Widget> children = [];
    for (var i = history.length - 1; i >= 0; i--) {
      var words = history[i];
      children.add(Row(
        children: [
          Expanded(child: buildWords(context, words)),
          FlatButton(child: Text('X'), onPressed: () => delete(i)),
        ]
      ));
    }
    return Column(children: children);
  }

  @override
  Widget build(BuildContext context) {
    for (var i = 0; i < history.length; i++) {

    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Builder(builder: (context) =>
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  children: [
                    Expanded(child: TextField(controller: controller)),
                    FlatButton(
                      child: Text('save'),
                      color: Colors.blue,
                      textColor: Colors.white,
                      onPressed: save,
                    )
                  ]
                )
              ),
              buildWords(context, words),
              Divider(),
              buildHistory(context),
            ],
          ),
        )
      ),
    );
  }
}
