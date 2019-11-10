import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

class User {
  final String id;
  final String email;
  bool isEmailVerified;

  User({@required this.id, @required this.email, @required this.isEmailVerified})
  : assert(id != null && email != null && isEmailVerified != null);

  Map<String, dynamic> toJson() => {
    'id': this.id,
    'email': this.email,
    'isEmailVerified': this.isEmailVerified,
  };

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        email = json['email'],
        isEmailVerified = json['isEmailVerified'];

  factory User.fromFirebaseUser(FirebaseUser firebaseUser) {

    if (firebaseUser == null) {
      return null;
    }

    return User(
        id: firebaseUser.uid,
        email: firebaseUser.email,
        isEmailVerified: firebaseUser.isEmailVerified
    );
  }

  @override
  String toString() {
    return 'User{id: $id, email: $email, isEmailVerified: $isEmailVerified}';
  }

}
