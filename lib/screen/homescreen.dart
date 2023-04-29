import 'dart:developer';

import 'package:chattingapp/firebase/firestore.dart';
import 'package:chattingapp/model/chat_user.dart';
import 'package:chattingapp/screen/loginscreen.dart';
import 'package:chattingapp/widgets/dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../widgets/user_card_list.dart';
import 'profilescreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> list = [];
  //for searcging searched items
  final List<ChatUser> _searchList = [];
  //for storing search status
  bool _isSearching = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    APIs.getSelfInfo();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (() => FocusScope.of(context).unfocus()),
      child: WillPopScope(
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
            appBar: AppBar(
                title: _isSearching
                    ? TextField(
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Name, Email....',
                        ),
                        autofocus: true,
                        onChanged: (val) {
                          _searchList.clear();
                          for (var i in list) {
                            if (i.name
                                    .toLowerCase()
                                    .contains(val.toLowerCase()) ||
                                i.email
                                    .toLowerCase()
                                    .contains(val.toLowerCase())) {
                              _searchList.add(i);
                            }
                            setState(() {
                              _searchList;
                            });
                          }
                        },
                      )
                    : Text("Welcome to Lets chat"),
                actions: [
                  IconButton(
                      onPressed: () {
                        setState(() {
                          _isSearching = !_isSearching;
                        });
                      },
                      icon: Icon(_isSearching
                          ? CupertinoIcons.clear_circled_solid
                          : Icons.search)),
                  IconButton(
                      onPressed: (() {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfileScreen(
                                      user: APIs.me,
                                    )));
                      }),
                      icon: Icon(Icons.more_vert))
                ],
                leading: IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: (() async {
                    await FirebaseAuth.instance.signOut();
                    await GoogleSignIn().signOut();
                    Dialogs.showProgressBar(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: ((context) => const LoginScreen())));
                  }),
                )),
            body: StreamBuilder(
                stream: APIs.getAllUsers(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return const Center(child: CircularProgressIndicator());

                    case ConnectionState.active:
                    case ConnectionState.done:
                      final data = snapshot.data?.docs;
                      list = data
                              ?.map((e) => ChatUser.fromJson(e.data()))
                              .toList() ??
                          [];

                      if (list.isNotEmpty) {
                        return ListView.builder(
                            itemCount:
                                _isSearching ? _searchList.length : list.length,
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return UserCardList(
                                user: _isSearching
                                    ? _searchList[index]
                                    : list[index],
                              );
                              //return Text('Name: ${list[index]}');
                            });
                      } else {
                        return Center(child: Text("no connection available"));
                      }
                  }
                })),
      ),
    );
  }
}
