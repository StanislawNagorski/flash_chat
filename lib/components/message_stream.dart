import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import 'message_bubble.dart';

class MessageStream extends StatelessWidget {
  const MessageStream({
    Key key,
    @required FirebaseFirestore fireStore,
    @required this.loggedUserEmail,
  })  : _fireStore = fireStore,
        super(key: key);

  final FirebaseFirestore _fireStore;
  final String loggedUserEmail;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _fireStore
          .collection(kFireBaseDBName)
          .orderBy(kFireBaseDBTimestamp, descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlue,
            ),
          );
        }
        final messages = snapshot.data.docs;
        List<MessageBubble> messagesBubbles = messages.map((message) {
          String messageText = message.data()[kFireBaseDBTextLabel];
          String messageSender = message.data()[kFireBaseDBSenderLabel];
          return MessageBubble(
            text: messageText,
            sender: messageSender,
            isMe: messageSender == loggedUserEmail,
          );
        }).toList(growable: true);
        return Expanded(
            child: ListView(
          reverse: true,
          children: messagesBubbles,
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
        ));
      },
    );
  }
}
