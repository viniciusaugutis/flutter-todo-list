import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/models/item.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  var items = new List<Item>();
  HomePage() {
    items = [];
    /*items.add(Item(title: "Item 1", done: false));
    items.add(Item(title: "Item 2", done: true));
    items.add(Item(title: "Item 3", done: true));*/
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  _HomePageState() {
    load();
  }
  var newTaskCtrl = TextEditingController();

  void add() {
    if (newTaskCtrl.text.isEmpty) return;
    setState(() {
      widget.items.add(Item(title: newTaskCtrl.text, done: false));
      newTaskCtrl.text = ""; //ou newTaskCtrl.clear();
      save();
    });
  }

  void remove(index) {
    setState(() {
      widget.items.removeAt(index);
      save();
    });
  }

  Future load() async {
    var prefs = await SharedPreferences.getInstance();
    var data = prefs.getString('data');
    print(data);
    if (data != null) {
      Iterable decoded = jsonDecode(data);
      List<Item> result = decoded.map((x) => Item.fromJson(x)).toList();
      setState(() {
        widget.items = result;
      });
    }
  }

  save() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('data', jsonEncode(widget.items));
  }

  @override
  Widget build(BuildContext context) {
    newTaskCtrl.clear();
    return Scaffold(
      appBar: AppBar(
          //leading: Text("Oi"),
          title: TextFormField(
        controller: newTaskCtrl,
        keyboardType: TextInputType.text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
        decoration: InputDecoration(
            labelText: "Nova tarefa",
            labelStyle: TextStyle(color: Colors.white)),
      )),
      //actions: <Widget>[Icon(Icons.plus_one)]),
      body: ListView.builder(
          itemCount: widget.items.length,
          itemBuilder: (BuildContext context, int index) {
            final item = widget.items[index];
            return Dismissible(
              child: CheckboxListTile(
                  title: Text(item.title),
                  value: item.done,
                  onChanged: (value) {
                    setState(() {
                      item.done = value;
                      save();
                    });
                  }),
              key: Key(item.title),
              background: Container(
                color: Colors.red.withOpacity(0.2),
              ),
              onDismissed: (direction) {
                if (direction == DismissDirection.startToEnd) {}
                remove(index);
              },
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: add,
        child: Icon(Icons.add),
        backgroundColor: Colors.pink,
      ),
    );
  }
}
