import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 👉 Iniciar sesión
  Future<User?> signIn(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw e.code;
    }
  }

  // 👉 Registrar usuario (solo dueños)
  Future<User?> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;
      if (user != null) {
        await user.updateDisplayName(name);

        // 🔹 Guardar datos en Firestore
        await _firestore.collection("users").doc(user.uid).set({
          "fullName": name,
          "email": email,
          "role": "owner", // 🔥 rol fijo
          "createdAt": FieldValue.serverTimestamp(),
        });
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw e.code;
    }
  }

  // 👉 Cerrar sesión
  Future<void> signOut() async => await _auth.signOut();

  // 👉 Restablecer contraseña
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw e.code;
    }
  }
}
