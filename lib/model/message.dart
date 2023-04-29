import 'package:flutter/rendering.dart';

class Message {
  late final String toId;
  late final String msg;
  late final String read;
  late final Type type;
  late final String fromId;
  late final String sent;

  Message(
      {required this.fromId,
      required this.msg,
      required this.read,
      required this.sent,
      required this.toId,
      required this.type});

  Message.fromJson(Map<String, dynamic> json) {
    toId = json['toId'].toString();
    msg = json['msg'].toString();
    read = json['read'].toString();
    type = json['type'].toString() == Type.image.name ? Type.image : Type.text;
    fromId = json['fromId'].toString();
    sent = json['sent'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['toId'] = toId;
    data['msg'] = msg;
    data['read'] = read;
    data['type'] = type.name;
    data['fromId'] = fromId;
    data['sent'] = sent;
    return data;
  }
}

enum Type { text, image }
