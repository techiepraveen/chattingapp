import 'package:cached_network_image/cached_network_image.dart';
import 'package:chattingapp/firebase/firestore.dart';
import 'package:chattingapp/main.dart';
import 'package:chattingapp/screen/chatScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/chat_user.dart';
import '../model/message.dart';

class UserCardList extends StatefulWidget {
  final ChatUser user;
  const UserCardList({super.key, required this.user});

  @override
  State<UserCardList> createState() => _UserCardListState();
}

class _UserCardListState extends State<UserCardList> {
  //list message info(if null--> no message)
  Message? _message;
  @override
  Widget build(BuildContext context) {
    return Card(
      // margin: EdgeInsets.symmetric(horizontal: mq.width * 0.4, vertical: 4),
      //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 0.5,
      child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChatScreen(
                          user: widget.user,
                        )));
          },
          child: StreamBuilder(
            stream: APIs.getLastMessages(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              if (data != null && data.first.exists) {
                _message = Message.fromJson(data.first.data());
              }
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(
                      MediaQuery.of(context).size.height * .3),
                  child: CachedNetworkImage(
                    fit: BoxFit.fill,
                    width: MediaQuery.of(context).size.height * .055,
                    height: MediaQuery.of(context).size.height * .055,
                    imageUrl: widget.user.image,
                    errorWidget: (context, url, error) => const CircleAvatar(
                      child: Icon(CupertinoIcons.person),
                    ),
                  ),
                ),
                //user name
                title: Text(widget.user.name),
                //last message
                subtitle: Text(
                  _message != null ? _message!.msg : widget.user.about,
                  maxLines: 1,
                ),
                trailing: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.greenAccent.shade400),
                ),
                //trailing: Text("12:00PM"),
              );
            },
          )),
    );
  }
}
