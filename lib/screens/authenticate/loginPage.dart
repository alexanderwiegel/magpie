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

  List<Text> signUpErrors = [];
  List<Text> signInErrors = [];
  Text nameError;
  Text emailError;
  Text passwordError;
  Text repeatPasswordError;

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
        // ignore: missing_return
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
              gradient: linearGradient(Theme.Colors.loginGradientEnd,
                  Theme.Colors.loginGradientStart),
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
                        padding: EdgeInsets.only(top: 50.0),
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

    nameError = errorMessage("Bitte gib einen Benutzernamen an");
    emailError = errorMessage("Bitte gib eine gültige Emailadresse an");
    passwordError =
        errorMessage("Passwörter müssen mindestens sechs Zeichen beinhalten");
    repeatPasswordError = errorMessage("Die Passwörter müssen identisch sein");
  }

  void showInSnackBar(String value) {
    FocusScope.of(context).requestFocus(FocusNode());
    _scaffoldKey.currentState?.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(
        value,
        textAlign: TextAlign.center,
        style: style().copyWith(color: Colors.white),
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
            headerButton("Einloggen", _onSignInButtonPress, left),
            headerButton("Registrieren", _onSignUpButtonPress, right),
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
                    height: 195.0,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: formFieldPadding(),
                          child: TextFormField(
                            validator: (val) =>
                                validate(val.isEmpty, signInErrors, emailError),
                            focusNode: myFocusNodeEmailLogin,
                            controller: loginEmailController,
                            keyboardType: TextInputType.emailAddress,
                            style: style().copyWith(color: Colors.black),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              icon: icon(Icons.mail),
                              hintText: "Emailadresse",
                              hintStyle: style(),
                            ),
                          ),
                        ),
                        line(),
                        Padding(
                          padding: formFieldPadding(),
                          child: TextFormField(
                            validator: (val) => validate(
                                val.length < 6, signInErrors, passwordError),
                            focusNode: myFocusNodePasswordLogin,
                            controller: loginPasswordController,
                            obscureText: _obscureTextLogin,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              icon: icon(FontAwesomeIcons.lock),
                              hintText: "Passwort",
                              suffixIcon: toggleEyeIcon(
                                  _toggleLogin, _obscureTextLogin),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                footerButton(
                    175,
                    "LOGIN",
                    _signInKey,
                    signInErrors,
                    loginEmailController.text,
                    loginPasswordController.text,
                    "Email oder Passwort ungültig")
              ],
            ),
            showErrors(signInErrors),
            Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: FlatButton(
                  onPressed: () {},
                  child: Text(
                    "Passwort vergessen?",
                    style: style().copyWith(
                      decoration: TextDecoration.underline,
                      color: Colors.white,
                    ),
                  )),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  fadingLine(Colors.white10, Colors.white),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.0),
                    child: Text(
                      "oder",
                      style: style().copyWith(color: Colors.white),
                    ),
                  ),
                  fadingLine(Colors.white, Colors.white10),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                socialIcon("Facebook", FontAwesomeIcons.facebookF),
                socialIcon("Google", FontAwesomeIcons.google),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget socialIcon(String socialNetworkName, IconData socialNetworkIcon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: GestureDetector(
        onTap: () => showInSnackBar("$socialNetworkName button pressed"),
        child: Container(
          padding: const EdgeInsets.all(15.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Icon(
            socialNetworkIcon,
            color: Color(0xFF0084ff),
          ),
        ),
      ),
    );
  }

  Widget toggleEyeIcon(Function onTap, bool condition) {
    return GestureDetector(
      onTap: onTap,
      child: icon(condition ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash),
    );
  }

  Icon icon(IconData iconData) {
    return Icon(iconData, size: 19, color: Colors.black);
  }

  EdgeInsets formFieldPadding() {
    return EdgeInsets.symmetric(vertical: 20, horizontal: 25);
  }

  TextStyle style() {
    return TextStyle(fontSize: 16); //fontFamily: "WorkSansSemiBold"
  }

  Container line() {
    return Container(
      width: 250.0,
      height: 1.0,
      color: Colors.grey[400],
    );
  }

  Container fadingLine(Color leftColor, Color rightColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: linearGradient(leftColor, rightColor),
      ),
      width: 100.0,
      height: 1.0,
    );
  }

  Widget headerButton(String text, Function onPressed, Color color) {
    return Expanded(
      child: FlatButton(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 16.0,
            //fontFamily: "WorkSansSemiBold"
          ),
        ),
      ),
    );
  }

  Widget footerButton(double margin, String text, GlobalKey<FormState> key,
      List<Text> errors, String email, String password, String error) {
    return Container(
      margin: EdgeInsets.only(top: margin),
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
        gradient: linearGradient(
            Theme.Colors.loginGradientEnd, Theme.Colors.loginGradientStart),
      ),
      child: MaterialButton(
          highlightColor: Colors.transparent,
          splashColor: Theme.Colors.loginGradientEnd,
          //shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 42.0),
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 25.0,
                //fontFamily: "WorkSansBold"
              ),
            ),
          ),
          onPressed: () async {
            if (key.currentState.validate() && errors.length == 0) {
              setState(() => loading = true);
              dynamic result = text == "LOGIN"
                  ? await _auth.signInWithEmailAndPassword(email, password)
                  : await _auth.registerWithEmailAndPassword(email, password);
              if (result == null) {
                setState(() {
                  loading = false;
                });
                showInSnackBar(error);
              }
            }
          }),
    );
  }

  LinearGradient linearGradient(Color leftColor, Color rightColor) {
    return LinearGradient(
        colors: [leftColor, rightColor],
        begin: const FractionalOffset(0.0, 0.0),
        end: const FractionalOffset(1.2, 1.2),
        stops: [0.0, 1.0],
        tileMode: TileMode.clamp);
  }

  Text errorMessage(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.amber),
    );
  }

  Widget showErrors(List<Text> errors) {
    return Visibility(
        visible: errors.length == 0 ? false : true,
        child: Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Column(
            children: errors,
          ),
        ));
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
                    height: 360.0,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: formFieldPadding(),
                          child: TextFormField(
                            validator: (val) =>
                                validate(val.isEmpty, signUpErrors, nameError),
                            focusNode: myFocusNodeName,
                            controller: signUpNameController,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.words,
                            style: style().copyWith(color: Colors.black),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              icon: icon(FontAwesomeIcons.user),
                              hintText: "Benutzername",
                              hintStyle: style(),
                            ),
                          ),
                        ),
                        line(),
                        Padding(
                          padding: formFieldPadding(),
                          child: TextFormField(
                            validator: (val) =>
                                validate(val.isEmpty, signUpErrors, emailError),
                            focusNode: myFocusNodeEmail,
                            controller: signUpEmailController,
                            keyboardType: TextInputType.emailAddress,
                            style: style().copyWith(color: Colors.black),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              icon: icon(FontAwesomeIcons.envelope),
                              hintText: "Emailadresse",
                              hintStyle: style(),
                            ),
                          ),
                        ),
                        line(),
                        Padding(
                          padding: formFieldPadding(),
                          child: TextFormField(
                            validator: (val) => validate(
                                val.length < 6, signUpErrors, passwordError),
                            focusNode: myFocusNodePassword,
                            controller: signUpPasswordController,
                            obscureText: _obscureTextSignUp,
                            style: style().copyWith(color: Colors.black),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              icon: icon(FontAwesomeIcons.lock),
                              hintText: "Passwort",
                              hintStyle: style(),
                              suffixIcon: toggleEyeIcon(
                                  _toggleSignUp, _obscureTextSignUp),
                            ),
                          ),
                        ),
                        line(),
                        Padding(
                          padding: formFieldPadding(),
                          child: TextFormField(
                            validator: (val) => validate(
                                val != signUpPasswordController.text,
                                signUpErrors,
                                repeatPasswordError),
                            controller: signUpConfirmPasswordController,
                            obscureText: _obscureTextSignUpConfirm,
                            style: style().copyWith(color: Colors.black),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              icon: icon(FontAwesomeIcons.lock),
                              hintText: "Passwort wiederholen",
                              hintStyle: style(),
                              suffixIcon: toggleEyeIcon(_toggleSignUpConfirm,
                                  _obscureTextSignUpConfirm),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                footerButton(
                    340,
                    "REGISTRIEREN",
                    _signUpKey,
                    signUpErrors,
                    signUpEmailController.text,
                    signUpPasswordController.text,
                    "Bitte fülle alle Felder korrekt aus")
              ],
            ),
            showErrors(signUpErrors),
          ],
        ),
      ),
    );
  }

  String validate(bool condition, List<Text> errors, Text error) {
    errors.remove(error);
    if (condition) setState(() => errors.add(error));
    return null;
  }

  void _onSignInButtonPress() {
    _pageController.animateToPage(0,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void _onSignUpButtonPress() {
    _pageController?.animateToPage(1,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void _toggleLogin() {
    setState(() => _obscureTextLogin = !_obscureTextLogin);
  }

  void _toggleSignUp() {
    setState(() => _obscureTextSignUp = !_obscureTextSignUp);
  }

  void _toggleSignUpConfirm() {
    setState(() => _obscureTextSignUpConfirm = !_obscureTextSignUpConfirm);
  }
}
