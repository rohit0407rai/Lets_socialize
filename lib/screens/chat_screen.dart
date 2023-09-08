import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wechat/helper/my_date_util.dart';
import 'package:wechat/models/chat_user.dart';
import 'package:wechat/screens/view_profile_screen.dart';
import 'package:wechat/widgets/message_card.dart';

import '../api/apis.dart';
import '../models/message.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;

  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> list = [];
  bool showEmoji = false;
  String? _image;
  bool isUploading=false;
  final TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size mq = MediaQuery.sizeOf(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            if (showEmoji) {
              setState(() {
                showEmoji = false;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            backgroundColor: const Color.fromARGB(255, 234, 248, 255),
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(context),
            ),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: APIs.getAllMessages(widget.user),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const Center(
                            child: SizedBox(),
                          );
                        case ConnectionState.active:
                        case ConnectionState.done:
                          // final data = snapshot.data?.docs;
                          // print('data is here ${jsonEncode(data![0].data())}');
                          // list=data?.map((e) =>Message.fromJson(e.data())).toList()??[];
                          final data = snapshot.data?.docs;
                          print(data);
                          if (data != null && data.isNotEmpty) {
                            list = data
                                .map((e) => Message.fromJson(e.data()))
                                .toList();
                          }
                          if (list.isNotEmpty) {
                            return ListView.builder(
                              reverse:true,
                                padding: EdgeInsets.only(top: mq.height * 0.01),
                                itemCount: list.length,
                                physics: BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  // return ChatUserCard();
                                  return MessageCard(
                                    message: list[index],
                                  );
                                });
                          } else {
                            return const Center(
                              child: Text(
                                'Say Hi! 👋',
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            );
                          }
                      }
                    },
                  ),
                ),
                if(isUploading)
                const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                        child: CircularProgressIndicator(strokeWidth: 2,))),
                _chatInput(context),
                if (showEmoji)
                  SizedBox(
                    height: mq.height * 0.35,
                    child: EmojiPicker(
                      textEditingController: textEditingController,

                      // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
                      config: Config(
                        bgColor: const Color.fromARGB(255, 234, 248, 255),
                        initCategory: Category.RECENT,
                        columns: 7,
                        emojiSizeMax: 32 *
                            (Platform.isIOS
                                ? 1.30
                                : 1.0), // Issue: https://github.com/flutter/flutter/issues/28894
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar(BuildContext context) {
    Size mq = MediaQuery.sizeOf(context);
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_)=>ViewProfileScreen(user: widget.user,)));
      },
      child: StreamBuilder(
        stream: APIs.getUserInfo(widget.user),
        builder:(context,snapshot){
          final data=snapshot.data?.docs;
          final list=data?.map((e)=>ChatUser.fromJson(e.data())).toList()??[];

          return Row(
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black54,
                  )),
              ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .03),
                child: CachedNetworkImage(
                  width: mq.height * 0.05,
                  height: mq.height * 0.05,
                  imageUrl: list.isNotEmpty?list[0].image: widget.user.image,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(list.isNotEmpty?list[0].name:
                    widget.user.name,
                    style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: mq.height * .002,
                  ),
                  Text(
                    list.isNotEmpty? list[0].isOnline?'Online':MyDateUtil().getLastActiveTime(context: context,lastActive: list[0].lastActive):MyDateUtil().getLastActiveTime(context: context, lastActive: widget.user.lastActive),
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  )
                ],
              )
            ],
          );
        }
      )
    );
  }

  Widget _chatInput(BuildContext context) {
    Size mq = MediaQuery.sizeOf(context);
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * .01, horizontal: mq.width * .025),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          showEmoji = !showEmoji;
                        });
                      },
                      icon: const Icon(
                        Icons.emoji_emotions,
                        color: Colors.blueAccent,
                        size: 25,
                      )),
                  Expanded(
                      child: TextField(
                    controller: textEditingController,
                    keyboardType: TextInputType.multiline,
                    onTap: () {
                      if (showEmoji)
                        setState(() {
                          showEmoji = false;
                        });
                    },
                    maxLines: null,
                    decoration: const InputDecoration(
                        hintText: 'Type Something...',
                        hintStyle: TextStyle(color: Colors.blueAccent),
                        border: InputBorder.none),
                  )),
                  IconButton(
                      onPressed: () async{
                        final ImagePicker _picker = ImagePicker();
                        final List<XFile> image = await _picker.pickMultiImage(
                             imageQuality: 70);
                        if (image.isNotEmpty) {
                          for(var i in image){
                            print('IMage Path : ${i.path}');
                            setState(() {
                              isUploading=true;
                            });
                            await APIs.sendChatImage(widget.user, File(i.path)).then((value) {setState(() {
                              isUploading=false;

                            });});

                          }
                        }
                      },
                      icon: const Icon(
                        Icons.image,
                        color: Colors.blueAccent,
                        size: 26,
                      )),
                  IconButton(
                      onPressed: () async {
                        final ImagePicker _picker = ImagePicker();
                        final XFile? image = await _picker.pickImage(
                            source: ImageSource.camera, imageQuality: 70);
                        if (image != null) {
                          print('IMage Path : ${image.path}');
                          await APIs.sendChatImage(widget.user, File(image.path));
                        }
                      },
                      icon: const Icon(
                        Icons.camera,
                        color: Colors.blueAccent,
                        size: 26,
                      )),
                  SizedBox(
                    width: mq.width * .02,
                  )
                ],
              ),
            ),
          ),
          MaterialButton(
            shape: const CircleBorder(),
            minWidth: 0,
            padding: EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            color: Colors.green,
            onPressed: () {
              if (textEditingController.text.isNotEmpty) {
                if(list.isEmpty){
                  APIs.sendFirstMessage(
                      widget.user, textEditingController.text, Type.text);
                }else{
                APIs.sendMessage(
                    widget.user, textEditingController.text, Type.text);
                textEditingController.text = '';}
              }
            },
            child: const Icon(
              Icons.send,
              color: Colors.white,
              size: 28,
            ),
          )
        ],
      ),
    );
  }
}
