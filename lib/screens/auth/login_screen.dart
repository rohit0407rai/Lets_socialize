import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wechat/api/apis.dart';

import '../../helper/dialogs.dart';
import '../home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate=false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(milliseconds: 500),(){
      setState(() {
        _isAnimate=true;
      });
    });
  }
  _handleBtnClick(){
    Dialogs.showProgressBar(context);
    _signInWithGoogle().then((user) async {
      Navigator.pop(context);
      if(user!=null){
        print("User: ${user.user}");
        print("\nUser Info: ${user.additionalUserInfo}");
        if ((await APIs.userExist())){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>HomeScreen()));
        }else{
          await APIs.createUser().then((value) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>HomeScreen()));
          });
        }

      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    // Trigger the authentication flow
    try{
      await InternetAddress.lookup('google.com');
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    }
    catch(e){
      print('signInWithGoogle:$e');
      Dialogs.showsnackbar(context, 'Something went wrong (Check Internet Connection)', Colors.red);
      return null;

    }
  }
  // _signOut() async{
  //   await FirebaseAuth.instance.signOut();
  //   await GoogleSignIn().signOut();
  // }
  @override
  Widget build(BuildContext context) {
    Size mq = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Letss Login to Socialize'),
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(seconds: 1),
              top: _isAnimate?mq.height * 0.15:-mq.height*0.25,
              width: mq.width * 0.5,
              right: mq.width * 0.25,
              curve: Curves.elasticInOut,
              child: Image.asset('assets/images/social_media.png')),
            // Positioned(child: TextFormField(), bottom: mq.height* 0.25, width: mq.width*0.9,left: mq.width*0.05,height: mq.height*0.06,),

          Positioned(
              bottom: mq.height * .15,
              width: mq.width * .9,
              left: mq.width * .05,
              height: mq.height * .06,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    shape: const StadiumBorder(),
                    elevation: 1),
                onPressed: () {
                  _handleBtnClick();
                },
                icon: Image.asset(
                  'assets/images/OK.png',
                  height: mq.height * 0.03,
                ),
                label: RichText(
                    text: const TextSpan(
                        style: TextStyle(fontSize: 16),
                        children: [
                      TextSpan(text: 'LogIn With'),
                      TextSpan(
                          text: ' Google',
                          style: TextStyle(fontWeight: FontWeight.w500))
                    ])),
              )),
        ],
      ),
    );
  }
}
