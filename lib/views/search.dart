import 'package:chat_app/helper/constant.dart';
import 'package:chat_app/helper/helperfunction.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/chatRoomsScreen.dart';
import 'package:chat_app/views/conversation_screen.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

late String _myName;

class _SearchScreenState extends State<SearchScreen> {
  DatabaseMethod databaseMethod = DatabaseMethod();
  TextEditingController searchTextEditingController = TextEditingController();

  QuerySnapshot? searchSnapshot;

  Widget searchList() {
    // ignore: unnecessary_null_comparison
    return searchSnapshot != null
        ? ListView.builder(
            itemCount: searchSnapshot?.docs.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return SearchTile(
                userName: searchSnapshot?.docs[index]["name"],
                userEmail: searchSnapshot?.docs[index]["email"],
              );
            })
        : Container();
  }

  initiateSearch() {
    databaseMethod
        .getUserByUsername(searchTextEditingController.text)
        .then((val) {
      setState(() {
        searchSnapshot = val;
      });
    });
  }

  // create function chatroom, send user to convesation screen, pushreplacement
  createChatRoomAndStartConversation({required String userName}) {
    if (userName != Constant.myName) {
      String chatroomId = getChatRoomId(userName, Constant.myName);

      List<String> users = [userName, Constant.myName];
      Map<String, dynamic> chatRoomMap = {
        "users": users,
        "chatroomId": chatroomId
      };
      DatabaseMethod().createChatRoom(chatroomId, chatRoomMap);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ConversationScreen(chatroomId)));
    } else {
      print("you cannot messege to yourself!!! ");
    }
  }

  Widget SearchTile({required String userName, required String userEmail}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(userName, style: mediumTextFieldStyle()),
              Text(userEmail, style: mediumTextFieldStyle()),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              createChatRoomAndStartConversation(userName: userName);
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text(
                "Message",
                style: mediumTextFieldStyle(),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  getUserInfo() async {
    Constant.myName = (await HelperFunctions.getUserNameSharedPreference())!;
    setState(() {
      _myName = Constant.myName;
    });
    print("My Name : $_myName");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: Container(
        child: Column(
          children: [
            Container(
              color: const Color(0x54FFFFFF),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchTextEditingController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "search username...",
                          hintStyle: TextStyle(color: Colors.white54)),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      initiateSearch();
                    },
                    child: Container(
                        height: 40,
                        width: 40,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0x36FFFFFF),
                              Color(0x0FFFFFFF),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Image.asset("assets/images/search_white.png")),
                  )
                ],
              ),
            ),
            searchList()
          ],
        ),
      ),
    );
  }
}

getChatRoomId(String a, String b) {
  if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
    return "$b\_$a";
  } else {
    return "$a\_$b";
  }
}
