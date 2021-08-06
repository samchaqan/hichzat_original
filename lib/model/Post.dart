
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:hichzat/model/user.dart';

class Post{
  String id;
  String authorId;
  String text;
  String image;
  Timestamp timestamp;
  int likes;
  int reposts;
  int dislikes;
  String authorName;


  Post({this.id, this.authorId, this.text, this.image, this.timestamp,
      this.likes, this.reposts,this.dislikes,this.authorName});


  Post.fromMap(Map<String,dynamic> map):
      id = map['id'],
      authorId = map['authorId'],
      text = map['text'],
      image = map['image'],
      likes = map['likes'],
      reposts = map['reposts'],
      dislikes = map['dislikes'],
      timestamp = map['timestamp'];


  factory Post.fromDoc(DocumentSnapshot doc){
    return Post(
      id: doc.id,
      authorId: doc['authorId'],
      text: doc['text'],
      image: doc['image'],
      timestamp: doc['timestamp'],
      likes: doc['likes'],
      reposts: doc['reposts'],
      dislikes: doc['dislikes'],
      authorName: doc['authorName'],
    );
  }

}