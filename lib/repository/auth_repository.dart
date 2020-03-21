import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easy_order/models/user.dart';
import 'package:flutter_easy_order/widgets/helpers/logger.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

abstract class AuthRepository {
  Stream<User> get user$;

  Future<User> currentUser();

  Future<User> signInWithEmailAndPassword({@required String email, @required String password});

  Future<User> signInWithGoogle();

  Future<User> signInWithFacebook();

  Future<User> createUserWithEmailAndPassword({@required String email, @required String password});

  Future<void> signOut();

  Future<void> sendPasswordResetEmail({@required String email});

  void dispose();
}

class AuthRepositoryFirebaseImpl implements AuthRepository {
  final BehaviorSubject<User> _userSubject = BehaviorSubject<User>.seeded(null);

  @override
  Stream<User> get user$ => _userSubject.stream;

//  AuthRepositoryFirebaseImpl() {
//    _firebaseAuth.onAuthStateChanged.listen((FirebaseUser fbUser) {
//      logger.d('onAuthStateChanged fbUser: $fbUser');
//      final User user = User.fromFirebaseUser(fbUser);
//      _userSubject.add(user);
//    }, onError: (error) => logger.e('_firebaseAuth onAuthStateChanged listen error: $error'), cancelOnError: false);
//  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FacebookLogin _facebookLogin = FacebookLogin();
  final Logger logger = getLogger();

  @override
  Future<User> currentUser() async {
    final FirebaseUser fbUser = await _firebaseAuth.currentUser();
    return User.fromFirebaseUser(fbUser);
  }

  @override
  Future<User> signInWithEmailAndPassword({String email, String password}) async {
    final AuthResult authResult = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    logger.d('firebase user: $authResult'); // firebase, google.com, password
    final User user = User.fromFirebaseUser(authResult.user);
    if (user.isEmailVerified) {
      _userSubject.add(user);
    }
    return user;
  }

  @override
  Future<User> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      final AuthResult authResult = await _firebaseAuth.signInWithCredential(credential);
      logger.d('google user: $authResult'); // firebase, google.com, password
      final User user = User.fromFirebaseUser(authResult.user);
      _userSubject.add(user);
      return user;
    } on Exception catch (ex) {
      logger.e(ex);
      return null;
    }
  }

  @override
  Future<User> signInWithFacebook() async {
    final result = await _facebookLogin.logIn(['email']);
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final AuthCredential credential = FacebookAuthProvider.getCredential(accessToken: result.accessToken.token);

//        var graphResponse = await http.get(
//            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${result.accessToken.token}');
//        var profile = json.decode(graphResponse.body);
//        logger.d(profile.toString());

        final AuthResult authResult = await _firebaseAuth.signInWithCredential(credential);
        logger.d('facebook user: $authResult'); // firebase, facebook.com

//        logger.d('providerId: ${fbUser.providerId}');
//        fbUser.providerData.forEach((UserInfo userInfo) {
//          logger.d(userInfo.providerId);
//        });

        final User user = User.fromFirebaseUser(authResult.user);
        // For Facebook users, set email verified to true by default
        user.isEmailVerified = true;
        _userSubject.add(user);
        return user;

      case FacebookLoginStatus.cancelledByUser:
      case FacebookLoginStatus.error:
      default:
//        throw PlatformException(
//            code: '400', message: 'Authentication failed', details: 'Facebook login cancelled or failed');
        return null;
    }
  }

  @override
  Future<User> createUserWithEmailAndPassword({String email, String password}) async {
    final AuthResult authResult = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    await authResult.user.sendEmailVerification();
    final User user = User.fromFirebaseUser(authResult.user);
    return user;
  }

  @override
  Future<void> signOut() async {
    _facebookLogin.logOut();
    _googleSignIn.signOut();
    _firebaseAuth.signOut();
    _userSubject.add(null);
  }

  @override
  Future<void> sendPasswordResetEmail({@required String email}) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  void dispose() {
    logger.d('*** DISPOSE AuthRepository ***');
    _userSubject.close();
  }
}
