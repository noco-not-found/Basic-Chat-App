import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
          return Center(child: Text("No messages found"));
        }
        if (chatSnapshot.hasError) {
          return Center(child: Text("Something went wrong"));
        }

        final loadedMessage = chatSnapshot.data!.docs;

        return ListView.builder(
          reverse: true,
          padding: const EdgeInsets.only(bottom: 40, left: 13, right: 13),
          itemCount: loadedMessage.length,
          itemBuilder: (ctx, index) {
            final chatMessage = loadedMessage[index].data();
            final nextchatmessage = index + 1 > loadedMessage.length
                ? loadedMessage[index + 1]
                : null;
            final currentMessageUid = chatMessage['userId'];
            final nextMessageUid = nextchatmessage != null
                ? nextchatmessage['UserId']
                : null;
            final nextuserissame = currentMessageUid == nextMessageUid;
            if (nextuserissame) {
              return MessageBubble.next(
                message: chatMessage['text'],
                isMe: authenticatedUser.uid == currentMessageUid,
              );
            } else {
              return MessageBubble.first(
                userImage: chatMessage['userimage'],
                username: chatMessage['userName'],
                message: chatMessage['text'],
                isMe: authenticatedUser.uid == currentMessageUid,
              );
            }
          },

          // Text(loadedMessage[index].data()['text']),
        );
      },
    );
  }
}
