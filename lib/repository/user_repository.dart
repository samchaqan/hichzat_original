import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hichzat/model/user.dart';
import 'package:hichzat/services/auth_base.dart';
import 'package:hichzat/services/fake_auth_service.dart';
import 'package:hichzat/services/firebase_auth_service.dart';
import 'package:hichzat/services/firestore_db_service.dart';

import '../locator.dart';

enum AppMode {DEBUG, RELEASE}

class UserRepository implements AuthBase {

  FirebaseAuthService _firebaseAuthService = locator<FirebaseAuthService>();
  FakeAuthenticationService _fakeAuthenticationService = locator<FakeAuthenticationService>();
  FirestoreDBService _firestoreDBService = locator<FirestoreDBService>();


  AppMode appMode = AppMode.RELEASE;

  @override
  Future<Uzer> currentUser() async {
    if(appMode == AppMode.DEBUG){
      return await _fakeAuthenticationService.currentUser();
    }else{
      return await _firebaseAuthService.currentUser();
    }
  }

  @override
  Future<bool> signOut() async {
    if(appMode == AppMode.DEBUG){
      return await _fakeAuthenticationService.signOut();
    }else{
      return await _firebaseAuthService.signOut();
    }

  }

  @override
  Future<Uzer> createUserEmailandPassword(String email, String sifre) async{
    if(appMode == AppMode.DEBUG){
      return await _fakeAuthenticationService.createUserEmailandPassword(email, sifre);
    }else{
      Uzer _user = await _firebaseAuthService.createUserEmailandPassword(email, sifre);
      bool _sonuc = await _firestoreDBService.saveUser(_user);
      if(_sonuc){ // if this code is true
        return await _firestoreDBService.readUser(_user.userID);
      }else return null;
    }
  }

  @override
  Future<Uzer> signInWithEmailandPassword(String email, String sifre) async{
    if(appMode == AppMode.DEBUG){
      return await _fakeAuthenticationService.signInWithEmailandPassword(email, sifre);
    }else{
      Uzer _user =  await _firebaseAuthService.signInWithEmailandPassword(email, sifre);
      return await  _firestoreDBService.readUser(_user.userID);
    }
  }

  Future<bool> updateUserName(String userID, String yeniUserName) async {
    if(appMode == AppMode.DEBUG){
      return false;
    }else{

      return await  _firestoreDBService.updateUserName(userID,yeniUserName);
    }
  }
  Future<bool> updateGroupName(QueryDocumentSnapshot group, String yeniUserName) async {
    if(appMode == AppMode.DEBUG){
      return false;
    }else{

      return await  _firestoreDBService.updateGroupName(group,yeniUserName);
    }
  }

}