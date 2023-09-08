import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wechat/api/apis.dart';
import 'package:wechat/screens/auth/login_screen.dart';
import '../home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isAnimate=false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.white, systemNavigationBarColor: Colors.white));

    Future.delayed(Duration(seconds: 2),(){
      initializeApp();
    });
  }
  Future<void> initializeApp() async {
    await Firebase.initializeApp();
    if(APIs.auth.currentUser!=null){
      Future.delayed(const Duration(seconds: 2),(){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const HomeScreen()));
      });
    }else{
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const LoginScreen()));
    }
  }
  @override
  Widget build(BuildContext context) {
    Size mq = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Container(
        child: Stack(
          children: [
            Positioned(
                top: mq.height * 0.35,
                width: mq.width * 0.5,
                right: mq.width * 0.25,
                child: Image.asset('assets/images/social_media.png')),
            Positioned(
                bottom: mq.height * .3,
                width: mq.width * .9,
                left: mq.width * .1,
                height: mq.height * .06,
                child: Text('Give Friendship the way of love', style: GoogleFonts.dancingScript(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),)),
          ],
        ),
      ),
    );
  }
}
