import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/scheduler.dart';
//import 'package:appt/ChatMessage.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
     return new MaterialApp(
      title: 'Generated App',
      theme: new ThemeData(
        // primarySwatch: Colors.blue,
        // primaryColor: const Color(0xFF2196f3),
        // accentColor: const Color(0xFF2196f3),
        // canvasColor: const Color(0xFFfafafa),
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Chat Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  TextEditingController _chatTextController = new TextEditingController();
  TextEditingController _nameTextController = new TextEditingController();
  ScrollController _scrollController = new ScrollController();

  bool _hasText = false;

  String _name = '';

  void _handleChatSubmit(String text) {
    _chatTextController.clear();
    Firestore.instance.collection('chats').add({
      'name': _name,
      'message': text,
      'timestamp': new DateTime.now().millisecondsSinceEpoch
    });
  }

  Widget buildChatList() {
    return new Expanded(
        child: new StreamBuilder(
            stream: Firestore.instance.collection('chats').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Text('Loading...');
              return new ListView.builder(
                  controller: _scrollController,
                  itemCount: snapshot.data.documents.length,
                  padding: const EdgeInsets.only(top: 10.0),
                  itemBuilder: (context, index) {
                    SchedulerBinding.instance.addPostFrameCallback((duration) {
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    });
                    DocumentSnapshot ds = snapshot.data.documents[index];
                    print("documentChange received? ${ds['message']}");
                    return buildChatBubble(ds['name'], ds['message']);
                  });
            }));
  }

  Widget buildChatBar() {
    return new Container(
        padding: new EdgeInsets.all(15.0),
        color: Colors.white,
        child: new Row(
          children: <Widget>[
            new Expanded(
                child: new TextField(
              controller: _chatTextController,
              decoration:
                  new InputDecoration.collapsed(hintText: "Send a message"),
              onChanged: (text) {
                setState(() {
                  _hasText = text.length > 0;
                });
              },
            )),
            new IconButton(
              icon: new Icon(Icons.send),
              onPressed: _hasText
                  ? () {
                      _handleChatSubmit(_chatTextController.text);
                    }
                  : null,
            )
          ],
        ));
  }

  Widget buildChatBubble(String name, String message) {
    const whiteText = const TextStyle(color: Colors.white, fontSize: 15.0);

    return new Container(
      margin: new EdgeInsets.all(5.0),
      decoration: new BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: new BorderRadius.all(const Radius.circular(8.0))),
      padding: new EdgeInsets.all(10.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Text(
            "$name: ",
            style: whiteText,
          ),
          new Text(message, style: whiteText)
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    promptName();
  }

  promptName() async {
    String name = await showDialog(
        context: context,
        builder: (buildContext) {
          return new SimpleDialog(
              contentPadding: new EdgeInsets.all(10.0),
              title: const Text('Whats your name?'),
              children: <Widget>[
                new Column(children: <Widget>[
                  new TextField(
                    controller:_nameTextController,
                      decoration:
                          new InputDecoration.collapsed(hintText: "Name")),
                  new FlatButton(onPressed: () {
                    Navigator.pop(context, _nameTextController.text);
                  }, child: new Text('OK'))
                ])
              ]);
        });

    this._name = name;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(widget.title),
      ),
      body: new Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: new Column(
          // Column is also layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug paint" (press "p" in the console where you ran
          // "flutter run", or select "Toggle Debug Paint" from the Flutter tool
          // window in IntelliJ) to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[buildChatList(), buildChatBar()],
        ),
      ),
    );
}
}