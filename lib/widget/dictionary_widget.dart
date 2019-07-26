import 'package:flutter/material.dart';

class Dictionary extends StatelessWidget {
  final Widget child;
  final Map<String, List<String>> dictionary;

  Dictionary({@required this.dictionary, @required this.child});

  static of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(InheritedDictionary) as InheritedDictionary).dictionary;
  }

  @override
  Widget build(BuildContext context) {
    return InheritedDictionary(
      dictionary: this.dictionary,
      child: this.child,
    );
  }
}

class InheritedDictionary extends InheritedWidget {
  final Map<String, List<String>> dictionary;

  InheritedDictionary({
    Key key,
    @required this.dictionary,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;
}
