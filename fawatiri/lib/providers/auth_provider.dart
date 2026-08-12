import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UserRole { owner, receiver }

/// Roles come from the Firestore document `config/roles`
/// (fields: ownerUid, receiverUid), managed in Firebase Console.
/// A user matching neither is treated as having no privileged role.
final authProvider = StreamProvider<UserRole?>((ref) {
  return FirebaseAuth.instance.authStateChanges().asyncMap((user) async {
    if (user == null) return null;
    try {
      final roles = await FirebaseFirestore.instance
          .collection('config')
          .doc('roles')
          .get();
      final data = roles.data();
      final ownerUid = data?['ownerUid'] as String? ?? '';
      final receiverUid = data?['receiverUid'] as String? ?? '';
      if (user.uid == ownerUid) return UserRole.owner;
      if (user.uid == receiverUid) return UserRole.receiver;
      return null;
    } catch (_) {
      return null;
    }
  });
});

final authActionsProvider = Provider((_) => AuthActions());

class AuthActions {
  Future<void> signIn(String email, String password) =>
      FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
  Future<void> signOut() => FirebaseAuth.instance.signOut();
}