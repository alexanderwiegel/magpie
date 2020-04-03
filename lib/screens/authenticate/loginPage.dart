import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:magpie_app/services/auth.dart';

import 'bubble_indication_painter.dart';
import 'theme.dart' as Theme;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final AuthService _auth = AuthService();
  final _signUpKey = GlobalKey<FormState>();
  final _signInKey = GlobalKey<FormState>();
  bool loading = false;
  int addedHeightSignIn = 0;
  int addedHeightSignUp = 0;

  final FocusNode myFocusNodeEmailLogin = FocusNode();
  final FocusNode myFocusNodePasswordLogin = FocusNode();

  final FocusNode myFocusNodePassword = FocusNode();
  final FocusNode myFocusNodeEmail = FocusNode();
  final FocusNode myFocusNodeName = FocusNode();

  TextEditingController loginEmailController = TextEditingController();
  TextEditingController loginPasswordController = TextEditingController();

  bool _obscureTextLogin = true;
  bool _obscureTextSignUp = true;
  bool _obscureTextSignUpConfirm = true;

  TextEditingController signUpEmailController = TextEditingController();
  TextEditingController signUpNameController = TextEditingController();
  TextEditingController signUpPasswordController = TextEditingController();
  TextEditingController signUpConfirmPasswordController =
      TextEditingController();

  PageController _pageController;

  Color left = Colors.black;
  Color right = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowGlow();
        },
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height >= 775.0
                ? MediaQuery.of(context).size.height
                : 775.0,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Theme.Colors.loginGradientStart,
                    Theme.Colors.loginGradientEnd
                  ],
                  begin: const FractionalOffset(0.0, 0.0),
                  end: const FractionalOffset(1.0, 1.0),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp),
            ),
            child: loading
                ? Container(
                    color: Colors.teal,
                    child: Center(
                        child: CircularProgressIndicator(
                      backgroundColor: Colors.white,
                    )))
                : Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 75.0),
                        child: Image.asset(
                          "pics/logo.png",
                          width: 100.0,
                          height: 100.0,
                          fit: BoxFit.fill,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20.0),
                        child: _buildMenuBar(context),
                      ),
                      Expanded(
                        flex: 2,
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (i) {
                            if (i == 0) {
                              setState(() {
                                right = Colors.white;
                                left = Colors.black;
                              });
                            } else if (i == 1) {
                              setState(() {
                                right = Colors.black;
                                left = Colors.white;
                              });
                            }
                          },
                          children: <Widget>[
                            ConstrainedBox(
                              constraints: const BoxConstraints.expand(),
                              child: _buildSignIn(context),
                            ),
                            ConstrainedBox(
                              constraints: const BoxConstraints.expand(),
                              child: _buildSignUp(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    myFocusNodePassword.dispose();
    myFocusNodeEmail.dispose();
    myFocusNodeName.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _pageController = PageController();
  }

  void showInSnackBar(String value) {
    FocusScope.of(context).requestFocus(FocusNode());
    _scaffoldKey.currentState?.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0,
          //fontFamily: "WorkSansSemiBold"
        ),
      ),
      backgroundColor: Colors.teal,
      duration: Duration(seconds: 3),
    ));
  }

  Widget _buildMenuBar(BuildContext context) {
    return Container(
      width: 300.0,
      height: 50.0,
      decoration: BoxDecoration(
        color: Color(0x552B2B2B),
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
      ),
      child: CustomPaint(
        painter: TabIndicationPainter(pageController: _pageController),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: _onSignInButtonPress,
                child: Text(
                  "Einloggen",
                  style: TextStyle(
                    color: left,
                    fontSize: 16.0,
                    //fontFamily: "WorkSansSemiBold"
                  ),
                ),
              ),
            ),
            //Container(height: 33.0, width: 1.0, color: Colors.white),
            Expanded(
              child: FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: _onSignUpButtonPress,
                child: Text(
                  "Registrieren",
                  style: TextStyle(
                    color: right,
                    fontSize: 16.0,
                    //fontFamily: "WorkSansSemiBold"
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignIn(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 23.0),
      child: Form(
        key: _signInKey,
        child: Column(
          children: <Widget>[
            Stack(
              alignment: Alignment.topCenter,
              overflow: Overflow.visible,
              children: <Widget>[
                Card(
                  elevation: 2.0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Container(
                    width: 300.0,
                    height: 195.0 + addedHeightSignIn * 1.2,
                    // TODO: hier
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                              top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                          child: TextFormField(
                            validator: (val) => val.isEmpty
                                ? "Bitte gib eine Emailadresse an"
                                : null,
                            focusNode: myFocusNodeEmailLogin,
                            controller: loginEmailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(
                                //fontFamily: "WorkSansSemiBold",
                                fontSize: 16.0,
                                color: Colors.black),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              icon: Icon(
                                Icons.mail,
                                color: Colors.black,
                                size: 22.0,
                              ),
                              hintText: "Emailadresse",
                              hintStyle: TextStyle(
                                  //fontFamily: "WorkSansSemiBold",
                                  fontSize: 17.0),
                            ),
                          ),
                        ),
                        Container(
                          width: 250.0,
                          height: 1.0,
                          color: Colors.grey[400],
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                          child: TextFormField(
                            validator: (val) {
                              if (val.length < 6) {
                                setState(() => addedHeightSignIn = 30);
                                return "Passwort muss min. 6 Zeichen haben";
                              } else
                                return null;
                            },
                            focusNode: myFocusNodePasswordLogin,
                            controller: loginPasswordController,
                            obscureText: _obscureTextLogin,
                            style: TextStyle(
                                //fontFamily: "WorkSansSemiBold",
                                fontSize: 16.0,
                                color: Colors.black),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              icon: Icon(
                                FontAwesomeIcons.lock,
                                size: 22.0,
                                color: Colors.black,
                              ),
                              hintText: "Passwort",
                              hintStyle: TextStyle(
                                  //fontFamily: "WorkSansSemiBold",
                                  fontSize: 17.0),
                              suffixIcon: GestureDetector(
                                onTap: _toggleLogin,
                                child: Icon(
                                  _obscureTextLogin
                                      ? FontAwesomeIcons.eye
                                      : FontAwesomeIcons.eyeSlash,
                                  size: 15.0,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  // TODO: hier
                  margin: EdgeInsets.only(top: 175.0 + addedHeightSignIn * 1.2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Theme.Colors.loginGradientStart,
                        offset: Offset(1.0, 6.0),
                        blurRadius: 20.0,
                      ),
                      BoxShadow(
                        color: Theme.Colors.loginGradientEnd,
                        offset: Offset(1.0, 6.0),
                        blurRadius: 20.0,
                      ),
                    ],
                    gradient: LinearGradient(
                        colors: [
                          Theme.Colors.loginGradientEnd,
                          Theme.Colors.loginGradientStart
                        ],
                        begin: const FractionalOffset(0.2, 0.2),
                        end: const FractionalOffset(1.0, 1.0),
                        stops: [0.0, 1.0],
                        tileMode: TileMode.clamp),
                  ),
                  child: MaterialButton(
                      highlightColor: Colors.transparent,
                      splashColor: Theme.Colors.loginGradientEnd,
                      //shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 42.0),
                        child: Text(
                          "LOGIN",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25.0,
                            //fontFamily: "WorkSansBold"
                          ),
                        ),
                      ),
                      onPressed: () async {
                        if (_signInKey.currentState.validate()) {
                          setState(() => loading = true);
                          dynamic result =
                              await _auth.signInWithEmailAndPassword(
                                  loginEmailController.text,
                                  loginPasswordController.text);
                          if (result == null) {
                            setState(() {                              loading = false;
                            });
                            showInSnackBar("Email oder Passwort ungültig");
                          }
                        }
                      }),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: FlatButton(
                  onPressed: () {},
                  child: Text(
                    "Passwort vergessen?",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.white,
                      fontSize: 16.0,
                      //fontFamily: "WorkSansMedium"
                    ),
                  )),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [
                            Colors.white10,
                            Colors.white,
                          ],
                          begin: const FractionalOffset(0.0, 0.0),
                          end: const FractionalOffset(1.0, 1.0),
                          stops: [0.0, 1.0],
                          tileMode: TileMode.clamp),
                    ),
                    width: 100.0,
                    height: 1.0,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15.0, right: 15.0),
                    child: Text(
                      "oder",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        //fontFamily: "WorkSansMedium"
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [
                            Colors.white,
                            Colors.white10,
                          ],
                          begin: const FractionalOffset(0.0, 0.0),
                          end: const FractionalOffset(1.0, 1.0),
                          stops: [0.0, 1.0],
                          tileMode: TileMode.clamp),
                    ),
                    width: 100.0,
                    height: 1.0,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 10.0, right: 40.0),
                  child: GestureDetector(
                    onTap: () => showInSnackBar("Facebook button pressed"),
                    child: Container(
                      padding: const EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Icon(
                        FontAwesomeIcons.facebookF,
                        color: Color(0xFF0084ff),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: GestureDetector(
                    onTap: () => showInSnackBar("Google button pressed"),
                    child: Container(
                      padding: const EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Icon(
                        FontAwesomeIcons.google,
                        color: Color(0xFF0084ff),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUp(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 23.0),
      child: Form(
        key: _signUpKey,
        child: Column(
          children: <Widget>[
            Stack(
              alignment: Alignment.topCenter,
              overflow: Overflow.visible,
              children: <Widget>[
                Card(
                  elevation: 2.0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Container(
                    width: 300.0,
                    // TODO: hier
                    height: 360.0 + addedHeightSignUp * 3.2,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                              top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                          child: TextFormField(
                            validator: (val) => val.isEmpty
                                ? "Bitte gib einen Benutzernamen an"
                                : null,
                            focusNode: myFocusNodeName,
                            controller: signUpNameController,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.words,
                            style: TextStyle(
                                //fontFamily: "WorkSansSemiBold",
                                fontSize: 16.0,
                                color: Colors.black),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              icon: Icon(
                                FontAwesomeIcons.user,
                                color: Colors.black,
                              ),
                              hintText: "Benutzername",
                              hintStyle: TextStyle(
                                  //fontFamily: "WorkSansSemiBold",
                                  fontSize: 16.0),
                            ),
                          ),
                        ),
                        Container(
                          width: 250.0,
                          height: 1.0,
                          color: Colors.grey[400],
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                          child: TextFormField(
                            validator: (val) => val.isEmpty
                                ? "Bitte gib eine Emailadresse an"
                                : null,
                            focusNode: myFocusNodeEmail,
                            controller: signUpEmailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(
                                //fontFamily: "WorkSansSemiBold",
                                fontSize: 16.0,
                                color: Colors.black),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              icon: Icon(
                                FontAwesomeIcons.envelope,
                                color: Colors.black,
                              ),
                              hintText: "Emailadresse",
                              hintStyle: TextStyle(
                                  //fontFamily: "WorkSansSemiBold",
                                  fontSize: 16.0),
                            ),
                          ),
                        ),
                        Container(
                          width: 250.0,
                          height: 1.0,
                          color: Colors.grey[400],
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                          child: TextFormField(
                            validator: (val) {
                              if (val.length < 6) {
                                setState(() => addedHeightSignUp = 20);
                                return "Passwort muss min. 6 Zeichen haben";
                              } else
                                return null;
                            },
                            focusNode: myFocusNodePassword,
                            controller: signUpPasswordController,
                            obscureText: _obscureTextSignUp,
                            style: TextStyle(
                                //fontFamily: "WorkSansSemiBold",
                                fontSize: 16.0,
                                color: Colors.black),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              icon: Icon(
                                FontAwesomeIcons.lock,
                                color: Colors.black,
                              ),
                              hintText: "Passwort",
                              hintStyle: TextStyle(
                                  //fontFamily: "WorkSansSemiBold",
                                  fontSize: 16.0),
                              suffixIcon: GestureDetector(
                                onTap: _toggleSignUp,
                                child: Icon(
                                  _obscureTextSignUp
                                      ? FontAwesomeIcons.eye
                                      : FontAwesomeIcons.eyeSlash,
                                  size: 15.0,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 250.0,
                          height: 1.0,
                          color: Colors.grey[400],
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                          child: TextFormField(
                            validator: (val) {
                              if (val != signUpPasswordController.text) {
                                setState(() => addedHeightSignUp = 30);
                                return "Die Passwörter müssen identisch sein";
                              } else
                                return null;
                            },
                            controller: signUpConfirmPasswordController,
                            obscureText: _obscureTextSignUpConfirm,
                            style: TextStyle(
                                //fontFamily: "WorkSansSemiBold",
                                fontSize: 16.0,
                                color: Colors.black),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              icon: Icon(
                                FontAwesomeIcons.lock,
                                color: Colors.black,
                              ),
                              hintText: "Passwort wiederholen",
                              hintStyle: TextStyle(
                                  //fontFamily: "WorkSansSemiBold",
                                  fontSize: 16.0),
                              suffixIcon: GestureDetector(
                                onTap: _toggleSignUpConfirm,
                                child: Icon(
                                  _obscureTextSignUpConfirm
                                      ? FontAwesomeIcons.eye
                                      : FontAwesomeIcons.eyeSlash,
                                  size: 15.0,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  // TODO: hier
                  margin: EdgeInsets.only(top: 340.0 + addedHeightSignUp * 3.2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Theme.Colors.loginGradientStart,
                        offset: Offset(1.0, 6.0),
                        blurRadius: 20.0,
                      ),
                      BoxShadow(
                        color: Theme.Colors.loginGradientEnd,
                        offset: Offset(1.0, 6.0),
                        blurRadius: 20.0,
                      ),
                    ],
                    gradient: LinearGradient(
                        colors: [
                          Theme.Colors.loginGradientEnd,
                          Theme.Colors.loginGradientStart
                        ],
                        begin: const FractionalOffset(0.2, 0.2),
                        end: const FractionalOffset(1.0, 1.0),
                        stops: [0.0, 1.0],
                        tileMode: TileMode.clamp),
                  ),
                  child: MaterialButton(
                      highlightColor: Colors.transparent,
                      splashColor: Theme.Colors.loginGradientEnd,
                      //shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 42.0),
                        child: Text(
                          "REGISTRIEREN",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25.0,
                            //fontFamily: "WorkSansBold"
                          ),
                        ),
                      ),
                      onPressed: () async {
                        if (_signUpKey.currentState.validate()) {
                          setState(() => loading = true);
                          print(loginEmailController.text);
                          print(loginPasswordController.text);
                          dynamic result =
                              await _auth.registerWithEmailAndPassword(
                                  signUpEmailController.text,
                                  signUpPasswordController.text);
                          if (result == null) {
                            setState(() {
                              loading = false;
                            });
                            showInSnackBar(
                                "Bitte gib eine gültige Emailadresse an");
                          }
                        }
                      }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onSignInButtonPress() {
    _pageController.animateToPage(0,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
    addedHeightSignUp = 0;
  }

  void _onSignUpButtonPress() {
    _pageController?.animateToPage(1,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
    addedHeightSignIn = 0;
  }

  void _toggleLogin() {
    setState(() {
      _obscureTextLogin = !_obscureTextLogin;
    });
  }

  void _toggleSignUp() {
    setState(() {
      _obscureTextSignUp = !_obscureTextSignUp;
    });
  }

  void _toggleSignUpConfirm() {
    setState(() {
      _obscureTextSignUpConfirm = !_obscureTextSignUpConfirm;
    });
  }
}
