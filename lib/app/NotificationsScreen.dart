import 'package:flutter/material.dart';
import 'package:hichzat/Constants/Constants.dart';
import 'package:hichzat/model/Activity.dart';
import 'package:hichzat/model/user.dart';
import 'package:hichzat/services/firestore_db_service.dart';

class NotificationsScreen extends StatefulWidget {
  final String currentUserId;

  const NotificationsScreen({Key key, this.currentUserId}) : super(key: key);
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {

  List<Activity> _activities = [];

  setupActivities()async{
    List<Activity> activities = await FirestoreDBService.getActivities(widget.currentUserId);
    if(mounted){
      setState(() {
        _activities = activities;
      });
    }
  }

  buildActivity(Activity activity){
    return FutureBuilder(
      future: usersRef.doc(activity.fromUserId).get(),
      builder: (BuildContext context,AsyncSnapshot snapshot){
        if(!snapshot.hasData){
          return SizedBox.shrink();
        }else{
          Uzer user = Uzer.fromDoc(snapshot.data);
          return Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  radius: 20,
                  backgroundImage: user.profilURL.isEmpty ?
                  AssetImage('lib/assets/placeholder.png'):
                  NetworkImage(user.profilURL),
                ),
                title: activity.follow == true?
                Text('${user.userName} Sizi takip etti'):
                Text('${user.userName} Gönderinizi Beğendi'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Divider(
                  color: KTweeterColor,
                  thickness: 1,
                ),
              ),
            ],
          );
        }
      },
    );
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setupActivities();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade200,
        title: Text(
          'Bildirimler',
          style: TextStyle(color: Colors.red,fontSize: 20,fontWeight: FontWeight.bold),
        ),
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
      ),
      backgroundColor: Colors.grey.shade200,
      body: RefreshIndicator(
        onRefresh: ()=> setupActivities(),
        child: ListView.builder(
          itemCount: _activities.length,
          itemBuilder: (BuildContext context,int index){
            Activity activity = _activities[index];
            return buildActivity(activity);
          },
        ),
      ),
    );
  }
}

