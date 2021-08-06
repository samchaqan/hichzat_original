import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hichzat/Constants/Constants.dart';
import 'package:hichzat/app/replies.dart';
import 'package:hichzat/model/Post.dart';
import 'package:hichzat/model/user.dart';
import 'package:hichzat/services/firestore_db_service.dart';

class PostContainer extends StatefulWidget {
  final Post post;
  final Uzer author;
  final String currentUserId;
  final String visitedUserId;

  PostContainer({Key key, this.post, this.author, this.currentUserId, this.visitedUserId})
      : super(key: key);

  @override
  _PostContainerState createState() => _PostContainerState();
}

class _PostContainerState extends State<PostContainer> {
  int _likesCount = 0;
  bool _isLiked = false;



  initPostLikes() async {
    bool isLiked =
        await FirestoreDBService.isLikePost(widget.currentUserId, widget.post);
    if(mounted){
      setState(() {
        _isLiked = isLiked;
      });
    }
  }


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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                widget.post.timestamp.toDate().toString().substring(0, 19),
                style: TextStyle(color: Colors.grey),
              ),
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
                width: 65,
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
                              _isLiked ?Icons.thumb_up  :Icons.thumb_up_alt_outlined,
                              color: _isLiked? Colors.red:Colors.black,
                            ),
                            onPressed: ()=>likePost(),
                          ),
                          Text(_likesCount.toString()),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.chat_bubble_outline),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => Replies(
                                    post: widget.post,currentUserId: widget.currentUserId,author: widget.author,
                                  )));
                            },
                          ),
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
    );
  }
}
