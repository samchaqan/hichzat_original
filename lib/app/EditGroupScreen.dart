import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hichzat/Constants/Constants.dart';
import 'package:hichzat/Widgets/platform_duyarli_alert_dialog.dart';
import 'package:hichzat/model/Group.dart';
import 'package:hichzat/model/user.dart';
import 'package:hichzat/services/StorageService.dart';
import 'package:hichzat/services/firestore_db_service.dart';
import 'package:hichzat/viewmodel/user_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';


class EditGroupScreen extends StatefulWidget {
  final QueryDocumentSnapshot group;
  final Uzer user;

  const EditGroupScreen({Key key, this.user, this.group}) : super(key: key);

  @override
  _EditGroupScreenState createState() => _EditGroupScreenState();
}

class _EditGroupScreenState extends State<EditGroupScreen> {

  String _name;
  String _bio;
  PickedFile _profileImage;
  PickedFile _coverImage;
  String _imagePickedType;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  TextEditingController _controllerUserName = TextEditingController(text: 'Grup Adi');



  saveProfile(BuildContext context) async {
    _formKey.currentState.save();
    if(_formKey.currentState.validate() && !_isLoading){
      setState(() {
        _isLoading = true;
      });
      String profilePictureUrl = '';
      String coverPictureUrl = '';


      if(_profileImage == null){
        profilePictureUrl = widget.group['groupPorfilephoto'];
      }else{
        profilePictureUrl = await StorageService.uploadGroupPictureZ(
          File(_profileImage.path)
        );
      }

      if(_coverImage == null){
        coverPictureUrl = widget.group['groupCoverphoto'];
      }else{
        coverPictureUrl = await StorageService.uploadGroupPicture(
           File(_coverImage.path)
        );
      }

      final _userModel = Provider.of<UserModel>(context, listen: false);
      if(widget.group['groupName'] != _controllerUserName.text){
        var updateResult = await _userModel.updateGroupName(widget.group, _controllerUserName.text);

        if(updateResult == true){
          Group group = Group(
            groupName: _name,
            groupCoverphoto: coverPictureUrl,
            whocreate: widget.user.userName,
            groupBio: _bio,
            whocreateid: widget.user.userID,
            groupPorfilephoto: profilePictureUrl,
            createdAt: widget.group['createdAt'],
          );
          FirestoreDBService.updateGroupData(group);
          PlatformDuyarliAlertDialog(
            baslik: 'Basarili',
            icerik: 'Grup Ismi Degistirildi',
            anaButonYazisi: 'Tamam',
          ).goster(context);
        }else{
          PlatformDuyarliAlertDialog(
            baslik: 'Hata',
            icerik: 'Grup username Zaten kullanimda',
            anaButonYazisi: 'Tamam',
          ).goster(context);
        }


      }else{
        PlatformDuyarliAlertDialog(
          baslik: 'Hata',
          icerik: 'Grup name degisikligi yapamadiniz',
          anaButonYazisi: 'Tamam',
        ).goster(context);
        Navigator.pop(context);
      }
    }
    final _userModel = Provider.of<UserModel>(context, listen: false);
    var updateResult = await _userModel.updateGroupName(widget.group, _controllerUserName.text);
    if(updateResult == false){
      PlatformDuyarliAlertDialog(
        baslik: 'Hata',
        icerik: 'Grup Name kullanimda',
        anaButonYazisi: 'Tamam',
      ).goster(context);
      Navigator.pop(context);
    }



  }
  handleImageFromGallery() async{
    try{
      var _picker = ImagePicker();
      PickedFile imageFile = await _picker.getImage(source: ImageSource.gallery);
      if(imageFile != null){
        if(_imagePickedType == 'profile'){
          setState(() {
            _profileImage = imageFile;
          });
        }else if(_imagePickedType == 'cover'){
          setState(() {
            _coverImage = imageFile;
          });
        }
      }
    }catch(e){
      print('error in handle image from gallery $e');
    }
  }


  displayCoverImage() {
    if(_coverImage == null){
      if(widget.group['groupCoverphoto'].isNotEmpty){
        return NetworkImage(widget.group['groupCoverphoto']);
      }
    }else{
      return FileImage(File(_coverImage.path));
    }
  }

  displayProfileImage(){
    if(_profileImage == null){
      if(widget.group['groupPorfilephoto'].isEmpty){
        return AssetImage('lib/assets/defaultphoto.png');
      }else{
        return NetworkImage(widget.group['groupPorfilephoto']);
      }
    }else{
      return FileImage(File(_profileImage.path));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _name = widget.group['groupName'];
    _bio = widget.group['groupBio'];
    _controllerUserName = TextEditingController();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        children: [
          GestureDetector(
            onTap: (){
              _imagePickedType = 'cover';
              handleImageFromGallery();
            },
            child: Stack(
              children: [
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: KTweeterColor,
                    image: _coverImage == null && widget.user.coverImage.isEmpty
                        ? null
                        : DecorationImage(
                      fit: BoxFit.cover,
                      image: displayCoverImage(),
                    ),
                  ),
                ),
                Container(
                  height: 150,
                  color: Colors.black54,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt,size: 70,color: Colors.white,),
                      Text(
                        'Change Cover Photo',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            transform: Matrix4.translationValues(0, -40, 0),
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: (){
                        _imagePickedType = 'profile';
                        handleImageFromGallery();
                      },
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 45,
                            backgroundImage: displayProfileImage(),
                            backgroundColor: Colors.white,
                          ),
                          CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.black54,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Icon(Icons.camera_alt,size: 25,color: Colors.white,),
                                Text(
                                  'Profil Resmini De??i??tir',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    GestureDetector(
                      onTap: ()=>saveProfile(context),
                      child: Container(
                        width: 100,
                        height: 35,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: KTweeterColor,
                        ),
                        child: Center(
                          child: Text('Kaydet',style: TextStyle(fontSize: 17,color: Colors.white,fontWeight: FontWeight.bold),),
                        ),
                      ),
                    )
                  ],
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: 30,),
                      TextFormField(
                        controller: _controllerUserName,
                        decoration: InputDecoration(
                          labelText: '??sim',
                          labelStyle: TextStyle(color: KTweeterColor),
                        ),
                        validator: (input)=>input.trim().length<2? 'L??tfen ge??erli bir kullan??c?? ad?? giriniz' : null,
                        onSaved: (value){
                          _name= value;
                        },
                      ),
                      SizedBox(height: 30,),
                      TextFormField(
                        initialValue: _bio,
                        decoration: InputDecoration(
                          labelText: 'Bio',
                          labelStyle: TextStyle(color: KTweeterColor),
                        ),
                        onSaved: (value){
                          _bio = value;
                        },
                      ),
                      SizedBox(height: 30,),
                      _isLoading ?
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(KTweeterColor),
                      )
                          : SizedBox.shrink()
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
