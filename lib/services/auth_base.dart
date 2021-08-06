import 'package:hichzat/model/user.dart';

abstract class AuthBase{
  Future<Uzer> currentUser();
  Future<bool> signOut();
  Future<Uzer> signInWithEmailandPassword(String email,String sifre);
  Future<Uzer> createUserEmailandPassword(String email,String sifre);
}