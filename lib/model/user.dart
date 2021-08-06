import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class Uzer{

  final String userID;
  String email;
  String userName;
  String profilURL;
  DateTime createdAt;
  DateTime updatedAt;
  String bio;
  String coverImage;

  Uzer({this.userID,this.email,this.coverImage,this.bio,this.userName,this.profilURL});

  Map<String,dynamic> toMap(){

    return {
      'userID' : userID,
      'email' : email,
      'userName' : userName ?? email.substring(0,email.indexOf('@')) + randomSayiUret(),
      'profilURL' : profilURL ?? '',
      'createdAt' : createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt' : updatedAt ?? FieldValue.serverTimestamp(),
      'bio' : bio ?? '',
      'coverImage': coverImage ?? '',
    };
  }

  Uzer.fromMap(Map<String,dynamic> map):
        userID = map['userID'],
        email = map['email'],
        bio = map['bio'],
        userName = map['userName'],
        profilURL = map['profilURL'],
        coverImage = map['coverImage'],
        createdAt = (map['createdAt'] as Timestamp).toDate(),
        updatedAt = (map['updatedAt'] as Timestamp).toDate();

  factory Uzer.fromDoc(DocumentSnapshot doc){
    return Uzer(
      userID: doc.id,
      userName: doc['userName'],
      email: doc['email'],
      profilURL: doc['profilURL'],
      bio: doc['bio'],
      coverImage: doc['coverImage'],

    );
  }

  @override
  String toString() {
    return 'Uzer{userID: $userID, email: $email, userName: $userName, profilURL: $profilURL, createdAt: $createdAt, updatedAt: $updatedAt, bio: $bio, coverImage: $coverImage}';
  }

  String randomSayiUret() {
    int rastgeleSayi = Random().nextInt(9999);
    return rastgeleSayi.toString();
  }
}










