import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hichzat/Constants/Constants.dart';
import 'package:hichzat/Widgets/PostContainer.dart';
import 'package:hichzat/app/CreatePostInGroup.dart';
import 'package:hichzat/app/EditGroupScreen.dart';
import 'package:hichzat/model/Post.dart';
import 'package:hichzat/model/user.dart';
import 'package:hichzat/services/firestore_db_service.dart';
import 'package:hichzat/viewmodel/user_model.dart';
import 'package:provider/provider.dart';

class GroupPage extends StatefulWidget {
  final String currentUserId;
  final String visitedUserId;
  final QueryDocumentSnapshot group;

  const GroupPage({Key key, this.currentUserId, this.visitedUserId, this.group})
      : super(key: key);

  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  int _followersCount = 0;
  int _followingCount = 0;
  bool _isFollowing = false;
  int _profileSegmentedValue = 0;
  List<Post> _allPosts = [];
  List<Post> _mediaPosts = [];

  Future<bool> _cikisYap(BuildContext context) async {
    final _userModel = Provider.of<UserModel>(context, listen: false);
    bool sonuc = await _userModel.signOut();
    return sonuc;
  }

  followOrUnFollow() {
    if (_isFollowing) {
      unFollowUser();
    } else {
      FollowUser();
    }
  }

  unFollowUser() {
    FirestoreDBService.unFollowUser(widget.currentUserId, widget.visitedUserId);
    setState(() {
      _isFollowing = false;
      _followersCount--;
    });
  }

  FollowUser() {
    FirestoreDBService.followUser(widget.currentUserId, widget.visitedUserId);
    setState(() {
      _isFollowing = true;
      _followersCount++;
    });
  }

  Map<int, Widget> _profileTabs = <int, Widget>{
    0: Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text(
        'Gönderiler',
        style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
      ),
    ),
    1: Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text(
        'Medya',
        style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
      ),
    ),
    2: Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text(
        'Beğeniler',
        style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
      ),
    ),
  };

  Widget BuildProfileWidgets(Uzer author) {
    switch (_profileSegmentedValue) {
      case 0:
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _allPosts.length,
          itemBuilder: (context, index) {
            return PostContainer(
              currentUserId: widget.currentUserId,
              author: author,
              post: _allPosts[index],
            );
          },
        );

        break;
      case 1:
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _mediaPosts.length,
          itemBuilder: (context, index) {
            return PostContainer(
              currentUserId: widget.currentUserId,
              author: author,
              post: _mediaPosts[index],
            );
          },
        );
        break;
      case 2:
        return Center(child: Text('Beğeniler', style: TextStyle(fontSize: 25)));
        break;
      default:
        return Center(
          child: Text(
            'Bir şeyler yanlış gitti..',
            style: TextStyle(fontSize: 25),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: usersRef.doc(widget.visitedUserId).get(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(KTweeterColor),
                ),
              );
            }
            Uzer _user = Uzer.fromDoc(snapshot.data);
            return ListView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              children: [
                Material(
                  elevation: 4,
                  child: Container(
                    height: 400,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade500,
                        image: _user.coverImage.isEmpty
                            ? null
                            : DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                    widget.group['groupCoverphoto']))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox.shrink(),
                          PopupMenuButton(
                            icon: Icon(
                              Icons.more_horiz,
                              color: Colors.white,
                            ),
                            itemBuilder: (_) {
                              return <PopupMenuItem<String>>[
                                new PopupMenuItem(
                                  child: Text('Logout'),
                                  value: 'logout',
                                )
                              ];
                            },
                            onSelected: (selectedItem) {
                              _cikisYap(context);
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  transform: Matrix4.translationValues(0.0, -40.0, 0.0),
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(45),
                            child: CircleAvatar(
                              radius: 45,
                              backgroundImage: _user.profilURL.isEmpty
                                  ? AssetImage('lib/assets/placeholder.png')
                                  : NetworkImage(
                                      widget.group['groupPorfilephoto']),
                              backgroundColor: Colors.white,
                            ),
                          ),
                          _user.userID == widget.group['whocreateid']
                              ? GestureDetector(
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditGroupScreen(
                                          user: _user,
                                          group: widget.group,
                                        ),
                                      ),
                                    );
                                    setState(() {});
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 35,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.white,
                                      border: Border.all(color: KTweeterColor),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Düzenle',
                                        style: TextStyle(
                                            fontSize: 17,
                                            color: KTweeterColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: followOrUnFollow,
                                  child: Container(
                                    width: 100,
                                    height: 35,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: _isFollowing
                                          ? KTweeterColor
                                          : Colors.white,
                                      border: Border.all(color: KTweeterColor),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _isFollowing ? 'Takipte' : 'Takip et',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: _isFollowing
                                                ? Colors.white
                                                : KTweeterColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        widget.group['groupName'],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        widget.group['groupBio'],
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          Text(
                            '$_followingCount Takip',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1,
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            '$_followersCount Takipçi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),

                      /// COMMENT SECTION
                      StreamBuilder(
                          stream: groupsRef
                              .doc(widget.group['createdAt']
                                  .toString()
                                  .substring(0, 23))
                              .collection('replies')
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (!snapshot.hasData) {
                              return Center(
                                child: CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation(KTweeterColor),
                                ),
                              );
                            }
                            return SizedBox(
                              height: 400,
                              child: ListView(
                                children: snapshot.data.docs.map((document) {
                                  return   Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SafeArea(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  document['text'],
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 50,
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                  radius: 20,
                                                  backgroundImage: NetworkImage(document['whocreatethispostimage']),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                document['whocreatethispost'],
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 15,
                                                width: 95,
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Row(

                                                      ),

                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Divider(
                                            height: 5,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            );

                          }),
                    ],
                  ),
                ),
                BuildProfileWidgets(_user),
              ],
            );
          }),
    );
  }
}
