import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hichzat/model/Group.dart';
import 'package:hichzat/model/user.dart';

abstract class DBBase{
  Future<bool> saveUser(Uzer user);
  Future<Uzer> readUser(String userID);
  Future<bool> updateUserName(String userID,String yeniUserName);
  Future<bool> updateGroupName(QueryDocumentSnapshot group,String yeniUserName);


}