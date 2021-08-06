import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hichzat/Constants/Constants.dart';
import 'package:hichzat/model/Activity.dart';
import 'package:hichzat/model/Group.dart';
import 'package:hichzat/model/GroupPost.dart';
import 'package:hichzat/model/Post.dart';
import 'package:hichzat/model/user.dart';
import 'package:hichzat/services/database_base.dart';

class FirestoreDBService implements DBBase {
  final FirebaseFirestore _firebaseDB = FirebaseFirestore.instance;

  @override
  Future<bool> saveUser(Uzer user) async {
    await _firebaseDB.collection("users").doc(user.userID).set(user.toMap());
    DocumentSnapshot _okunanUser =
        await FirebaseFirestore.instance.doc("users/${user.userID}").get();

    Map _okunanUserBilgileriMap = _okunanUser.data();
    Uzer _okunanUserBilgileriNesne = Uzer.fromMap(_okunanUserBilgileriMap);
    print('okunan user nesnesi :' + _okunanUserBilgileriNesne.toString());
    return true;
  }

  @override
  Future<Uzer> readUser(String userID) async {
    DocumentSnapshot _okunanUser =
        await _firebaseDB.collection("users").doc(userID).get();
    Map<String, dynamic> _okunanUserBilgileriMap = _okunanUser.data();
    Uzer _okunanUserNesnesi = Uzer.fromMap(_okunanUserBilgileriMap);
    print('okunan user nesnesi' + _okunanUserNesnesi.toString());
    return _okunanUserNesnesi;
  }

  Future<int> followersNum(String userID) async {
    QuerySnapshot followersSnapshot =
        await followersRef.doc(userID).collection('Followers').get();
    return followersSnapshot.docs.length;
  }

  Future<int> followingNum(String userID) async {
    QuerySnapshot followingSnapshot =
        await followingRef.doc(userID).collection('Following').get();
    return followingSnapshot.docs.length;
  }

  static void updateUserData(Uzer user) {
    usersRef.doc(user.userID).update({
      'userName': user.userName,
      'bio': user.bio,
      'profilURL': user.profilURL,
      'coverImage': user.coverImage,
    });
  }

  static void updateUserInGroupData(Uzer user) {
    //groupsRef.doc()

    //groupsRef.

    // usersRef.doc(user.userID).update({
    //   'userName': user.userName,
    //   'bio': user.bio,
    //   'profilURL': user.profilURL,
    //   'coverImage': user.coverImage,
    // });
  }

  static void updateGroupData(Group realgroup) {
    groupsRef.doc(realgroup.createdAt).update({
      'groupName': realgroup.groupName,
      'groupCoverphoto': realgroup.groupCoverphoto,
      'whocreate': realgroup.whocreate,
      'groupBio': realgroup.groupBio,
      'whocreateid': realgroup.whocreateid,
      'groupPorfilephoto': realgroup.groupPorfilephoto,
      'createdAt': realgroup.createdAt,
    });
  }




  static Future<QuerySnapshot> searchUsers(String name) async {
    Future<QuerySnapshot> users = usersRef
        .where('userName', isGreaterThanOrEqualTo: name)
        .where('userName', isLessThan: name + 'z')
        .get();

    return users;
  }

  static void followUser(String currentUserId, String visitedUserId) {
    followingRef
        .doc(currentUserId)
        .collection('Following')
        .doc(visitedUserId)
        .set({});
    followersRef
        .doc(visitedUserId)
        .collection('Followers')
        .doc(currentUserId)
        .set({});

    addActivity(currentUserId, null, true, visitedUserId);
  }

  static void unFollowUser(String currentUserId, String visitedUserId) {
    followingRef
        .doc(currentUserId)
        .collection('Following')
        .doc(visitedUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    followersRef
        .doc(visitedUserId)
        .collection('Followers')
        .doc(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  static Future<bool> isFollowingUser(
      String currentUserId, String visitedUserId) async {
    DocumentSnapshot followingDoc = await followersRef
        .doc(visitedUserId)
        .collection('Followers')
        .doc(currentUserId)
        .get();
    return followingDoc.exists;
  }
  // final postsRef = _fireStore.collection('posts');
  // final repliesRef = _fireStore.collection('replies');
  // bir onceki post
  static Future reply(Post post,String text)async{
    if(text == ''){
      return;
    }
    await postsRef.doc(post.authorId).collection('userPosts').doc(post.id).collection('replies').add({
      'text':text,
      'authorId': FirebaseAuth.instance.currentUser.uid,
      'timestamp': FieldValue.serverTimestamp(),
      'image': post.image,
      'likes': post.likes,
      'reposts': post.reposts,
      'dislikes': post.dislikes,
      'authorName': post.authorName,
    });

  }

  static void createPost(Post post) {
    postsRef.doc(post.authorId).set({'postTime': post.timestamp});
    postsRef.doc(post.authorId).collection('userPosts').add({
      'text': post.text,
      'image': post.image,
      'authorId': post.authorId,
      'timestamp': post.timestamp,
      'likes': post.likes,
      'reposts': post.reposts,
      'dislikes': post.dislikes,
      'authorName': post.authorName,
    }).then((doc) async {
      QuerySnapshot followerSnapshot =
          await followersRef.doc(post.authorId).collection('Followers').get();

      for (var docSnapshot in followerSnapshot.docs) {
        feedRefs.doc(docSnapshot.id).collection('userFeed').doc(doc.id).set({
          'text': post.text,
          'image': post.image,
          'authorId': post.authorId,
          'timestamp': post.timestamp,
          'likes': post.likes,
          'reposts': post.reposts,
          'dislikes': post.dislikes,
          'authorName': post.authorName,
        });
      }
    });
  }

  static void createPostInGroup(GroupPost groupPost,QueryDocumentSnapshot group) {
    groupsRef.doc(group['createdAt'].toString().substring(0,23)).collection('replies').add({
      'text': groupPost.text,
      'whocreatethispost': groupPost.whocreatethispost,
      'whocreatethispostimage': groupPost.whocreatethispostimage,
      'image': groupPost.image,
    });
  }

  static void createGroup(Group group,String currentUserId) {
    groupsRef.doc(group.createdAt.toString()).set({
      'groupName': group.groupName,
      'groupCoverphoto': group.groupCoverphoto,
      'whocreate': group.whocreate,
      'groupBio': group.groupBio,
      'whocreateid': group.whocreateid,
      'groupPorfilephoto': group.groupPorfilephoto,
      'createdAt': group.createdAt,
    });
  }


  static Future<List> getUserPosts(String userId) async {
    QuerySnapshot userPostsSnap = await postsRef
        .doc(userId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .get();
    List<Post> userPosts =
        userPostsSnap.docs.map((doc) => Post.fromDoc(doc)).toList();

    return userPosts;
  }

  static Future<List> getHomePosts(String currentUserId) async {
    QuerySnapshot homePosts = await feedRefs
        .doc(currentUserId)
        .collection('userFeed')
        .orderBy('timestamp', descending: true)
        .get();

    List<Post> followingPosts =
        homePosts.docs.map((doc) => Post.fromDoc(doc)).toList();
    return followingPosts;
  }

  // final repliesRef = _fireStore.collection('replies');
  static Future<List<Post>> getReplies(Post post) async {
    QuerySnapshot getreplies = await repliesRef
        .orderBy('timestamp', descending: true)
        .get();

  }




  static void likePost(String currentUserId, Post post) {
    DocumentReference postDocProfile =
        postsRef.doc(post.authorId).collection('userPosts').doc(post.id);
    postDocProfile.get().then((doc) {
      int likes = doc['likes'];
      postDocProfile.update({'likes': likes + 1});
    });

    DocumentReference postDocFeed =
        feedRefs.doc(currentUserId).collection('userFeed').doc(post.id);
    postDocFeed.get().then((doc) {
      if (doc.exists) {
        int likes = doc['likes'];
        postDocFeed.update({'likes': likes + 1});
      }
    });

    likesRef.doc(post.id).collection('postLikes').doc(currentUserId).set({});

    addActivity(currentUserId, post, false, null);
  }

  static void unlikePost(String currentUserId, Post post) {
    DocumentReference postDocProfile =
        postsRef.doc(post.authorId).collection('userPosts').doc(post.id);
    postDocProfile.get().then((doc) {
      int likes = doc['likes'];
      postDocProfile.update({'likes': likes - 1});
    });

    DocumentReference postDocFeed =
        feedRefs.doc(currentUserId).collection('userFeed').doc(post.id);
    postDocFeed.get().then((doc) {
      if (doc.exists) {
        int likes = doc['likes'];
        postDocFeed.update({'likes': likes - 1});
      }
    });

    likesRef
        .doc(post.id)
        .collection('postLikes')
        .doc(currentUserId)
        .get()
        .then((doc) => doc.reference.delete());
  }

  static Future<bool> isLikePost(String currentUserId, Post post) async {
    DocumentSnapshot userDoc = await likesRef
        .doc(post.id)
        .collection('postLikes')
        .doc(currentUserId)
        .get();

    return userDoc.exists;
  }

  static Future<List<Activity>> getActivities(String userId) async {
    QuerySnapshot userActivitiesSnapshot = await activitiesRef
        .doc(userId)
        .collection('userActivities')
        .orderBy('timestamp', descending: true)
        .get();
    List<Activity> activities = userActivitiesSnapshot.docs
        .map((doc) => Activity.fromDoc(doc))
        .toList();
    return activities;
  }

  static void addActivity(
      String currentUserId, Post post, bool follow, String followedUserId) {
    if (follow) {
      activitiesRef.doc(followedUserId).collection('userActivities').add({
        'fromUserId': currentUserId,
        'timestamp': Timestamp.fromDate(DateTime.now()),
        'follow': true,
      });
    } else {
      // like
      activitiesRef.doc(post.authorId).collection('userActivities').add({
        'fromUserId': currentUserId,
        'timestamp': Timestamp.fromDate(DateTime.now()),
        'follow': false,
      });
    }
  }

  @override
  Future<bool> updateUserName(String userID, String yeniUserName)async {
    var users = await usersRef.where("userName",isEqualTo: yeniUserName).get();
    if(users.docs.length >= 1){
      return false;
    }else{
      await usersRef.doc(userID).update({'userName':yeniUserName});
      return true;
    }
  }
  // groupsRef.doc(group['createdAt'].toString().substring(0,23))
  @override
  Future<bool> updateGroupName(QueryDocumentSnapshot group, String yeniUserName) async{
    var users = await groupsRef.where("groupName",isEqualTo: yeniUserName).get();
    if(users.docs.length >= 1){
      return false;
    }else{
      await groupsRef.doc(group['createdAt'].toString().substring(0,23)).update({'groupName':yeniUserName});
      return true;
    }
  }
}
