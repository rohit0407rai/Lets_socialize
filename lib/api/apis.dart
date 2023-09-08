import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';
import 'package:wechat/models/chat_user.dart';

import '../models/message.dart';

class APIs {
  //authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  //cloud firstore
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  //firebase Storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  static User get user => auth.currentUser!;

  //for storing self information
  static late ChatUser me;

  static FirebaseMessaging fmessaging = FirebaseMessaging.instance;

  // for checking if user exists or not?
  static Future<bool> userExist() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  static Future<void> getFirebaseMessagingToken() async {
    await fmessaging.requestPermission();
    fmessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        log("pushToken: ${me.pushToken}");
      }
    });
    //local notification
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   print('Got a message whilst in the foreground!');
    //   print('Message data: ${message.data}');
    //
    //   if (message.notification != null) {
    //     print('Message also contained a notification: ${message.notification}');
    //   }
    // });
  }

  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final bodi = {
        "to": chatUser.pushToken,
        "notification": {
          "title": chatUser.name,
          "body": msg,
          "android_channel_id": "chats",
        },
        "data": {
          "some_data": "User ID: ${me.id}",
        }
      };
      var response =
          await post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
              headers: {
                HttpHeaders.contentTypeHeader: 'application/json',
                HttpHeaders.authorizationHeader:
                    'key=AAAAFkKfQLw:APA91bGAMpYrcz5QgGHSTcCW7lU476J_dGdgtKp9S57izj7kDWJsgUdeb5vNLT2auZMeKkLUXbgbkk81Xxuej4QphXqnjml4C8J-TEMDEc6Ne997-FUvD6-TVl8BezoYfHuxXyQP4TFI'
              },
              body: jsonEncode(bodi));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    } catch (e) {
      log("error: ${e}");
    }
  }

  //for getting current user info
  static userInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();
        APIs.updateActiveStatus(true);
      } else {
        createUser();
      }
    });
  }

  //for creating a new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatUser(
        image: user.photoURL.toString(),
        name: user.displayName.toString(),
        about: 'Hey I am talking to you using this app',
        createdAt: time,
        isOnline: false,
        id: user.uid,
        lastActive: time,
        pushToken: '',
        email: user.email.toString());
    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  //get all users
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection('users').doc(user.uid).collection('my_users')
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(List<String> userIds) {
    if (userIds.isEmpty) {
      // Return an empty stream or handle it based on your needs
      return Stream.empty();
    }

    return firestore
        .collection('users')
        .where('id', whereIn: userIds)
        .snapshots();
  }
  static Future<void> sendFirstMessage(ChatUser chatUser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(chatUser.id).collection('my_users').doc(user.uid).set({}).then((value) {
          sendMessage(chatUser, msg, type);
    });
  }


  //update user data
  static Future<void> updateUserData() async {
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'name': me.name, 'about': me.about});
  }

  static Future<void> updateProfilePicture(File file) async {
    final ext = file.path.split('.').last;
    print(ext);
    final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      print('data transfered');
    });
    me.image = await ref.getDownloadURL();
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'image': me.image});
  }

  /// message related work
  ///get Conversation Id
  /////chats(collection)0=>conversation_id (doc)=>messages(collection)=>messages(doc)
  static String getConversationId(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationId(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    print("Kiska time $time ");
    final Message message = Message(
        toId: chatUser.id,
        msg: msg,
        read: '',
        type: type,
        fromId: user.uid,
        sent: time);
    final ref = firestore
        .collection('chats/${getConversationId(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson()).then((value) {
      sendPushNotification(chatUser, type == Type.text ? msg : "Image");
    });
  }

  static Future<void> updateMessageSentReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationId(message.fromId)}/messages/')
        .doc(message.sent)
        .update({
      'read': DateTime.now().millisecondsSinceEpoch.toString(),
    });
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationId(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    final ext = file.path.split('.').last;
    print(ext);
    final ref = storage.ref().child(
        'images/${getConversationId(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      print('data transfered');
    });
    final imageUrl = await ref.getDownloadURL();
    APIs.sendMessage(chatUser, imageUrl, Type.image);
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken
    });
  }

  static Future<void> deleteMessage(Message message) async{
   await  firestore
        .collection('chats/${getConversationId(message.toId)}/messages/')
        .doc(message.sent)
        .delete();
   if (message.type==Type.image){
     await storage.refFromURL(message.msg).delete();
   }

  }
  static Future<void> updateMessage(Message message, String updateMsg) async{
    await  firestore
        .collection('chats/${getConversationId(message.toId)}/messages/')
        .doc(message.sent)
        .update({
      "msg":updateMsg,
    });
    if (message.type==Type.image){
      await storage.refFromURL(message.msg).delete();
    }

  }

  static Future<bool> addChatUser(String email) async{
    final data=await firestore.collection('users').where('email',isEqualTo: email).get();
    log("user_match: ${data.docs.length}");
    if(data.docs.isNotEmpty && data.docs != null && data.docs.first.id!=user.uid){

      firestore.collection('users').doc(user.uid).collection('my_users').doc(data.docs.first.id).set({

      });
      return true;
    }else{
      return false;
    }
  }


}
