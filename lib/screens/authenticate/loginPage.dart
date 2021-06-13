import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:magpie_app/SizeConfig.dart';
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
  List<Text> resetErrors = [];
  Text nameError;
  Text emailError;
  Text passwordError;
  Text repeatPasswordError;
  Text resetPasswordError;

  // TODO: Regex auch für ai.hs-fulda.de freischalten
  RegExp emailRegEx = RegExp(
      r"^[^.@-]*(?:(?:[\wäöüÄÖÜ]+\-?)+[^.@-]*\.?[^.@-]*)*[^.@-]*@[^.@-]*\.?(?:(?:[\wäöüÄÖÜ]+\-?)+[^.@-]*\.[^.@-])+[\wäöüÄÖÜ]{0,3}$");

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
            width: SizeConfig.screenWidth,
            height: SizeConfig.screenHeight >= 775.0
                ? SizeConfig.screenHeight
                : loading
                    ? SizeConfig.screenHeight
                    : SizeConfig.screenHeight * 1.1,
            decoration: BoxDecoration(
              gradient: linearGradient(Theme.Colors.loginGradientEnd,
                  Theme.Colors.loginGradientStart),
            ),
            child: loading
                ? Container(
                    color: Colors.teal,
                    child: Center(
                        child: CircularProgressIndicator(
                            backgroundColor: Colors.white)))
                : Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: SizeConfig.vert * 5),
                        child: Image.asset(
                          "pics/logo.png",
                          width: SizeConfig.isTablet
                              ? SizeConfig.vert * 22
                              : SizeConfig.hori * 30,
                          height: SizeConfig.isTablet
                              ? SizeConfig.vert * 22
                              : SizeConfig.hori * 30,
                          fit: BoxFit.fill,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: SizeConfig.isTablet
                                ? SizeConfig.vert * 2
                                : SizeConfig.vert),
                        child: SizeConfig.isTablet
                            ? Container()
                            : _buildMenuBar(context),
                      ),
                      SizeConfig.isTablet
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(
                                    width: SizeConfig.hori * 50,
                                    child: _buildSignIn(context)),
                                SizedBox(
                                    width: SizeConfig.hori * 50,
                                    child: _buildSignUp(context)),
                              ],
                            )
                          : Expanded(
                              //flex: 2,
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
    _pageController = PageController();

    nameError = errorMessage("Bitte gib einen Benutzernamen an");
    emailError = errorMessage("Bitte gib eine gültige Emailadresse an");
    passwordError =
        errorMessage("Passwörter müssen mindestens sechs Zeichen beinhalten");
    repeatPasswordError = errorMessage("Die Passwörter müssen identisch sein");
    resetPasswordError = errorMessage(
        "Bitte gib eine gültige Emailadresse an, damit dein Passwort zurückgesetzt werden kann");
  }

  void showInSnackBar(String value) {
    FocusScope.of(context).requestFocus(FocusNode());
    _scaffoldKey.currentState?.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(value,
            textAlign: TextAlign.center,
            style: style().copyWith(color: Colors.white)),
        backgroundColor: Colors.teal,
        duration: Duration(seconds: 3)));
  }

  Widget _buildMenuBar(BuildContext context) {
    return Container(
      width: 300,
      height: 50,
      decoration: BoxDecoration(
        color: Color(0x552B2B2B),
        borderRadius: BorderRadius.all(Radius.circular(25)),
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
      padding: EdgeInsets.only(top: SizeConfig.isTablet ? 0 : 23),
      child: Form(
        key: _signInKey,
        child: Column(children: <Widget>[
          Column(
            children: <Widget>[
              Card(
                elevation: 2,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Container(
                  width: SizeConfig.isTablet
                      ? SizeConfig.hori * 40
                      : SizeConfig.hori * 80,
                  height: SizeConfig.isTablet
                      ? SizeConfig.hori * 16
                      : SizeConfig.vert * 25,
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: formFieldPadding(),
                          child: TextFormField(
                            validator: (val) => validate(
                                !emailRegEx.hasMatch(loginEmailController.text),
                                signInErrors,
                                emailError),
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
                      ),
                      line(),
                      Expanded(
                        child: Padding(
                          padding: formFieldPadding(),
                          child: TextFormField(
                            validator: (val) => validate(
                                val.length < 6, signInErrors, passwordError),
                            focusNode: myFocusNodePasswordLogin,
                            controller: loginPasswordController,
                            obscureText: _obscureTextLogin,
                            style: style().copyWith(color: Colors.black),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              icon: icon(FontAwesomeIcons.lock),
                              hintText: "Passwort",
                              suffixIcon: toggleEyeIcon(
                                  _toggleLogin, _obscureTextLogin),
                              hintStyle: style(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              footerButton(
                  SizeConfig.vert,
                  "LOGIN",
                  _signInKey,
                  signInErrors,
                  loginEmailController.text,
                  loginPasswordController.text,
                  "Email oder Passwort ungültig"),
              showErrors(signInErrors, 10),
              FlatButton(
                  onPressed: () {
                    validate(loginEmailController.text.isEmpty, resetErrors,
                        resetPasswordError);
                  },
                  child: Text(
                    "Passwort vergessen?",
                    style: style().copyWith(
                      decoration: TextDecoration.underline,
                      color: Colors.white,
                    ),
                  )),
              showErrors(resetErrors, 0),
              Visibility(
                visible: loginEmailController.text.isNotEmpty &&
                        resetErrors.length == 0
                    ? true
                    : false,
                child: FlatButton(
                    onPressed: () async {
                      setState(() => loading = true);
                      dynamic result =
                          await _auth.resetPassword(loginEmailController.text);
                      if (result == null) {
                        setState(() => loading = false);
                        showInSnackBar(
                            "Es wurde ein Link zum Zurücksetzen deines Passworts an deine Emailadresse gesendet");
                      }
                    },
                    child: Text(
                      "Passwort zurücksetzen",
                      style: style().copyWith(
                        decoration: TextDecoration.underline,
                        color: Colors.white,
                      ),
                    )),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    fadingLine(Colors.white10, Colors.white),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
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
        ]),
      ),
    );
  }

  Widget socialIcon(String socialNetworkName, IconData socialNetworkIcon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: GestureDetector(
        onTap: () async {
          setState(() => loading = true);
          dynamic result;
          switch (socialNetworkName) {
            case "Google":
              result = await _auth.signInWithGoogle();
              break;
            case "Facebook":
              result = await _auth.signInWithFacebook();
              break;
          }
          if (result == null || result == 0) {
            setState(() => loading = false);
            if (result == null)
              showInSnackBar(
                  "Etwas ist schiefgelaufen. Versuch es später nochmal.");
          }
        },
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Icon(socialNetworkIcon, color: Colors.teal),
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
    return Icon(iconData,
        size: SizeConfig.isTablet ? SizeConfig.vert * 3 : SizeConfig.hori * 5,
        color: Colors.black);
  }

  EdgeInsets formFieldPadding() {
    return EdgeInsets.symmetric(vertical: 20, horizontal: 25);
  }

  TextStyle style() {
    return TextStyle(
        fontSize: SizeConfig.isTablet
            ? SizeConfig.vert * 3
            : SizeConfig.hori * 4); //fontFamily: "WorkSansSemiBold"
  }

  Container line() {
    return Container(
        width: SizeConfig.hori * 100, height: 1, color: Colors.grey[400]);
  }

  Container fadingLine(Color leftColor, Color rightColor) {
    return Container(
        decoration: BoxDecoration(
          gradient: linearGradient(leftColor, rightColor),
        ),
        width:
            SizeConfig.isTablet ? SizeConfig.hori * 15 : SizeConfig.hori * 30,
        height: 1);
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
            fontSize: 16,
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
        borderRadius: BorderRadius.all(Radius.circular(5)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Theme.Colors.loginGradientStart,
            offset: Offset(1, 6),
            blurRadius: 20,
          ),
          BoxShadow(
            color: Theme.Colors.loginGradientEnd,
            offset: Offset(1, 6),
            blurRadius: 20,
          ),
        ],
        gradient: linearGradient(
            Theme.Colors.loginGradientEnd, Theme.Colors.loginGradientStart),
      ),
      child: MaterialButton(
          highlightColor: Colors.transparent,
          splashColor: Theme.Colors.loginGradientEnd,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 42),
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
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
                setState(() => loading = false);
                showInSnackBar(error);
              }
            }
          }),
    );
  }

  LinearGradient linearGradient(Color leftColor, Color rightColor) {
    return LinearGradient(
        colors: [leftColor, rightColor],
        begin: const FractionalOffset(0, 0),
        end: const FractionalOffset(1.2, 1.2),
        stops: [0, 1],
        tileMode: TileMode.clamp);
  }

  Text errorMessage(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
          color: Colors.amber,
          fontSize:
              SizeConfig.isTablet ? SizeConfig.vert * 2 : SizeConfig.hori * 3),
    );
  }

  Widget showErrors(List<Text> errors, double padding) {
    return Visibility(
        visible: errors.length == 0 ? false : true,
        child: Padding(
          padding: EdgeInsets.only(top: padding),
          child: Column(
            children: errors,
          ),
        ));
  }

  Widget _buildSignUp(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: SizeConfig.isTablet ? 0 : 23),
      child: Form(
        key: _signUpKey,
        child: Column(
          children: <Widget>[
            Column(
              children: <Widget>[
                Card(
                  elevation: 2,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Container(
                    width: SizeConfig.isTablet
                        ? SizeConfig.hori * 40
                        : SizeConfig.hori * 80,
                    height: SizeConfig.isTablet
                        ? SizeConfig.hori * 31
                        : SizeConfig.vert * 50,
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: formFieldPadding(),
                            child: TextFormField(
                              validator: (val) => validate(
                                  val.isEmpty, signUpErrors, nameError),
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
                        ),
                        line(),
                        Expanded(
                          child: Padding(
                            padding: formFieldPadding(),
                            child: TextFormField(
                              validator: (val) => validate(
                                  !emailRegEx
                                      .hasMatch(signUpEmailController.text),
                                  signUpErrors,
                                  emailError),
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
                        ),
                        line(),
                        Expanded(
                          child: Padding(
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
                        ),
                        line(),
                        Expanded(
                          child: Padding(
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
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            footerButton(
                SizeConfig.vert,
                "REGISTRIEREN",
                _signUpKey,
                signUpErrors,
                signUpEmailController.text,
                signUpPasswordController.text,
                "Bitte fülle alle Felder korrekt aus"),
            showErrors(signUpErrors, 10),
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
