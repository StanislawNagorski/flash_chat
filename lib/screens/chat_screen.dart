import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';

const kFireBaseDBName = 'messages';
const kFireBaseDBSenderLabel = 'sender';
const kFireBaseDBTextLabel = 'label';

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final _fireStore = FirebaseFirestore.instance;
  User loggedUser;
  String chatMessage;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedUser = user;
        print(loggedUser.email);
      }
    } on Exception catch (e) {
      print(e);
    }
  }

  // void getMessages() async {
  //   final messages = await _fireStore.collection(kFireBaseDBName).get();
  //   messages.docs.forEach((element) => print(element.data()));
  // }

  void messagesStream() async {
    await for (var snapshot
        in _fireStore.collection(kFireBaseDBName).snapshots()) {
      for (var message in snapshot.docs) {
        print(message.data());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: _fireStore.collection(kFireBaseDBName).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.lightBlue,
                    ),
                  );
                }
                final messages = snapshot.data.docs;
                List<MessageBubble> messageList = messages.map((message) {
                  String messageText = message.data()[kFireBaseDBTextLabel];
                  String messageSender = message.data()[kFireBaseDBSenderLabel];
                  return MessageBubble(
                      messageText: messageText, messageSender: messageSender);
                }).toList(growable: true);
                return Expanded(
                    child: ListView(
                  children: messageList,
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                ));
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        chatMessage = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      _fireStore.collection(kFireBaseDBName).add({
                        kFireBaseDBSenderLabel: loggedUser.email,
                        kFireBaseDBTextLabel: chatMessage
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    Key key,
    @required this.messageText,
    @required this.messageSender,
  }) : super(key: key);

  final String messageText;
  final String messageSender;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$messageText from $messageSender',
      style: TextStyle(fontSize: 50.0),
    );
  }
}
