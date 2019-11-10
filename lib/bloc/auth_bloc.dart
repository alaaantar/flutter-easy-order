import 'package:meta/meta.dart';
import 'package:flutter_easy_order/models/user.dart';
import 'package:flutter_easy_order/repository/auth_repository.dart';
import 'package:flutter_easy_order/widgets/helpers/logger.dart';
import 'package:logger/logger.dart';

abstract class AuthBloc {

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

class AuthBlocImpl implements AuthBloc {
  static const String USER_EMAIL = 'easyOrderUserEmail';
  static const String USER_ID = 'easyOrderUserId';
  static const String USER_IS_EMAIL_VERIFIED = 'easyOrderIsEmailVerified';

  final AuthRepository authRepository;
  final Logger logger = getLogger();

  @override
  Stream<User> get user$ => authRepository.user$;

  AuthBlocImpl({@required this.authRepository});

  @override
  Future<User> currentUser() async {
    User user = await authRepository.currentUser();
    return user;
  }

  @override
  Future<User> signInWithEmailAndPassword({@required String email, @required String password}) async {
    final User user = await authRepository.signInWithEmailAndPassword(email: email, password: password);
//    _userSubject.add(user);
    return user;
  }

  @override
  Future<User> signInWithGoogle() async {
    final User user = await authRepository.signInWithGoogle();
    return user;
  }

  // https://medium.com/flutter-community/flutter-facebook-login-77fcd187242
  @override
  Future<User> signInWithFacebook() async {
    final User user = await authRepository.signInWithFacebook();
//    _userSubject.add(user);
    return user;
  }

  @override
  Future<User> createUserWithEmailAndPassword({@required String email, @required String password}) async {
    final User user = await authRepository.createUserWithEmailAndPassword(email: email, password: password);
//    _userSubject.add(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    authRepository.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail({@required String email}) async {
    await authRepository.sendPasswordResetEmail(email: email);
  }

  @override
  void dispose() {
    logger.d('*** DISPOSE AuthBloc ***');
  }
}
