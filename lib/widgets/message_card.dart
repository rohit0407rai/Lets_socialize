
import 'package:dio/dio.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wechat/helper/dialogs.dart';
import 'package:wechat/helper/my_date_util.dart';

import '../api/apis.dart';
import '../models/message.dart';

class MessageCard extends StatefulWidget {
  final Message message;

  const MessageCard({super.key, required this.message});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    Size mq = MediaQuery.sizeOf(context);
    bool isMe = APIs.user.uid == widget.message.fromId;
    return InkWell(
      onLongPress: () {
        _showBottomSheet(context, isMe);
      },
      child: isMe ? _greenMessage(context) : _blueMessage(context),
    );
  }

  Widget _blueMessage(BuildContext context) {
    //update last read message if sender and receiver are different
    if (widget.message.read.isEmpty) {
      APIs.updateMessageSentReadStatus(widget.message);
      print('message read updated');
    }
    Size mq = MediaQuery.sizeOf(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 221, 245, 255),
                border: Border.all(color: Colors.lightBlue),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                        imageUrl: widget.message.msg,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                        errorWidget: (context, url, error) => const Icon(
                              Icons.image,
                              size: 70,
                            )),
                  ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: mq.width * .04),
          child: Text(
            MyDateUtil.getFormattedTime(
                context: context, time: widget.message.sent),
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  Widget _greenMessage(BuildContext context) {
    Size mq = MediaQuery.sizeOf(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: mq.width * 0.04,
            ),
            if (widget.message.read.isNotEmpty) ...[
              Icon(
                Icons.done_all_rounded,
                color: Colors.blue,
                size: 20,
              ),
            ] else ...[
              Icon(
                Icons.done_all_rounded,
                color: Colors.grey,
                size: 20,
              ),
            ],
            const SizedBox(
              width: 2,
            ),
            Text(
              MyDateUtil.getFormattedTime(
                  context: context, time: widget.message.sent),
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 218, 255, 176),
                border: Border.all(color: Colors.lightGreen),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30))),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                        imageUrl: widget.message.msg,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                        errorWidget: (context, url, error) => const Icon(
                              Icons.image,
                              size: 70,
                            )),
                  ),
          ),
        ),
      ],
    );
  }

  void _showBottomSheet(BuildContext ctx, bool isMe) {
    Size mq = MediaQuery.sizeOf(ctx);
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(20), topLeft: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: mq.height * .015, horizontal: mq.width * .4),
                decoration: const BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20))),
              ),
              widget.message.type == Type.text
                  ? _OptionItem(
                      icon: const Icon(
                        Icons.copy_all_rounded,
                        color: Colors.blue,
                        size: 26,
                      ),
                      name: 'Copy Text',
                      onTap: () async {
                        print("Rojiyt");
                        await Clipboard.setData(ClipboardData(text: widget.message.msg )).then((value) {
                          Navigator.pop(context);
                          Dialogs.showsnackbar(context, 'Text Copied', Colors.grey);
                        });
                      },
                    )
                  : _OptionItem(
                      icon: const Icon(
                        Icons.download_rounded,
                        color: Colors.blue,
                        size: 26,
                      ),
                      name: 'Save Image',
                      onTap: () async {
                        // print(widget.message.msg);
                        // var response = await Dio().get(
                        //    widget.message.msg,
                        //     options: Options(responseType: ResponseType.bytes));
                        // print(response);
                        // final result = await ImageGallerySaver.saveImage(
                        //     Uint8List.fromList(response.data),
                        //     quality: 60,
                        //     name: "hello");
                        // print(result);

                      },
                    ),
              Divider(
                color: Colors.black54,
                endIndent: mq.width * 0.04,
                indent: mq.width * 0.04,
              ),
              if (widget.message.type == Type.text && isMe)
                _OptionItem(
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.blue,
                    size: 26,
                  ),
                  name: 'Edit Message',
                  onTap: () {
                    Navigator.pop(context);
                    _showMessageUpdateDialog();
                  },
                ),
              if (isMe)
                _OptionItem(
                  icon: const Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                    size: 26,
                  ),
                  name: 'Delete Message',
                  onTap: () async {
                    await APIs.deleteMessage(widget.message).then((value) {
                      Navigator.pop(context);
                    });
                  },
                ),
              if (isMe)
                Divider(
                  color: Colors.black54,
                  endIndent: mq.width * 0.04,
                  indent: mq.width * 0.04,
                ),

              _OptionItem(
                icon: const Icon(
                  Icons.remove_red_eye,
                  color: Colors.blue,
                ),
                name: 'Sent At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}',
                onTap: () {

                },
              ),
              _OptionItem(
                icon: const Icon(
                  Icons.remove_red_eye,
                  color: Colors.green,
                  size: 26,
                ),
                name: widget.message.read.isEmpty?"Read At: Not Seen Yet":'Read At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}',
                onTap: () {},
              )
            ],
          );
        });
  }

  void _showMessageUpdateDialog() {
    String updatedMsg=widget.message.msg;
    showDialog(context: context, builder: (_)=>AlertDialog(
      title: Row(children: [
        Icon(Icons.message, color: Colors.blue, size: 28,), SizedBox(width:5),Text('Update Message')
      ],),
      content: TextFormField(
        initialValue: updatedMsg,
        onChanged: (value)=>updatedMsg=value,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15)
          ),

        ),
      ),
      actions: [
        MaterialButton(onPressed: (){
          Navigator.pop(context);
        },child:Text('Cancel', style: TextStyle(color: Colors.blue, fontSize: 16),) ,),
        MaterialButton(onPressed: (){
          APIs.updateMessage(widget.message, updatedMsg).then((value) {
            Navigator.pop(context);
          });
        },child:Text('Update', style: TextStyle(color: Colors.blue, fontSize: 16),) ,),
      ],
    ));
  }
}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Size mq = MediaQuery.sizeOf(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(
            left: mq.width * .05,
            top: mq.height * 0.015,
            bottom: mq.height * 0.015),
        child: Row(
          children: [
            icon,
            Flexible(
                child: Text(
              "   $name",
              style: const TextStyle(
                  fontSize: 15, color: Colors.black54, letterSpacing: 0.5),
            ))
          ],
        ),
      ),
    );
  }
}
