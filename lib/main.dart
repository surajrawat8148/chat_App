import 'package:chat_app/helper/authenticate.dart';
import 'package:chat_app/helper/helperfunction.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/chatRoomsScreen.dart';
import 'package:chat_app/views/signin.dart';
import 'package:chat_app/views/signup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'helper/constant.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool userIsLoggedIn = false;

  DatabaseMethod databaseMethod = DatabaseMethod();

  late Stream<QuerySnapshot<Map<String, dynamic>>> chatRoomsStream;

  @override
  void initState() {
    getloggedInState();
    getUserInfo();
    super.initState();
  }

  getloggedInState() async {
    await HelperFunctions.getUserLoggedInSharedPreference().then((value) {
      setState(() {
        userIsLoggedIn = value!;
      });
    });
  }

  getUserInfo() async {
    Constant.myName = (await HelperFunctions.getUserNameSharedPreference())!;
    databaseMethod.getChatRoom(Constant.myName).then((value) {
      setState(() {
        chatRoomsStream = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xff145C9E),
        scaffoldBackgroundColor: const Color(0xff1F1F1F),
        primarySwatch: Colors.blue,
      ),
      // ignore: unnecessary_null_comparison
      home: userIsLoggedIn != null
          ? /**/ userIsLoggedIn
              ? ChatRoom(
                  stream: chatRoomsStream,
                )
              /**/ : const Authenticate()
          : const Authenticate(),
    );
  }
}
