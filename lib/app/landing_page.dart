import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hichzat/app/home_page.dart';
import 'package:hichzat/app/sign_in/sign_in_page.dart';
import 'package:hichzat/viewmodel/user_model.dart';
import 'package:provider/provider.dart';

class LandingPage extends StatelessWidget {


  @override
  Widget build(BuildContext context) {

    final _userModel = Provider.of<UserModel>(context);

    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, snapshot){
        if(snapshot.hasData){
          return HomePage(currentUserId: _userModel.user.userID,visitedUserId: _userModel.user.userID,);
        }else{
          return SignInPage();
        }
      },
    );


    // if(_userModel.state == ViewState.Idle){
    //   if(_userModel.user == null){
    //     return SignInPage();
    //   }else{
    //     return HomePage(user: _userModel.user,);
    //   }
    // }else{
    //   return Scaffold(
    //     body: Center(child: CircularProgressIndicator(),),
    //   );
    // }



  }

}
