import 'dart:convert';
import 'dart:developer';

import 'package:we_chat/models/chat_user.dart';
import 'package:we_chat/screens/profile_screen.dart';
import 'package:we_chat/widgets/chat_user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../api/apis.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> usersList = [];
  final List<ChatUser> searchList = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(//to make the back button close the search
        onWillPop: () {
          if(_isSearching){
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);//do nothing if true back button will close the app
          }else{
            return Future.value(true);// back button will close the app
          }
        },
        child: Scaffold(
          //app bar
          appBar: AppBar(
            title: _isSearching
                ? TextField(
                    autofocus: true,
                    style: const TextStyle(
                      fontSize: 17,
                      letterSpacing: 0.5,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Name, Email , ...',
                    ),
                    onChanged: (val) {
                      //search logic
                      searchList.clear();
                      for (var i in usersList) {
                        if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                            i.email.toLowerCase().contains(val.toLowerCase())) {
                          searchList.add(i);
                        }
                        setState(() {
                          searchList;
                        });
                      }
                    },
                  )
                : const Text('WE Chat'),
            leading: const Icon(CupertinoIcons.home),
            actions: [
              //search user button
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                  });
                },
                icon: Icon(_isSearching
                    ? CupertinoIcons.clear_circled_solid
                    : Icons.search),
              ),
              //more features button
              IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ProfileScreen(
                                user: APIs.me,
                              )));
                },
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
          //floating button to add new user to your chat
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await APIs.auth.signOut();
              await GoogleSignIn().signOut();
            },
            child: const Icon(Icons.add_comment_rounded),
          ),
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
                    usersList =
                        data?.map((e) => ChatUser.fromJson(e.data())).toList() ??
                            [];
                    if (usersList.isNotEmpty) {
                      return ListView.builder(
                          itemCount: _isSearching ? searchList.length : usersList.length,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, inx) {
                            return ChatUserCard(
                              user: _isSearching ? searchList[inx] : usersList[inx],
                            );
                            //return Text('Name : ${usersList[inx]}');
                          });
                    } else {
                      return const Center(
                          child: Text(
                        'No Connections Found!!',
                        style: TextStyle(fontSize: 20),
                      ));
                    }
                }
              }),
        ),
      ),
    );
  }
}
