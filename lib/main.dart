// http://192.168.1.212:8080/
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

//Định nghĩa hàm lấy dữ liệu về nhớ sử dụng async await
Future<List<Animal>> fetchAlbum() async {
  /*
  Chú ý nếu dựng REST API ở localhost thì đừng gõ URL là localhost vì Emulator
  */
  final response = await http.get('http://192.168.1.212:8080/');

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    var animalsJson = jsonDecode(response.body) as List;
    List<Animal> animals =
        animalsJson.map((itemJson) => Animal.fromJson(itemJson)).toList();

    return animals;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

// Định nghĩa lớp Album để hứng dữ liệu trả về
class Animal {
  final int id;
  final String title;
  final String desc;
  final String imgUrl;

  Animal({this.id, this.title, this.desc, this.imgUrl});

  /*
  factory là một keyword trong Dart, nó không hẳn là constructor nhưng nó cũng tạo 
  ra đối tượng từ tham số truyền vào
  */
  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: json['id'],
      title: json['title'],
      desc: json['desc'],
      imgUrl: json['img'],
    );
  }

  @override
  String toString() {
    return '{ ${this.id}, ${this.title}, ${this.desc}, ${this.imgUrl} }';
  }
}

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<List<Animal>> futureAlbums;
  @override
  void initState() {
    futureAlbums = fetchAlbum();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('GET LIST ANIMAL EXAMPLE'),
        ),
        body: Center(
            child: FutureBuilder<List<Animal>>(
          future:
              futureAlbums, //Truyền kết quả trả về của Album trong tương lai vào đây
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Animal> albums = snapshot.data;
              return ListView.builder(
                itemCount: albums.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                    backgroundImage: NetworkImage(albums[index].imgUrl),
                      ),
                    title: Text(albums[index].title),
                    subtitle: Text(albums[index].desc),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }

            // By default, show a loading spinner.
            return CircularProgressIndicator();
          },
        )),
      ),
    );
  }
}