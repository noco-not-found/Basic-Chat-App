import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _NewMessageState();
  }
}

class _NewMessageState extends State<NewMessage> {
  var _newMessageController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    _newMessageController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    final _eneteredMessage = _newMessageController.text;

    if (_eneteredMessage.trim().isEmpty) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser!;

    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    FirebaseFirestore.instance.collection("chat").add({
      'text': _eneteredMessage,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'userName': userData.data()!['username'],
      'userimage': userData.data()!['image_url'],
    });

    //senf to Firebase

    //clearing the message after sending
    _newMessageController.clear();
    FocusScope.of(context).unfocus();
    _newMessageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _newMessageController,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: const InputDecoration(labelText: 'Send a message...'),
            ),
          ),
          IconButton(
            color: Theme.of(context).primaryColor,
            onPressed: _submitMessage,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
