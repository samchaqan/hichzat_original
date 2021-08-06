import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hichzat/model/user.dart';
import 'package:hichzat/repository/user_repository.dart';
import 'package:hichzat/services/auth_base.dart';
import '../locator.dart';

enum ViewState { Idle, Busy }

class UserModel with ChangeNotifier implements AuthBase {
  ViewState _state = ViewState.Idle;
  UserRepository _userRepository = locator<UserRepository>();
  Uzer _user;
  String emailHataMesaji;
  String sifreHataMesaji;

  Uzer get user => _user;

  ViewState get state => _state;

  set state(ViewState value) {
    _state = value;
    notifyListeners();
  }

  UserModel() {
    currentUser();
  }

  @override
  Future<Uzer> currentUser() async {
    try {
      state = ViewState.Busy;
      _user = await _userRepository.currentUser();
      return _user;
    } catch (e) {
      debugPrint("viewmodeldeki parent user hata " + e.toString());
      return null;
    } finally {
      state = ViewState.Idle;
    }
  }

  @override
  Future<bool> signOut() async {
    try {
      state = ViewState.Busy;
      bool sonuc = await _userRepository.signOut();
      _user = null;
      return sonuc;
    } catch (e) {
      debugPrint("viewmodeldeki parent user hata " + e.toString());
      return false;
    } finally {
      state = ViewState.Idle;
    }
  }

  @override
  Future<Uzer> createUserEmailandPassword(String email, String sifre) async {
    try {
      if (_emailSifreKontrol(email, sifre)) {
        state = ViewState.Busy;
        _user = await _userRepository.createUserEmailandPassword(email, sifre);
        return _user;
      } else
        return null;
    } catch (e) {
      debugPrint("viewmodeldeki create user hata " + e.toString());
      return null;
    } finally {
      state = ViewState.Idle;
    }
  }

  @override
  Future<Uzer> signInWithEmailandPassword(String email, String sifre) async {
    try {
      if (_emailSifreKontrol(email, sifre)) {
        state = ViewState.Busy;
        _user = await _userRepository.signInWithEmailandPassword(email, sifre);
        return _user;
      } else
        return null;
    } catch (e) {
      debugPrint("viewmodeldeki sign in hata " + e.toString());
      return null;
    } finally {
      state = ViewState.Idle;
    }
  }

  bool _emailSifreKontrol(String email, String sifre) {
    var sonuc = true;

    if (sifre.length < 6) {
      sifreHataMesaji = "En az 6 karakter olmali";
      sonuc = false;
    } else
      sifreHataMesaji = null;
    if (!email.contains('@')) {
      emailHataMesaji = "Gecersiz Email adresi";
      sonuc = false;
    } else
      emailHataMesaji = null;

    return sonuc;
  }

  Future<bool> updateUserName(String userID, String yeniUserName)async {
    state = ViewState.Busy;

    var sonuc = await _userRepository.updateUserName(userID, yeniUserName);
    state = ViewState.Idle;
    return sonuc;
  }
  Future<bool> updateGroupName(QueryDocumentSnapshot group, String yeniUserName)async {
    state = ViewState.Busy;

    var sonuc = await _userRepository.updateGroupName(group, yeniUserName);
    state = ViewState.Idle;
    return sonuc;
  }






}
