import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';
import '../models/budget_model.dart';

class FirebaseService {

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // ---------------- AUTH ----------------

  Future<String> signUp(String email, String password, String trim) async {
    try {
      await auth.createUserWithEmailAndPassword(email: email, password: password);
      return 'success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'This email is already registered';
      } else if (e.code == 'weak-password') {
        return 'Password is too weak';
      } else if (e.code == 'invalid-email') {
        return 'Please enter a valid email';
      }
      return e.message ?? 'Sign up failed';
    } catch (e) {
      return 'Sign up failed. Please check your internet connection';
    }
  }

  Future<String> signIn(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      return 'success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No account found for this email';
      } else if (e.code == 'wrong-password') {
        return 'Incorrect password';
      } else if (e.code == 'invalid-credential') {
        return 'Incorrect email or password';
      } else if (e.code == 'invalid-email') {
        return 'Please enter a valid email';
      }
      return e.message ?? 'Login failed';
    } catch (e) {
      return 'Login failed. Please check your internet connection';
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  User? getCurrentUser() {
    return auth.currentUser;
  }

  bool isLoggedIn() {
    return auth.currentUser != null;
  }

  // ---------------- FIRESTORE SYNC ----------------
  // Best-effort cloud backup of local data. The app always reads/writes
  // sqflite first (see DatabaseHelper) so it keeps working fully offline;
  // these calls just push a copy to Firestore when there is a connection.
  // Firestore also has offline persistence enabled by default on mobile,
  // so calls made while offline are queued and sent once back online.

  Future<void> syncTransaction(TransactionModel transaction) async {
    String? uid = auth.currentUser?.uid;
    if (uid == null) {
      return;
    }

    try {
      await firestore
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .add(transaction.toMap());
    } catch (e) {
      // Silently ignore. Local sqflite copy is already saved,
      // so the user's data is never lost even if this fails.
    }
  }

  Future<void> syncBudget(BudgetModel budget) async {
    String? uid = auth.currentUser?.uid;
    if (uid == null) {
      return;
    }

    try {
      await firestore
          .collection('users')
          .doc(uid)
          .collection('budgets')
          .add(budget.toMap());
    } catch (e) {
      // Silently ignore, same reasoning as above.
    }
  }
}
