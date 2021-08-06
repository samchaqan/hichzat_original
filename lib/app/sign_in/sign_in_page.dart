import 'package:flutter/material.dart';
import 'package:hichzat/app/sign_in/giris_yap.dart';
import 'package:hichzat/app/sign_in/kayit_ol.dart';

class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade200,
        title: Text(
          'Hichzat',
          style: TextStyle(color: Colors.red),
        ),
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade200,
      body: Container(
        padding: EdgeInsets.all(17.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              "Yeni Türkiye'nin Eleştiri Platformu",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
            ),
            SizedBox(
              height: 50,
            ),
            Container(
              width: 100,
              child: RaisedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      fullscreenDialog: false,
                      builder: (context) => GirisYap(),
                    ),
                  );
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Text(
                  "Giriş Yap",
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.red,
              ),
            ),
            TextButton(
              child: Text('Kayıt Ol'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (context) => KayitOl(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
