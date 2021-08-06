import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hichzat/model/user.dart';
import 'package:hichzat/viewmodel/user_model.dart';
import 'package:provider/provider.dart';

class KayitOl extends StatefulWidget {
  @override
  _KayitOlState createState() => _KayitOlState();
}

class _KayitOlState extends State<KayitOl> {

  String _email,_sifre;
  final _formKey = GlobalKey<FormState>();

  _formsubmit() async {
    _formKey.currentState.save();
    final _userModel = Provider.of<UserModel>(context,listen: false);
    Uzer kayitYapanUser = await _userModel.createUserEmailandPassword(_email, _sifre);
  }

  @override
  Widget build(BuildContext context) {
    final _userModel = Provider.of<UserModel>(context);

    if(_userModel.user != null){
      Future.delayed(Duration(milliseconds: 5),() {
        Navigator.of(context).pop();
      });
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey.shade200,
        title: Text(
          'Hichzat',
          style: TextStyle(color: Colors.red),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: Colors.red,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.grey.shade200,
      body: _userModel.state == ViewState.Idle ? SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 20, top: 30, right: 10, bottom: 20),
                child: Text(
                  "Hichzat'a Kayıt Ol Sende Aramıza Katıl !",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    errorText: _userModel.emailHataMesaji != null ? _userModel.emailHataMesaji : null,
                    hintText: 'Email',
                    labelText: 'Email',
                  ),
                  onSaved: (String girilenEmail){
                    _email = girilenEmail;
                  }
                  ,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  onSaved: (String girilenSifre){
                    _sifre = girilenSifre;
                  },
                  obscureText: true,
                  decoration: InputDecoration(
                    errorText: _userModel.sifreHataMesaji != null ? _userModel.sifreHataMesaji : null,
                    hintText: 'Şifre',
                    labelText: 'Şifre',
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                width: 100,
                child: RaisedButton(
                  onPressed: () =>_formsubmit(),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Text(
                    "Kayıt Ol",
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ) : Scaffold(
        body: Center(child: CircularProgressIndicator(),),
      ),
    );
  }


}
