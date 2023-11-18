import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:we_chat/helper/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../api/apis.dart';
import '../../main.dart';
import '../home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  bool _isAnimated = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(
      const Duration(microseconds: 500),
      () {
        setState(() {
          _isAnimated = true;
        });
      },
    );
  }

  _handelGoogleSighIn(){
    Dialogs.showProgressBar(context);
    _signInWithGoogle().then((user) async{
      Navigator.pop(context);
      if(user != null)
        {
          log('\nuser: ${user.user}');
          log('\nuser info: ${user.additionalUserInfo}');

          if((await APIs.userExists())){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> const HomeScreen()));
          }else{
            await APIs.createUser().then((value) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> const HomeScreen()));
            });
          }

        }
    });
  }
  Future<UserCredential?> _signInWithGoogle() async {
    try{
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
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
    }catch (e){
      log('\n _signInWithGoogle : $e');
      Dialogs.showSnackBar(context, 'Something went wrong, check the Internet Connection');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      //app bar
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Welcome To WE Chat'),
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
            top: mq.height * 0.15,
            right: _isAnimated ? mq.width * 0.25 : -mq.width * 0.5,
            width: mq.width * 0.5,
            duration: const Duration(seconds: 1),
            child: Image.asset('assets/images/chat.png'),
          ),
          Positioned(
            bottom: mq.height * 0.15,
            left: mq.width * 0.05,
            width: mq.width * 0.9,
            height: mq.height * 0.07,
            child: ElevatedButton.icon(
                onPressed: () {
                  _handelGoogleSighIn();
                },
                icon: Image.asset('assets/images/google.png'),
                label: const Text('Sign In with Google')),
          ),
        ],
      ),
    );
  }
}
