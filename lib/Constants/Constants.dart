import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

final _fireStore = FirebaseFirestore.instance;

final followersRef = _fireStore.collection('followers');

final followingRef = _fireStore.collection('following');

final usersRef = _fireStore.collection('users');

const Color KTweeterColor = Color(0xffFF0000);

final storageRef = FirebaseStorage.instance.ref();

final postsRef = _fireStore.collection('posts');

final feedRefs = _fireStore.collection('feeds');


final likesRef = _fireStore.collection('likes');

final activitiesRef = _fireStore.collection('activities');

final repliesRef = _fireStore.collection('replies');

final groupsRef = _fireStore.collection('groups');


