import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/message.dart';

class ChatService extends ChangeNotifier{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<void> sendMessage(String receiverID, String message) async {
    final String currentUserID = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
        senderID: currentUserID,
        senderEmail: currentUserEmail,
        receiverID: receiverID,
        message: message,
        timestamp: timestamp,
    );

    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join("_");

    await _fireStore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .add(newMessage.toMap());

    await _fireStore.collection('chat_rooms').doc(chatRoomID).set({
      'participants': ids,
      'lastMessage': newMessage.message,
      'lastTimestamp': newMessage.timestamp,
    }, SetOptions(merge: true));
  }

  Stream<QuerySnapshot> getMessages(String userID, String otherUserID){
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join("_");

    return _fireStore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<List<Map<String, dynamic>>> getAdminChats(String adminID) async{
    final chatRooms = await _fireStore
        .collection("chat_rooms")
        .where('participants', arrayContains: adminID)
        .get();

    List<Map<String, dynamic>> chats = [];

    for (var chatRoom in chatRooms.docs) {
      List<String> participantIDs = List<String>.from(chatRoom['participants']);
      participantIDs.remove(adminID);

      String otherUserID = participantIDs.first;
      DocumentSnapshot userSnapshot =
      await _fireStore.collection('users').doc(otherUserID).get();

      String otherUserEmail = userSnapshot['email'];

      chats.add({
        'chatRoomID': chatRoom.id,
        'otherUserID': otherUserID,
        'otherUserEmail': otherUserEmail,
        'lastMessage': chatRoom['lastMessage'],
        'lastTimestamp': chatRoom['lastTimestamp'],
      });
    }

    return chats;
  }

  Future<String> assignRandomAdmin() async {
    final adminSnapshot = await _fireStore
        .collection('users')
        .where('role', isEqualTo: 'Admin')
        .get();

    if (adminSnapshot.docs.isEmpty) {
      throw Exception('Администраторы не найдены');
    }

    final adminIDs = adminSnapshot.docs.map((doc) => doc.id).toList();
    final randomIndex = Random().nextInt(adminIDs.length);
    final selectedAdminID = adminIDs[randomIndex];

    return selectedAdminID;
  }

}