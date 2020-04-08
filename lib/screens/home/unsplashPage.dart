import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UnsplashPage extends StatefulWidget {
  @override
  _UnsplashPageState createState() => _UnsplashPageState();
}

class _UnsplashPageState extends State<UnsplashPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Unsplash"),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: getPics(),
        builder: (context, snapshot) {
          Map data = snapshot.data;
          if (snapshot.hasError) {
            print(snapshot.error);
            return Text("Failed");
          } else if (snapshot.hasData) {
            return Center(
              child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(5),
                        ),
                        Container(
                          child: InkWell(
                            onTap: () {},
                            child: Image.network(
                                "${data["results"][index]["urls"]["thumb"]}"),
                          ),
                        )
                      ],
                    );
                  }),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Future<Map> getPics() async {
    String url = "https://api.unsplash.com/search/photos?page=1&query=office>";
    final response = await http.get(url);
    return response.statusCode == 200 ? json.decode(response.body) : null;
  }
}
