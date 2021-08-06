import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hichzat/Constants/Constants.dart';
import 'package:hichzat/Widgets/PostContainer.dart';
import 'package:hichzat/app/GroupPage.dart';
import 'package:hichzat/app/createGroup.dart';
import 'package:hichzat/app/profilescreen.dart';
import 'package:hichzat/model/Group.dart';
import 'package:hichzat/model/Post.dart';
import 'package:hichzat/model/user.dart';
import 'package:hichzat/services/firestore_db_service.dart';
import 'package:hichzat/viewmodel/user_model.dart';
import 'package:provider/provider.dart';

import 'CreatePostScreen.dart';
import 'EditProfileScreen.dart';
import 'NotificationsScreen.dart';

class HomePage extends StatefulWidget {
  final String currentUserId;
  final String visitedUserId;

  const HomePage({Key key, @required this.currentUserId, this.visitedUserId})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  TabController tabController;
  int _followersCount = 0;
  int _followingCount = 0;
  int _profileSegmentedValue = 0;
  List<Post> _allPosts = [];
  List<Post> _mediaPosts = [];

  List _followingPosts = [];
  bool _loading = false;

  buildPosts(Post post, Uzer author) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: PostContainer(
        post: post,
        author: author,
        currentUserId: widget.currentUserId,
        visitedUserId: widget.visitedUserId,
      ),
    );
  }

  showFollowingPosts(String currentUserId) {
    List<Widget> followingPostsList = [];
    for (Post post in _followingPosts) {
      followingPostsList.add(FutureBuilder(
        future: usersRef.doc(post.authorId).get(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            Uzer author = Uzer.fromDoc(snapshot.data);
            return buildPosts(post, author);
          } else {
            return SizedBox.shrink();
          }
        },
      ));
    }

    return followingPostsList;
  }

  setupFollowingPosts() async {
    setState(() {
      _loading = true;
    });
    List followingPosts =
        await FirestoreDBService.getHomePosts(widget.currentUserId);
    if (mounted) {
      setState(() {
        _followingPosts = followingPosts;
        _loading = false;
      });
    }
  }

  Future<QuerySnapshot> _users;

  TextEditingController _searchController = TextEditingController();

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    getFollowingCount();
    getFollowersCount();
    getAllPosts();
    setupFollowingPosts();
  }

  clearSearch() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _searchController.clear());
    setState(() {
      _users = null;
    });
  }

  buildUserTile(Uzer user) {
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundImage: user.profilURL.isEmpty
            ? AssetImage('lib/assets/placeholder.png')
            : NetworkImage(user.profilURL),
      ),
      title: Text(user.userName),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ProfileScreeen(
                  currentUserId: widget.currentUserId,
                  visitedUserId: user.userID,
                )));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => CreatePostScreen(
                    currentUserId: widget.currentUserId,
                  )));
        },
      ),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        bottom: tabBars(),
        actions: [
          IconButton(
              icon: Icon(
                Icons.favorite,
                color: KTweeterColor,
              ),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => NotificationsScreen(
                          currentUserId: widget.currentUserId,
                        )));
              }),
          IconButton(
              icon: Icon(
                Icons.account_circle,
                color: KTweeterColor,
              ),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ProfileScreeen(
                          currentUserId: widget.currentUserId,
                          visitedUserId: widget.visitedUserId,
                        )));
              }),
        ],
        backgroundColor: Colors.grey.shade200,
        title: Text(
          'Hichzat',
          style: TextStyle(color: Colors.red),
        ),
      ),
      backgroundColor: Colors.grey.shade200,
      body: TabBarView(
        controller: tabController,
        children: [
          // PAGES /////////////////////////////////////////

          // main section
          RefreshIndicator(
            onRefresh: () => setupFollowingPosts(),
            child: ListView(
              physics: BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              children: [
                _loading ? LinearProgressIndicator() : SizedBox.shrink(),
                SizedBox(
                  height: 5,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 5,
                    ),
                    Column(
                      children: _followingPosts.isEmpty && _loading == false
                          ? [
                              SizedBox(
                                height: 5,
                              ),
                              Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 25),
                                  child: Text(
                                    'There is no new Post ',
                                    style: TextStyle(fontSize: 20),
                                  ))
                            ]
                          : showFollowingPosts(widget.currentUserId),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Groups section
          SingleChildScrollView(
            child: Container(
              color: Colors.grey.shade200,
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 30,
                    height: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black26,
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Ara Hichzat...',
                        hintStyle: TextStyle(color: Colors.white),
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            clearSearch();
                          },
                        ),
                        filled: true,
                      ),
                      onChanged: (input) {
                        if (input.isNotEmpty) {
                          setState(() {
                            _users = FirestoreDBService.searchUsers(input);
                          });
                        }
                      },
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      cursorColor: Colors.white.withOpacity(0.3),
                    ),
                  ),

                  // REAL GROUPS SECTION
                  _users == null
                      ? FutureBuilder(
                          future: usersRef.doc(widget.visitedUserId).get(),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (!snapshot.hasData) {
                              return Center(
                                child: CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation(KTweeterColor),
                                ),
                              );
                            }
                            Uzer _user = Uzer.fromDoc(snapshot.data);
                            return Column(
                              children: [
                                RaisedButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CreateGroupPage(
                                                  user: _user,
                                                  currentUserId:
                                                      widget.currentUserId,
                                                )));
                                  },
                                  child: Text('Grup Oluştur'),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                StreamBuilder(
                                  // final groupsRef = _fireStore.collection('groups');
                                  stream: groupsRef.snapshots(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<QuerySnapshot> snapshot) {
                                    if (!snapshot.hasData) {
                                      return Center(
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation(
                                              KTweeterColor),
                                        ),
                                      );
                                    }
                                    return SafeArea(
                                      child: Column(
                                        children:
                                            snapshot.data.docs.map((document) {
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Card(
                                              child: ListTile(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              GroupPage(
                                                                currentUserId:
                                                                    widget
                                                                        .currentUserId,
                                                                visitedUserId:
                                                                    _user
                                                                        .userID,
                                                                group: document,
                                                              )));
                                                },
                                                leading: CircleAvatar(
                                                  backgroundImage: NetworkImage(
                                                      document[
                                                          'groupPorfilephoto']),
                                                  radius: 30,
                                                ),
                                                title:
                                                    Text(document['groupName']),
                                                subtitle:
                                                    Text(document['groupBio']),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    );
                                  },
                                )
                              ],
                            );
                          },
                        )
                      : FutureBuilder(
                          future: _users,
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (!snapshot.hasData) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.data.docs.length == 0) {
                              return Center(
                                child: Text('Böyle birisi yok'),
                              );
                            }
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data.docs.length,
                              itemBuilder: (BuildContext context, int index) {
                                Uzer user =
                                    Uzer.fromDoc(snapshot.data.docs[index]);
                                return buildUserTile(user);
                              },
                            );
                          }),
                ],
              ),
            ),
          ),

          // Profile section
        ],
      ),
    );
  }

  TabBar tabBars() {
    return TabBar(
      controller: tabController,
      tabs: [
        Tab(
          icon: Icon(
            Icons.home,
            color: Colors.red,
          ),
        ),
        Tab(
          icon: Icon(
            Icons.group_sharp,
            color: Colors.red,
          ),
        ),
      ],
    );
  }
}
