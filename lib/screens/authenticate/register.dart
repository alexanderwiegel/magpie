import 'package:flutter/material.dart';
import 'package:magpie_app/services/auth.dart';

class Register extends StatefulWidget {
  final Function toggleView;

  Register(this.toggleView);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String email = "";
  String password = "";
  String error = "";

  @override
  Widget build(BuildContext context) {
    return loading
        ? Container(
            color: Colors.teal,
            child: Center(
                child: CircularProgressIndicator(
              backgroundColor: Colors.white,
            )))
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.teal,
              elevation: 0.0,
              title: Text("Registrierung"),
              actions: <Widget>[
                FlatButton.icon(
                    onPressed: () => widget.toggleView(),
                    icon: Icon(Icons.person),
                    label: Text("Login"))
              ],
            ),
            body: Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 20.0,
                    ),
                    TextFormField(
                      validator: (val) =>
                          val.isEmpty ? "Bitte gib eine Emailadresse an" : null,
                      onChanged: (val) {
                        setState(() => email = val);
                      },
                    ),
                    TextFormField(
                      validator: (val) => val.length < 6
                          ? "Dein Password muss mindestens sechs Zeichen lang sein"
                          : null,
                      onChanged: (val) => password = val,
                      obscureText: true,
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    RaisedButton(
                      color: Colors.amber,
                      child: Text(
                        "Registrieren",
                        style: TextStyle(color: Colors.teal),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          setState(() => loading = true);
                          dynamic result = await _auth
                              .registerWithEmailAndPassword(email, password);
                          if (result == null)
                            setState(() {
                              error = "Bitte gib eine gültige Emailadresse an.";
                              loading = false;
                            });
                        }
                      },
                    ),
                    SizedBox(
                      height: 12.0,
                    ),
                    Text(
                      error,
                      style: TextStyle(color: Colors.red, fontSize: 14.0),
                    )
                  ],
                ),
              ),
            ),
          );
  }
}
