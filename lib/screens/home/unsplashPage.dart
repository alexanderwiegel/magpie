import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:http/http.dart' as http;
import 'package:magpie_app/SizeConfig.dart';
import 'package:magpie_app/constants.dart' as Constants;
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class UnsplashPage extends StatefulWidget {
  @override
  _UnsplashPageState createState() => _UnsplashPageState();
}

class _UnsplashPageState extends State<UnsplashPage> {
  Color textColor = Constants.COLOR3;
  Color bgColor = Constants.COLOR1;
  int count = SizeConfig.isTablet ? 5 : 2;
  double sizeAsDouble =
      SizeConfig.isTablet ? SizeConfig.vert * 28 : SizeConfig.hori * 46;
  int size;
  String query = "Nest";

  @override
  Widget build(BuildContext context) {
    size = sizeAsDouble.toInt();
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(text: "Fotos von ", style: TextStyle(fontSize: 18)),
              TextSpan(
                  text: "Unsplash",
                  style: TextStyle(
                      fontSize: 18, decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => _openInWebview(
                        "https://unsplash.com?utm_source=Magpie&utm_medium=referral"))
            ],
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: BottomAppBar(
          color: bgColor,
          child: TextField(
            textCapitalization: TextCapitalization.sentences,
            onChanged: (value) => setState(() => query = value),
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: "Fotos durchsuchen...",
              hintStyle: TextStyle(color: textColor, fontSize: 18),
              prefixIcon: Icon(Icons.search, color: Constants.COLOR3),
              //border: OutlineInputBorder(),
            ),
          ),
        ),
      ),
      body: FutureBuilder(
        future: getPics(),
        builder: (context, snapshot) {
          Map data = snapshot.data;
          if (snapshot.hasData) {
            return Center(
              child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: count),
                  itemCount: data["results"].length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: <Widget>[
                        Container(
                          padding:
                              EdgeInsets.symmetric(vertical: SizeConfig.vert),
                          child: InkWell(
                            onTap: () async =>
                                zoomInOnImage(data["results"][index]),
                            child: Image.network(
                              "${data["results"][index]["urls"]["raw"]}" +
                                  "&fit=crop&w=$size&h=$size",
                            ),
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

  Future _openInWebview(String url) async {
    if (await url_launcher.canLaunch(url)) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (ctx) => WebviewScaffold(
                initialChild: Center(child: CircularProgressIndicator()),
                url: url,
                appBar: AppBar(title: Text("Unsplash.com")),
              )));
    }
  }

  Future<void> zoomInOnImage(photoInformation) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))),
            backgroundColor: bgColor,
            contentPadding:
                EdgeInsets.only(bottom: SizeConfig.isTablet ? 40 : 0),
            content: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                title: Material(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(10),
                            bottom: Radius.circular(0))),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pop(
                              context, photoInformation["urls"]["raw"]);
                        },
                        child: SizeConfig.isTablet
                            ? Image.network(photoInformation["urls"]["raw"] +
                                "&fit=crop&h=${size * 3.5}")
                            : Image.network(
                                photoInformation["urls"]["small"]))),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                                text: "Foto von ",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: textColor,
                                    fontWeight: FontWeight.bold)),
                            TextSpan(
                                text: photoInformation["user"]["name"],
                                style: TextStyle(
                                    color: textColor,
                                    fontSize: 18,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.bold),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => _openInWebview(
                                      "https://unsplash.com/@${photoInformation["user"]["username"]}?utm_source=Magpie&utm_medium=referral"))
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          );
        });
  }

  Future<Map> getPics() async {
    String url =
        "https://api.unsplash.com/search/photos?query=$query&per_page=30&client_id=IdQYjoATojZnq4uJblpSYV7ryIrxdhfvPkjoI5wOENM";
    final response = await http.get(url);
    return response.statusCode == 200 ? json.decode(response.body) : null;
  }
}
