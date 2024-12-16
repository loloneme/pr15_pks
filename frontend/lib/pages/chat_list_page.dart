import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frontend/pages/chat_page.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/chat_service.dart';

class ChatListPage extends StatefulWidget {
  final String adminID;

  const ChatListPage({super.key, required this.adminID});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Center(
              child: Text("Чаты",
                  style: GoogleFonts.sourceSerif4(
                      textStyle: const TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.w400,
                    color: Color.fromRGBO(255, 238, 205, 1.0),
                  )))),
          backgroundColor: const Color.fromRGBO(71, 58, 42, 1.0),
        ),
        backgroundColor: const Color.fromRGBO(71, 58, 42, 1.0),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _chatService.getAdminChats(widget.adminID),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("Нет доступных чатов",
                  style: GoogleFonts.sourceSerif4(
                      textStyle: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(255, 238, 205, 1.0),
                      ))));
            }

            final chats = snapshot.data!;

            return Padding(
              padding: const EdgeInsets.all(20),
              child: ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  final chatRoomID = chat['chatRoomID'];
                  final otherUserID = chat['otherUserID'];
                  final otherUserEmail = chat['otherUserEmail'];
                  final lastMessage = chat['lastMessage'];
                  final lastTimestamp = chat['lastTimestamp'] as Timestamp;

                  return Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(otherUserEmail,
                                style: GoogleFonts.sourceSerif4(
                                    textStyle: const TextStyle(
                                      fontSize: 16.0,
                                      color: Color.fromRGBO(255, 238, 205, 1.0),
                                    )
                                )
                            ),
                            const SizedBox(height: 5),
                            Text(lastMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.sourceSerif4(
                                textStyle: const TextStyle(
                                fontSize: 14.0,
                                color: Color.fromRGBO(255, 238, 205, 1.0),
                              )
                          ))
                          ],
                        ),
                        trailing: Text("${lastTimestamp.toDate().hour}:${lastTimestamp.toDate().minute}",
                            style: GoogleFonts.sourceSerif4(
                                textStyle: const TextStyle(
                                  fontSize: 12.0,
                                  color: Color.fromRGBO(159, 133, 102, 1.0),
                                )
                            )
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                receiverUserEmail: otherUserEmail,
                                receiverUserID: otherUserID,
                              ),
                            ),
                          );
                        },
                      ),
                      Container(
                        width: double.infinity,
                        height: 1,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(159, 133, 102, 1.0),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      )
                    ],
                  );
                },
              ),
            );
          },
        ),
    );
  }
}
