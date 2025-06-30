import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _userRef = FirebaseFirestore.instance.collection(
    'users',
  );

  // Menyimpan user ke Firestore
  Future<void> saveUser(UserModel user) async {
    await _userRef.doc(user.uid).set(user.toMap());
  }

  // Mengambil user dari Firestore
  Future<UserModel?> getUser(String uid) async {
    final doc = await _userRef.doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Registrasi dengan email & password
  Future<String?> register(String email, String password, String name, {String status = 'reguler'}) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final newUser = UserModel(
        uid: result.user!.uid,
        email: email,
        name: name,
        status: status,
      );

      try {
        await saveUser(newUser);
      } catch (e) {
        return "Gagal menyimpan user ke Firestore: $e";
      }

      // Upload ke Realtime Database
      try {
        final userData = {
          "uid": result.user!.uid,
          "email": email,
          "name": name,
          "status": status,
        };
        await FirebaseDatabase.instance
            .ref()
            .child("user")
            .child(result.user!.uid)
            .set(userData);
      } catch (e) {
        return "Gagal upload ke Realtime Database: $e";
      }

      return null; // sukses
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Terjadi kesalahan saat registrasi: $e";
    }
  }

  // Login dengan email & password
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Terjadi kesalahan saat login";
    }
  }

  // Logout
  Future<String?> logout() async {
    try {
      await _auth.signOut();
      return null;
    } catch (e) {
      return "Logout gagal: ${e.toString()}";
    }
  }

  // User saat ini
  User? get currentUser => _auth.currentUser;

  // Ambil UserModel user yang sedang login
  Future<UserModel?> getCurrentUserModel() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return getUser(user.uid);
  }
}
