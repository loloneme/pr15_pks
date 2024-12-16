import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService{
  final FirebaseAuth _firebase = FirebaseAuth.instance;

  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future <UserCredential> signIn(String email, String password) async {
    try{
      UserCredential userCredential = await _firebase.signInWithEmailAndPassword(email: email, password: password);

      return userCredential;
    } on FirebaseAuthException catch (e){
      throw Exception(e.code);
    }
  }

  Future <UserCredential> signUp(String email, String password, role) async {
    try{
      UserCredential userCredential = await _firebase.createUserWithEmailAndPassword(email: email, password: password);
      final String uid = userCredential.user?.uid ?? '';

      if (uid.isEmpty) {
        throw Exception('failed to get user UID');
      }

      await _fireStore.collection('users').doc(uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'role': role,
      });
      return userCredential;
    } on FirebaseAuthException catch (e){
      throw Exception(e.code);
    }
  }

  Future <void> signOut() async{
    return await FirebaseAuth.instance.signOut();
  }

  Future<String> getUserRole(String userID) async {
    DocumentSnapshot userDoc = await _fireStore.collection('users').doc(userID).get();
    final data = userDoc.data() as Map<String, dynamic>?;

    return data?['role'] as String;
  }

}