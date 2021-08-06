import 'package:hichzat/model/user.dart';
import 'package:hichzat/services/auth_base.dart';

class FakeAuthenticationService implements AuthBase{



  @override
  Future<Uzer> currentUser() async{
    return await Future.value(Uzer(userID: "211313213323"));
  }

  @override
  Future<bool> signOut() {
    return Future.value(true);
  }

  @override
  Future<Uzer> createUserEmailandPassword(String email, String sifre) {
    // TODO: implement createUserEmailandPassword
    throw UnimplementedError();
  }

  @override
  Future<Uzer> signInWithEmailandPassword(String email, String sifre) {
    // TODO: implement signInWithEmailandPassword
    throw UnimplementedError();
  }

}