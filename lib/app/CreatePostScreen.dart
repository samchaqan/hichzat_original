import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hichzat/Constants/Constants.dart';
import 'package:hichzat/model/Post.dart';
import 'package:hichzat/model/user.dart';
import 'package:hichzat/services/StorageService.dart';
import 'package:hichzat/services/firestore_db_service.dart';
import 'package:hichzat/viewmodel/user_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CreatePostScreen extends StatefulWidget {
  final String currentUserId;
  const CreatePostScreen({Key key, this.currentUserId}) : super(key: key);

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {

  String _postText;
  PickedFile _pickedImage;
  bool _loading = false;

  handleImageFromGallery() async {
    try {
      var _picker = ImagePicker();
      PickedFile imageFile =
          await _picker.getImage(source: ImageSource.gallery);
      if (imageFile != null) {
        setState(() {
          _pickedImage = imageFile;
        });
      }
    } catch (e) {
      print('error from handle image $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final _userModel = Provider.of<UserModel>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: KTweeterColor,
        centerTitle: true,
        title: Text(
          'Hichzat',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              TextField(
                maxLength: 280,
                maxLines: 7,
                decoration: InputDecoration(
                  hintText: 'Gönderinizi giriniz',
                ),
                onChanged: (value) {
                  _postText = value;
                },
              ),
              SizedBox(
                height: 10,
              ),
              _pickedImage == null
                  ? SizedBox.shrink()
                  : Column(
                      children: [
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: KTweeterColor,
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: FileImage(File(_pickedImage.path)),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
              GestureDetector(
                onTap: handleImageFromGallery,
                child: Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    border: Border.all(
                      color: KTweeterColor,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: 50,
                    color: KTweeterColor,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              RaisedButton(
                onPressed: () async {
                  setState(() {
                    _loading = true;
                  });
                  if (_postText != null && _postText.isNotEmpty) {
                    String image;
                    if (_pickedImage == null) {
                      image = '';
                    } else {
                      image = await StorageService.uploadPostPicture(
                          File(_pickedImage.path));
                    }

                    Post post = Post(
                      text: _postText,
                      image: image,
                      authorId: widget.currentUserId,
                      likes: 0,
                      reposts: 0,
                      dislikes: 0,
                      timestamp: Timestamp.fromDate(
                        DateTime.now(),
                      ),
                    );
                    FirestoreDBService.createPost(post);
                    Navigator.pop(context);
                  }
                  setState(() {
                    _loading = false;
                  });
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Text(
                  "Paylaş",
                  style: TextStyle(color: Colors.white),
                ),
                color: KTweeterColor,
              ),
              SizedBox(height: 20,),
              _loading?CircularProgressIndicator():SizedBox.shrink()
            ],
          ),
        ),
      ),
    );
  }
}
