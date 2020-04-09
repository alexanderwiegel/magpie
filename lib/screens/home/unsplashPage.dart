import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class UnsplashPage extends StatefulWidget {
  @override
  _UnsplashPageState createState() => _UnsplashPageState();
}

class _UnsplashPageState extends State<UnsplashPage> {
  String query = "Nest";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(children: [
            TextSpan(text: "Fotos von ", style: TextStyle(fontSize: 18)),
            TextSpan(
              text: "Unsplash",
              style: TextStyle(fontSize: 18, decoration: TextDecoration.underline),
              recognizer: TapGestureRecognizer()..onTap = () async => await launch("https://unsplash.com")
            )
          ],),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: BottomAppBar(
          color: Colors.teal,
          child: TextField(
            textCapitalization: TextCapitalization.sentences,
            onChanged: (value) => setState(() => query = value),
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Fotos durchsuchen...",
              hintStyle: TextStyle(color: Colors.white, fontSize: 18),
              prefixIcon: Icon(Icons.search, color: Colors.amber,),
              //border: OutlineInputBorder(),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4),
        child: FutureBuilder(
              future: getPics(),
              builder: (context, snapshot) {
                Map data = snapshot.data;
                if (snapshot.hasData) {
                  return Center(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                        itemCount: data["results"].length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: InkWell(
                                  onTap: () => Navigator.pop(context, "${data["results"][index]["urls"]["raw"]}"),
                                  child: Image.network(
                                      "${data["results"][index]["urls"]["raw"]}" + "&fit=crop&w=168&h=168"),
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
      ),
    );
  }

  Future<Map> getPics() async {
    String url = "https://api.unsplash.com/search/photos?query=$query&client_id=IdQYjoATojZnq4uJblpSYV7ryIrxdhfvPkjoI5wOENM";
    final response = await http.get(url);
    return response.statusCode == 200 ? json.decode(response.body) : null;
  }
}
