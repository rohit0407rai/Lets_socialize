import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wechat/api/apis.dart';
import 'package:wechat/screens/auth/login_screen.dart';
import 'package:wechat/screens/profile_screen.dart';
import 'package:wechat/widgets/chat_user_card.dart';

import '../helper/dialogs.dart';
import '../models/chat_user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser>list=[];
  final List<ChatUser> searchList=[];
  bool _isSearching=false;
  String? k;

  @override
  void initState() {
    super.initState();
    APIs.userInfo();
    SystemChannels.lifecycle.setMessageHandler((msg) {
      print("duniya");
      log("message: $msg");
      if(APIs.auth.currentUser!=null){
      if (msg.toString().contains('pause')) APIs.updateActiveStatus(false);
      if (msg.toString().contains('resume')) APIs.updateActiveStatus(true);}

      return Future.value(msg);
    });

  }

  @override
  Widget build(BuildContext context) {
    Size mq = MediaQuery.sizeOf(context);
    if(k!=null){
      print(k);
    }
    print("hellp");
    return WillPopScope(
      onWillPop: (){
        if(_isSearching){
          setState(() {
            _isSearching=false;

          });

          return Future.value(false);
        }else{

          return Future.value(true);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: _isSearching? TextField(
            onChanged: (val){
              searchList.clear();
              for(var i in list){
                if(i.name.toLowerCase().contains(val.toLowerCase())|| i.email.toLowerCase().contains(val.toLowerCase())){
                  setState(() {
                    searchList.add(i);
                  });
                }
              }
            },
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Name, Email,...',
            ),
            style: TextStyle(fontSize: 16, letterSpacing: 0.5),
            autofocus: true,

          ) :Text('We Chat'),
          leading: const Icon(
            CupertinoIcons.home,
            color: Colors.black,
          ),
          actions: [
            IconButton(onPressed: () {
              setState(() {
                _isSearching=!_isSearching;
              });
              if(_isSearching==false){
                searchList.clear();
              }

            }, icon: Icon(_isSearching?CupertinoIcons.clear_circled_solid:Icons.search)),
            IconButton(onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_)=>ProfileScreen(user: APIs.me,)));
            }, icon: const Icon(Icons.more_vert))
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
             _addChatUserDialog();
          },
          child: const Icon(Icons.add_comment_rounded),
        ),
        body: StreamBuilder(
          stream: APIs.getMyUsersId(),
          builder: (context, snapshot){
    switch (snapshot.connectionState) {
      case ConnectionState.waiting:
      case ConnectionState.none:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case ConnectionState.active:
      case ConnectionState.done:
        return StreamBuilder(
          stream: APIs.getAllUsers(
              snapshot.data?.docs.map((e) => e.id).toList() ?? []),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.none:
                return const Center(
                  child: CircularProgressIndicator(),
                );
              case ConnectionState.active:
              case ConnectionState.done:
                final data = snapshot.data?.docs;
                list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ??
                    [];
                if (list.isNotEmpty) {
                  return ListView.builder(
                      padding: EdgeInsets.only(top: mq.height * 0.01),
                      itemCount: _isSearching ? searchList.length : list.length,
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        // return ChatUserCard();
                        return ChatUserCard(user: _isSearching
                            ? searchList[index]
                            : list[index]);
                      });
                } else {
                  return const Center(
                    child: Text('No Connections Found', style: TextStyle(
                        fontSize: 20, color: Colors.pinkAccent),),);
                }
            }
          },
        );
    }
          },
        )
      ),
    );
  }
  void _addChatUserDialog() {
    String email="";
    showDialog(context: context, builder: (_)=>AlertDialog(
      title: Row(children: [
        Icon(Icons.person_add, color: Colors.blue, size: 28,), SizedBox(width:5),Text('Add User')
      ],),
      content: TextFormField(
        initialValue: email,
        maxLines: null,
        onChanged: (value)=>email=value,
        decoration: InputDecoration(
          hintText: "Email Id",
          prefixIcon: Icon(Icons.email, color: Colors.blue,),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),

          ),

        ),
      ),
      actions: [
        MaterialButton(onPressed: (){
          Navigator.pop(context);
        },child:Text('Cancel', style: TextStyle(color: Colors.blue, fontSize: 16),) ,),
        MaterialButton(onPressed: ()async{
          if(email.isNotEmpty){
            await APIs.addChatUser(email).then((value) {
              if(!value){
                Dialogs.showsnackbar(context, "User does not exist", Colors.red);
              }
            });
          }
        },child:Text('Add', style: TextStyle(color: Colors.blue, fontSize: 16),) ,),
      ],
    ));
  }
}
