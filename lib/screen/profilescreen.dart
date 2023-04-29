// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chattingapp/firebase/firestore.dart';
import 'package:chattingapp/main.dart';
import 'package:chattingapp/model/chat_user.dart';
import 'package:chattingapp/screen/loginscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/dialog.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _image;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: AppBar(
              title: const Text("Welcome to Lets chat"),
              leading:
                  const IconButton(icon: Icon(Icons.logout), onPressed: null)),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              Dialogs.showProgressBar(context);
              await APIs.auth.signOut().then((value) async {
                await GoogleSignIn().signOut().then((value) {
                  Navigator.pop(context);
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => LoginScreen()));
                });
              });
            },
            icon: const Icon(Icons.logout),
            label: const Text("logout"),
            backgroundColor: Colors.redAccent.shade200,
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Center(
                      child: Stack(
                        children: [
                          _image != null
                              ?
                              //local image
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      MediaQuery.of(context).size.height * .3),
                                  child: Image.file(
                                    File(_image!),
                                    width:
                                        MediaQuery.of(context).size.height * .2,
                                    height:
                                        MediaQuery.of(context).size.height * .2,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              :
                              //image from server
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      MediaQuery.of(context).size.height * .3),
                                  child: CachedNetworkImage(
                                    fit: BoxFit.fill,
                                    width:
                                        MediaQuery.of(context).size.height * .2,
                                    height:
                                        MediaQuery.of(context).size.height * .2,
                                    imageUrl: widget.user.image,
                                    errorWidget: (context, url, error) =>
                                        const CircleAvatar(
                                      child: Icon(CupertinoIcons.person),
                                    ),
                                  ),
                                ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: MaterialButton(
                              onPressed: () {
                                _showBottomSheet();
                              },
                              child: const Icon(Icons.edit),
                              color: Colors.white,
                              shape: const CircleBorder(),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Text(
                    widget.user.email,
                    style: const TextStyle(fontSize: 18),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: TextFormField(
                      initialValue: widget.user.name,
                      onSaved: (val) => APIs.me.name = val ?? '',
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'required Field',
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                          prefixIcon: Icon(Icons.person),
                          hintText: "eg enter your name",
                          label: Text("name")),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: TextFormField(
                      initialValue: widget.user.about,
                      onSaved: (val) => APIs.me.about = val ?? '',
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'required Field',
                      //initialValue: widget.user.name,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                          prefixIcon: Icon(Icons.info_outline),
                          hintText: "eg feeling happy",
                          label: Text("about you")),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ElevatedButton.icon(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            APIs.updateUserInfo();
                          }
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text("Update")),
                  )
                ],
              ),
            ),
          )),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Pick Profile Picture",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            backgroundColor: Colors.white,
                            fixedSize: Size(
                                MediaQuery.of(context).size.width * 0.3,
                                MediaQuery.of(context).size.height * 0.15)),
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          // Pick an image.
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery, imageQuality: 80);
                          if (image != null) {
                            log('Image path: ${image.path}');
                            setState(() {
                              _image = image.path;
                            });
                            APIs.updateProfilePicture(File(_image!));
                            Navigator.pop(context);
                          }
                        },
                        child: const Icon(
                          Icons.image,
                          color: Colors.blue,
                        )),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            backgroundColor: Colors.white,
                            fixedSize: Size(
                                MediaQuery.of(context).size.width * 0.3,
                                MediaQuery.of(context).size.height * 0.15)),
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          // Pick an image.
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.camera, imageQuality: 80);
                          if (image != null) {
                            log('Image path: ${image.path}');
                            setState(() {
                              _image = image.path;
                            });
                            APIs.updateProfilePicture(File(_image!));
                            Navigator.pop(context);
                          }
                        },
                        child: const Icon(
                          Icons.camera,
                          color: Colors.blue,
                        )),
                  ],
                ),
              ),
            ],
          );
        });
  }
}
