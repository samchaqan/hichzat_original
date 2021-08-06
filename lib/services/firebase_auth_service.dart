import 'package:firebase_auth/firebase_auth.dart';
import 'package:hichzat/model/user.dart';
import 'package:hichzat/services/auth_base.dart';

class FirebaseAuthService implements AuthBase{

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<Uzer> currentUser() async{
    try {
      User user = await _firebaseAuth.currentUser;
      return _userFromFirebase(user);
    }catch(e){
      print("Hata Current user"+e.toString());
      return null;
    }


  }

  Uzer _userFromFirebase(User user){
    if(user == null)
      return null;
    return Uzer(userID: user.uid,email: user.email);
  }


  @override
  Future<bool> signOut() async {
    try{
      await _firebaseAuth.signOut();
      return true;
    }catch(e){
      print('Signout hata'+e.toString());
      return false;
    }

  }

  @override
  Future<Uzer> createUserEmailandPassword(String email, String sifre) async{
    try {
      UserCredential sonuc = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: sifre);
      return _userFromFirebase(sonuc.user);
    }catch(e){
      print("Hata firebase auth service createuserwithemail"+e.toString());
      return null;
    }
  }

  @override
  Future<Uzer> signInWithEmailandPassword(String email, String sifre) async{
    try {
      UserCredential sonuc = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: sifre);
      return _userFromFirebase(sonuc.user);
    }catch(e){
      print("Hata firebase auth service signinwithemail"+e.toString());
      return null;
    }
  }

}