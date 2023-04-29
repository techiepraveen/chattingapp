import 'dart:developer';
import 'dart:io';

import 'package:chattingapp/firebase/firestore.dart';
import 'package:chattingapp/main.dart';
import 'package:chattingapp/screen/homescreen.dart';
import 'package:chattingapp/widgets/dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), (() {
      setState(() {
        _isAnimate = true;
      });
    }));
  }

  _handleGoogleBtnClick() {
    Dialogs.showProgressBar(context);
    _signInWithGoogle().then((user) async {
      Navigator.pop(context);
      if (user != null) {
        if (await (APIs.userExists())) {
          Navigator.push(context,
              MaterialPageRoute(builder: ((context) => const HomeScreen())));
        } else {
          await APIs.createUser().then((value) {
            Navigator.push(context,
                MaterialPageRoute(builder: ((context) => const HomeScreen())));
          });
        }
      } else {
        Dialogs.showSnackBar(context, "please log in ");
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      log('_signInWithGoogle: $e');
      Dialogs.showSnackBar(context,
          "Something went wrong(please check your internet connection)");
      return null;
    }
    // Trigger the authentication flow
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Welcome to Lets Chat")),
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
              top: mq.height * 0.15,
              right: _isAnimate ? mq.width * 0.25 : mq.width * .01,
              width: mq.width * 0.5,
              duration: const Duration(seconds: 1),
              child: Image.asset("images/chat.png")),
          AnimatedPositioned(
            top: mq.height * 0.55,
            right: _isAnimate ? mq.width * 0.25 : mq.width * .01,
            width: mq.width * 0.5,
            duration: const Duration(seconds: 1),
            child: ElevatedButton(
              onPressed: () {
                _handleGoogleBtnClick();
              },
              child: const Text("Sign In With Google"),
            ),
          ),
        ],
      ),
    );
  }
}
