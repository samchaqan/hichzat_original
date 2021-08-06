

import 'package:cloud_firestore/cloud_firestore.dart';

class Group{
  String groupName;
  String groupCoverphoto;
  String whocreate;
  String groupBio;
  String whocreateid;
  String groupPorfilephoto;
  String createdAt;


  Group({this.groupName, this.groupCoverphoto, this.whocreate,this.groupBio,this.whocreateid,this.groupPorfilephoto,this.createdAt});



  factory Group.fromDoc(DocumentSnapshot doc){
    return Group(
      groupName: doc['groupName'],
      groupCoverphoto: doc['groupCoverphoto'],
      whocreate: doc['whocreate'],
      groupBio: doc['groupBio'],
      whocreateid: doc['whocreateid'],
      groupPorfilephoto: doc['groupPorfilephoto'],
      createdAt: doc['createdAt'],
    );
  }


}