import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/magpieUser.dart';
import 'database_helper.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FacebookLogin facebookLogin = FacebookLogin();
  final GoogleSignIn googleSignIn = GoogleSignIn(
      //clientId:
      //    "426743660967-bfff2c6p98l0nnl43jv3qhjcpj62ejjm.apps.googleusercontent.com"
      );

  MagpieUser _userFromFirebaseUser(User user) {
    return user != null ? MagpieUser(uid: user.uid) : null;
  }

  Stream<MagpieUser> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  Future signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleSignInAccount =
          await googleSignIn.signIn();
      if (googleSignInAccount == null) return 0;
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      final UserCredential result = await _auth.signInWithCredential(credential);
      final User user = result.user;
      await DatabaseHelper.instance.insertHome(user.uid);
      // TODO: unterscheiden zwischen Login (update) und SignUp (insert)
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signInWithFacebook() async {
    try {
      final FacebookLoginResult facebookLoginResult =
          await facebookLogin.logIn(['email']);
      switch (facebookLoginResult.status) {
        case FacebookLoginStatus.loggedIn:
          final FacebookAccessToken token = facebookLoginResult.accessToken;
          final AuthCredential credential =
              FacebookAuthProvider.credential(token.token);
          final UserCredential result =
              await _auth.signInWithCredential(credential);
          final User user = result.user;
          await DatabaseHelper.instance.insertHome(user.uid);
          // TODO: unterscheiden zwischen Login (update) und SignUp (insert)
          return _userFromFirebaseUser(user);
          break;
        case FacebookLoginStatus.cancelledByUser:
          return 0;
          break;
        case FacebookLoginStatus.error:
          return null;
          break;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future resetPassword(String email) async {
    try {
      return await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      final User user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      final User user = result.user;
      await user.sendEmailVerification();
      await DatabaseHelper.instance.insertHome(user.uid);
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signOut() async {
    try {
      //if (googleSignIn.currentUser != null)
      //  return await googleSignIn.signOut();
      //if (facebook)
      //  return await facebookLogin.logOut();
      //else
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
