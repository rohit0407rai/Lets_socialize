import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wechat/screens/view_profile_screen.dart';

import '../../models/chat_user.dart';
class ProfileDialog extends StatelessWidget {
  final ChatUser user;
  const ProfileDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    Size mq = MediaQuery.sizeOf(context);
    return AlertDialog(
      contentPadding: EdgeInsets.all(0),
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        width: mq.width*0.6,
        height: mq.height*0.35,
        child: Stack(
          children: [
            Positioned(
              top: mq.height*0.075,
              left: mq.width*0.13,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(mq.height* .25),
                child: CachedNetworkImage(
                  width: mq.width *0.5,
                  fit: BoxFit.cover,
                  imageUrl: user.image,
                  placeholder: (context,url)=>const CircularProgressIndicator(),
                  errorWidget: (context,url,error)=>const CircleAvatar(child: Icon(Icons.person),),
                ),
              ),
            ),
            Positioned(
              left: mq.width*.04,
                top: mq.height*.02,
                width: mq.width *.55,
                child: Text(user.name,style: const TextStyle(fontSize: 18,fontWeight: FontWeight.w500),)),

            Positioned(
              right: 8,
              top: 6,
              child: MaterialButton(
                shape: CircleBorder(),
                padding: EdgeInsets.all(0),
                minWidth: 0,
                onPressed: (){
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_)=>ViewProfileScreen(user: user)));
                },child: Icon(Icons.info_outline),),
            )
          ],
        ),
      ),
    );
  }
}
