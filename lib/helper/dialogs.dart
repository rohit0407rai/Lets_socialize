import 'package:flutter/material.dart';
class Dialogs{
  static  void showsnackbar(BuildContext context,String msg, Color colors){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: colors,behavior: SnackBarBehavior.floating,));
  }
  static void showProgressBar(BuildContext context){
    showDialog(context: context, builder: (_)=>const Center(child: CircularProgressIndicator()));
  }

}