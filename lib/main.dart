import 'package:chattingapp/screen/homescreen.dart';
import 'package:chattingapp/screen/loginscreen.dart';
import 'package:chattingapp/widgets/user_card_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

late Size mq;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
