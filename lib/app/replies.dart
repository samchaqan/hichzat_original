import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hichzat/Constants/Constants.dart';
import 'package:hichzat/model/Post.dart';
import 'package:hichzat/model/user.dart';
import 'package:hichzat/services/firestore_db_service.dart';
import 'package:hichzat/viewmodel/user_model.dart';
import 'package:provider/provider.dart';

class Replies extends StatefulWidget {
  final Post post;
  final Uzer author;
  final String currentUserId;


   Replies({Key key, this.post, this.author, this.currentUserId})
      : super(key: key);

  @override
  _RepliesState createState() => _RepliesState();
}

class _RepliesState extends State<Replies> {
  int _likesCount = 0;
  bool _isLiked = false;
  String text = '';
  TextEditingController _textController = TextEditingController();

  likePost() {
    if (_isLiked) {
      FirestoreDBService.unlikePost(widget.currentUserId, widget.post);
      setState(() {
        _isLiked = false;
        _likesCount--;
      });
    } else {
      FirestoreDBService.likePost(widget.currentUserId, widget.post);
      setState(() {
        _isLiked = true;
        _likesCount++;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _likesCount = widget.post.likes;
    initPostLikes();
  }

  initPostLikes() async {
    bool isLiked =
        await FirestoreDBService.isLikePost(widget.currentUserId, widget.post);
    if (mounted) {
      setState(() {
        _isLiked = isLiked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final _userModel = Provider.of<UserModel>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: Colors.red,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.grey.shade200,
        title: Text(
          widget.author.userName,
          style: TextStyle(color: Colors.red),
        ),
      ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Container(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SafeArea(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.post.text,
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 50,
                                  ),
                                  Text(
                                    widget.post.timestamp
                                        .toDate()
                                        .toString()
                                        .substring(0, 19),
                                    style: TextStyle(color: Colors.grey),
                                  )
                                ],
                              ),
                              widget.post.image.isEmpty
                                  ? SizedBox.shrink()
                                  : Column(
                                      children: [
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Container(
                                          height: 250,
                                          decoration: BoxDecoration(
                                            color: KTweeterColor,
                                            borderRadius: BorderRadius.circular(10),
                                            image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: NetworkImage(widget.post.image),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundImage: widget.author.profilURL.isEmpty
                                        ? AssetImage('lib/assets/placeholder.png')
                                        : NetworkImage(widget.author.profilURL),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    widget.author.userName,
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
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  _isLiked
                                                      ? Icons.thumb_up
                                                      : Icons.thumb_up_alt_outlined,
                                                  color: _isLiked
                                                      ? Colors.red
                                                      : Colors.black,
                                                ),
                                                onPressed: () => likePost(),
                                              ),
                                              Text(_likesCount.toString()),
                                            ],
                                          ),
                                          Row(
                                            children: [

                                            ],
                                          )
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
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Form(
                              child: TextFormField(
                                controller: _textController,
                                onChanged: (val){
                                  setState(() {
                                    text=val;
                                  });
                                },
                              ),
                            ),
                            SizedBox(height: 10,),
                            FlatButton(
                              onPressed: ()async{
                                await FirestoreDBService.reply(widget.post, text);
                                _textController.text = '';
                                setState(() {
                                  text = '';
                                });
                              },
                              child: Text('Reply'),
                              textColor: Colors.white,
                              color: KTweeterColor,
                            ),
                          ],
                        ),
                      ),

                        /// REPLIES SECTION ................


                      // Replies sections
                      StreamBuilder(
                        stream: postsRef.doc(widget.post.authorId).collection('userPosts').doc(widget.post.id).collection('replies').snapshots(),
                        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                          if(!snapshot.hasData){
                            return Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(KTweeterColor),
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
                                              backgroundImage: AssetImage('lib/assets/placeholder.png')
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              'Anonim',
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
                        }
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }
}
