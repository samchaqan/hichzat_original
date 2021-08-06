import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hichzat/Constants/Constants.dart';
import 'package:hichzat/Widgets/PostContainer.dart';
import 'package:hichzat/model/Post.dart';
import 'package:hichzat/model/user.dart';
import 'package:hichzat/services/firestore_db_service.dart';
import 'package:hichzat/viewmodel/user_model.dart';
import 'package:provider/provider.dart';

import 'EditProfileScreen.dart';

class ProfileScreeen extends StatefulWidget {

  final String currentUserId;
  final String visitedUserId;
  final Uzer authorName;


  ProfileScreeen({Key key, this.currentUserId, this.visitedUserId,this.authorName}) : super(key: key);

  @override
  _ProfileScreeenState createState() => _ProfileScreeenState();
}

class _ProfileScreeenState extends State<ProfileScreeen> {

  int _followersCount = 0;
  int _followingCount = 0;
  bool _isFollowing = false;
  int _profileSegmentedValue = 0;
  List<Post> _allPosts=[];
  List<Post> _mediaPosts=[];

  getFollowersCount() async {
    final _userModel = Provider.of<UserModel>(context, listen: false);
    int followersCount =
    await FirestoreDBService().followersNum(_userModel.user.userID);
    if (mounted) {
      setState(() {
        _followersCount = followersCount;
      });
    }
  }

  getFollowingCount() async {
    final _userModel = Provider.of<UserModel>(context, listen: false);
    int followingCount =
    await FirestoreDBService().followingNum(_userModel.user.userID);
    if (mounted) {
      setState(() {
        _followingCount = followingCount;
      });
    }
  }

  Widget BuildProfileWidgets(Uzer author) {
    switch (_profileSegmentedValue) {
      case 0:
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _allPosts.length,
          itemBuilder: (context,index){
            return PostContainer(
              currentUserId: widget.currentUserId,
              author:author,
              post:_allPosts[index],
            );
          },
        );

        break;
      case 1:
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _mediaPosts.length,
          itemBuilder: (context,index){
            return PostContainer(
              currentUserId: widget.currentUserId,
              author:author,
              post:_mediaPosts[index],

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

  followOrUnFollow(){
    if(_isFollowing){
      unFollowUser();
    }else{
      FollowUser();
    }
  }

  unFollowUser(){
    FirestoreDBService.unFollowUser(widget.currentUserId,widget.visitedUserId);
    setState(() {
      _isFollowing = false;
      _followersCount--;
    });
  }
  FollowUser(){
    FirestoreDBService.followUser(widget.currentUserId,widget.visitedUserId);
    setState(() {
      _isFollowing = true;
      _followersCount++;
    });
  }

  setupIsFollowing()async{
    bool isFollowingThisUser = await FirestoreDBService.isFollowingUser(widget.currentUserId,widget.visitedUserId);
    setState(() {
      _isFollowing = isFollowingThisUser;
    });
  }

  getAllPosts() async {
    List<Post> userPosts =
    await FirestoreDBService.getUserPosts(widget.visitedUserId);
    if (mounted) {
      setState(() {
        _allPosts = userPosts;
        _mediaPosts =
            _allPosts.where((element) => element.image.isNotEmpty).toList();
      });
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getFollowingCount();
    getFollowersCount();
    setupIsFollowing();
    getAllPosts();
  }

  Future<bool> _cikisYap(BuildContext context) async {
    final _userModel = Provider.of<UserModel>(context, listen: false);
    bool sonuc = await _userModel.signOut();
    return sonuc;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: FutureBuilder(
          future: usersRef.doc(widget.visitedUserId).get(),
          // actually visiteduserid
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
                            image: NetworkImage(_user.coverImage))),
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
                                  : NetworkImage(_user.profilURL),
                              backgroundColor: Colors.white,
                            ),
                          ),
                          widget.currentUserId == widget.visitedUserId  ? GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProfileScreen(
                                    user: _user,
                                  ),
                                ),
                              );
                              setState(() {});
                            },
                            child: Container(
                              width: 100,
                              height: 35,
                              padding: EdgeInsets.symmetric(horizontal: 10),
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
                          ) :
                          GestureDetector(
                            onTap: followOrUnFollow,
                            child: Container(
                              width: 100,
                              height: 35,
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: _isFollowing ? KTweeterColor : Colors.white,
                                border: Border.all(color: KTweeterColor),
                              ),
                              child: Center(
                                child: Text(
                                  _isFollowing ?'Takipte' : 'Takip et',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: _isFollowing ? Colors.white : KTweeterColor,
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
                        _user.userName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        _user.bio,
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
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: CupertinoSlidingSegmentedControl(
                          groupValue: _profileSegmentedValue,
                          thumbColor: Colors.black,
                          backgroundColor: Colors.grey,
                          children: _profileTabs,
                          onValueChanged: (i) {
                            setState(() {
                              _profileSegmentedValue = i;
                            });
                          },
                        ),
                      ),
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
