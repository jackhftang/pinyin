import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../widget/dictionary_widget.dart';

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

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  TextEditingController controller = TextEditingController();
  List<Word> words = [];
  List<List<Word>> history = [];

  _read() async {
    var dictionary = Dictionary.of(context);
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

    var dictionary = Dictionary.of(context);
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
    _read().then((_) {
      setState(() {});
    });
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
                  final snackBar = SnackBar(content: Text('${word.text} 并無其他拼音'), duration: Duration(seconds: 1));
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
                            }));
                      });
                  setState(() {
                    word.index = i;
                    _save();
                  });
                }
              }));
    }).toList());
  }

  Widget buildHistory(context) {
    List<Widget> children = [];
    for (var i = history.length - 1; i >= 0; i--) {
      var words = history[i];
      children.add(Row(children: [
        Expanded(child: buildWords(context, words)),
        GestureDetector(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 5.0),
            child: Icon(Icons.delete, size: 16.0),
          ),
          onTap: () => delete(i),
        ),
      ]));
    }
    return ListView(
      padding: EdgeInsets.all(5.0),
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(children: [
                Expanded(child: TextField(controller: controller)),
                FlatButton(
                  child: Text('save'),
                  color: Colors.blue,
                  textColor: Colors.white,
                  onPressed: save,
                )
              ])),
          buildWords(context, words),
          Divider(),
          Expanded(child: buildHistory(context)),
        ],
      ),
    );
  }
}
