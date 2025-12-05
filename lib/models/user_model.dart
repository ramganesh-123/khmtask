import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String uid;
  final String email;
  final String? displayName;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
  });

  factory UserModel.fromFirebaseUser(User firebaseUser) {
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
    );
  }

  factory UserModel.fromFirebaseUserSafe(dynamic firebaseUser) {
    try {
      if (firebaseUser is User) {
        return UserModel.fromFirebaseUser(firebaseUser);
      } else {
        throw TypeError();
      }
    } catch (e) {
      throw Exception('Failed to create UserModel: Invalid user type');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
    );
  }
}
