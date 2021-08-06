
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupPost{
  String text;
  String whocreatethispost;
  String whocreatethispostimage;
  String image;

  GroupPost({this.text, this.whocreatethispost, this.whocreatethispostimage,
      this.image});

  factory GroupPost.fromDoc(DocumentSnapshot doc){
    return GroupPost(
      text: doc['text'],
      whocreatethispost: doc['whocreatethispost'],
      whocreatethispostimage: doc['whocreatethispostimage'],
      image: doc['image'],
    );
  }



}