import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wechat/helper/my_date_util.dart';
import 'package:wechat/screens/chat_screen.dart';
import 'package:wechat/widgets/dialogs/profile_dialogs.dart';

import '../api/apis.dart';
import '../models/chat_user.dart';
import '../models/message.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? _message;
  @override
  Widget build(BuildContext context) {
    Size mq = MediaQuery.sizeOf(context);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15)
      ),
      color: Colors.blue.shade100,
      elevation: 1,
      margin: EdgeInsets.symmetric(horizontal: mq.width*0.04, vertical: 4),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_)=>ChatScreen(user: widget.user,)));
        },
        child:  StreamBuilder(
          stream: APIs.getLastMessage(widget.user),
          builder: (context, snapshot) {
            final data=snapshot.data?.docs;
            if (data != null && data.isNotEmpty && data.first.exists) {
              _message = Message.fromJson(data.first.data());
            } else {
              _message = null; // Handle the case when data is empty or doesn't exist
            }
            return ListTile(
              title: Text(widget.user.name),
              subtitle: Text(
                _message!=null?_message!.type==  Type.image?"Image": _message!.msg:widget.user.about,
                maxLines: 1,
              ),
              leading: InkWell(
                onTap: (){
                  showDialog(context: context, builder: (_)=>ProfileDialog(user: widget.user));
                },
                child: CircleAvatar(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height* .3),
                    child: CachedNetworkImage(
                      width: mq.height *0.55,
                      height: mq.height *0.55,
                      imageUrl: widget.user.image,
                      placeholder: (context,url)=>const CircularProgressIndicator(),
                      errorWidget: (context,url,error)=>const CircleAvatar(child: Icon(Icons.person),),
                    ),
                  ),

                ),
              ),
              trailing: _message==null?null:_message!.read.isEmpty&& _message!.fromId!=APIs.user.uid?Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                    color: Colors.greenAccent.shade400,
                    borderRadius: BorderRadius.circular(10)
                ),
              ):Text(
                MyDateUtil.getLastMessageTime(context: context, time: _message!.sent),
                style: TextStyle(color: Colors.black54),
              ),
              // trailing: Text(
              //   '12:00',
              //   style: TextStyle(color: Colors.black54),
              // ),
            );
          }
        ),
      ),
    );
  }
}
