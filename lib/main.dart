import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

final apiKey = 'apiKeyを入れる';
//エンドポイントとは、連携したいAPIにアクセスするための接続先のこと。この接続先は、URI（URL）と呼ばれます。
final endpoint = 'URLを入れる';

//モデルクラス
class ListItem {
  final String title;
  final String content;
  final DateTime publishedAt;

//JsonからデータをMapに変換処理
  ListItem.fromJSON(Map<String, dynamic> json)
      : title = json['title'],
        content = json['content'],
        publishedAt = DateTime.parse(
          json['publishedAt'],
        );
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'blog',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //getリクエストでAPIからJsonデータ取得
  _loadListItem() async {
    final _listItems = <ListItem>[];
    //URLを使えるようにパースする
    var url = Uri.parse(endpoint);
    //getリクエストでとってきたデータを変数に代入
    final response =
        await http.get(url, headers: {"X-MICROCMS-API-KEY": apiKey});

    List contents = json.decode(response.body)['contents'];

    _listItems.clear();
    _listItems.addAll(contents.map((content) => ListItem.fromJSON(content)));
    return _listItems;
  }

  @override
  void initState() {
    _loadListItem();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('記事一覧'),
      ),
      body: FutureBuilder<dynamic>(
          future: _loadListItem(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  var data = snapshot.data[index];
                  return Card(
                    child: ListTile(
                      title: Text(data.title),
                      subtitle: Text(data.publishedAt.toIso8601String()),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BlogScreen(
                                  title: data.title, content: data.content)),
                        );
                      },
                    ),
                  );
                },
              );
            } else {
              return const CircularProgressIndicator();
            }
          }),
    );
  }
}

class BlogScreen extends StatefulWidget {
  final String title;
  final String content;
  const BlogScreen({super.key, required this.content, required this.title});

  @override
  State<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Text(widget.content));
  }
}
