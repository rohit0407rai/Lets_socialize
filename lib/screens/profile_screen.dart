import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wechat/api/apis.dart';
import 'package:wechat/screens/auth/login_screen.dart';

import '../helper/dialogs.dart';
import '../models/chat_user.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final formKey = GlobalKey<FormState>();
  String? _image;
  @override
  Widget build(BuildContext context) {
    Size mq = MediaQuery.sizeOf(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile Screen'),
        ),
        body: Form(
          key: formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * 0.05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(width: mq.width, height: mq.height * .03),
                  Stack(

                      children: [
                        _image!=null?ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .1),
              child: Image.file(File(_image!), width: mq.height*.2,height: mq.height*.2, fit: BoxFit.cover,)
            )
                            :ClipRRect(
                          borderRadius: BorderRadius.circular(mq.height * .1),
                          child: CachedNetworkImage(
                            width: mq.height * 0.2,
                            height: mq.height * 0.2,
                            fit: BoxFit.cover,
                            imageUrl: widget.user.image,
                            placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                            const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                          ),
                        ),

                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          onPressed: () {
                            _showBottomSheet(context);
                          },
                          child: const Icon(
                            Icons.edit,
                            color: Colors.blue,
                          ),
                          color: Colors.white,
                          shape: const CircleBorder(),
                          elevation: 1,
                        ))
                  ]),
                  SizedBox(height: mq.height * .03),
                  Text(
                    widget.user.email,
                    style: const TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                  SizedBox(height: mq.height * .05),
                  TextFormField(
                    initialValue: widget.user.name,
                    decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Colors.blueAccent,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        hintText: 'eg: Rohit Rai',
                        label: Text('Name')),
                    onSaved: (val) => APIs.me.name = val ?? "",
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required Field',
                  ),
                  SizedBox(height: mq.height * .02),
                  TextFormField(
                    initialValue: widget.user.about,
                    decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.info_outline,
                          color: Colors.blueAccent,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        hintText: 'eg: Feeling Happy',
                        label: const Text('About')),
                    onSaved: (val) => APIs.me.about = val ?? "",
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required Field',
                  ),
                  SizedBox(height: mq.height * .05),
                  ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          shape: const StadiumBorder(),
                          minimumSize: Size(mq.width * 0.4, mq.height * 0.06)),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          formKey.currentState!.save();
                          Dialogs.showProgressBar(context);
                          APIs.updateUserData().then((value) {
                            Navigator.pop(context);
                            Dialogs.showsnackbar(
                                context, 'Update Succesfull', Colors.blue);
                          });
                        }
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text(
                        'UPDATE',
                        style: const TextStyle(fontSize: 16),
                      ))
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.redAccent,
          onPressed: () async {
            Dialogs.showProgressBar(context);
            await APIs.updateActiveStatus(false);
            await APIs.auth.signOut().then((value) {
              GoogleSignIn().signOut().then((value) {
                Navigator.pop(context);
                Navigator.pop(context);

                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()));
              });
            });
          },
          icon: const Icon(Icons.logout),
          label: const Text('Log Out'),
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext ctx) {
    Size mq = MediaQuery.sizeOf(ctx);
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(20),topLeft: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(top: mq.height * .03,bottom: mq.height*.03),
            children: [
              const Text('Pick Profile Picture', style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500),textAlign: TextAlign.center,),
              SizedBox(height: mq.height*0.02,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, fixedSize: Size(mq.width*.3, mq.height*0.15), shape: const CircleBorder()),
                      onPressed: () async {
                        final ImagePicker _picker= ImagePicker();
                        final XFile? image=await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                        if(image!=null){
                          print('IMage Path : ${image.path}');

                          setState(() {
                            _image=image.path.toString();
                          });
                          APIs.updateProfilePicture(File(_image!));
                          Navigator.pop(context);
                        }

                      }, child: Image.asset('assets/images/gallery.png')),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, fixedSize: Size(mq.width*.3, mq.height*0.15), shape: const CircleBorder()),
                      onPressed: () async{
                        final ImagePicker _picker= ImagePicker();
                        final XFile? image=await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                        if(image!=null){
                          print('IMage Path : ${image.path}');

                          setState(() {
                            _image=image.path.toString();
                          });
                          APIs.updateProfilePicture(File(_image!));
                          Navigator.pop(context);
                        }
                      }, child: Image.asset('assets/images/camera.png'))
                ],
              )
            ],
          );
        });
  }
}
