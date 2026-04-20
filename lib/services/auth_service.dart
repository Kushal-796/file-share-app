import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../utils/code_generator.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> signInAnonymously() async {
    try {
      final UserCredential userCredential = await _auth.signInAnonymously();
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Check if user already has a document
        final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
        
        if (!userDoc.exists) {
          // Generate a unique short code
          String shortCode = CodeGenerator.generate();
          
          // Ensure short code uniqueness in Firestore
          while ((await _firestore.collection('users').where('shortCode', isEqualTo: shortCode).get()).docs.isNotEmpty) {
            shortCode = CodeGenerator.generate();
          }

          final newUser = UserModel(
            uid: firebaseUser.uid,
            shortCode: shortCode,
            createdAt: DateTime.now(),
          );

          await _firestore.collection('users').doc(firebaseUser.uid).set(newUser.toMap());
          return newUser;
        } else {
          return UserModel.fromMap(userDoc.data()!);
        }
      }
    } catch (e) {
      print('Auth Error: $e');
    }
    return null;
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
