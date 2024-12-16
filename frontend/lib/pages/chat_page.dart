import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/services/chat_service.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserID;
  final String receiverUserEmail;

  const ChatPage({
    super.key,
    required this.receiverUserEmail,
    required this.receiverUserID
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage() async {
    if (_messageController.text.isNotEmpty){
      await _chatService.sendMessage(widget.receiverUserID, _messageController.text);

        _messageController.text = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Center(
              child: Text(widget.receiverUserEmail,
                  style: GoogleFonts.sourceSerif4(
                      textStyle: const TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.w400,
                    color: Color.fromRGBO(255, 238, 205, 1.0),
                  )))),
          backgroundColor: const Color.fromRGBO(71, 58, 42, 1.0),
      ),
      backgroundColor: const Color.fromRGBO(71, 58, 42, 1.0),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          children: [
            Expanded(
              child: _messageList(),
            ),

            _messageInput(),
          ],
        ),
      )
    );
  }

  Widget _messageList(){
    return StreamBuilder(
        stream: _chatService.getMessages(widget.receiverUserID, _firebaseAuth.currentUser!.uid),
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}',
                style: GoogleFonts.sourceSerif4(
                    textStyle: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w400,
                      color: Color.fromRGBO(255, 238, 205, 1.0),
                    ))));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Невозможно получить пользователя',
                style: GoogleFonts.sourceSerif4(
                    textStyle: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w400,
                      color: Color.fromRGBO(255, 238, 205, 1.0),
                    ))));
          } else {
            return ListView.separated(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) => _messageItem(snapshot.data!.docs[index]),
                separatorBuilder: (context, index) => const SizedBox(height: 8),
            );
          }
        }
        );
  }

  Widget _messageItem(DocumentSnapshot document){
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    return Align(
      alignment: (data['senderID'] == _firebaseAuth.currentUser!.uid)
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (data['senderID'] == _firebaseAuth.currentUser!.uid)
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: Text(
                  "${data['timestamp'].toDate().hour}:${data['timestamp'].toDate().minute}",
                  style: GoogleFonts.sourceSerif4(
                    textStyle: const TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                      color: Color.fromRGBO(159, 133, 102, 1.0),
                    ),
                  ),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                color: const Color.fromRGBO(159, 133, 102, 1.0),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(
                data['message'],
                style: GoogleFonts.sourceSerif4(
                  textStyle: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                    color: Color.fromRGBO(255, 238, 205, 1.0),
                  ),
                ),
              ),
            ),
            if (data['senderID'] != _firebaseAuth.currentUser!.uid)
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Text(
                  "${data['timestamp'].toDate().hour}:${data['timestamp'].toDate().minute}",
                  style: GoogleFonts.sourceSerif4(
                    textStyle: const TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                      color: Color.fromRGBO(159, 133, 102, 1.0),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _messageInput(){
    return Row(
      children: [
        Expanded(
            child: TextField(
              controller: _messageController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                style: GoogleFonts.sourceSerif4(
                    textStyle: const TextStyle(
                        fontSize: 16.0,
                        color: Color.fromRGBO(255, 238, 205, 1.0))),
                decoration: InputDecoration(
                  isDense: true,
                  enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromRGBO(159, 133, 102, 1.0),
                          width: 2.0)),
                  focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromRGBO(159, 133, 102, 1.0),
                          width: 2.0)),
                  contentPadding: const EdgeInsets.all(5),
                  hintText:
                  'Введите сообщение',
                  hintStyle: GoogleFonts.sourceSerif4(
                      textStyle: const TextStyle(
                          fontSize: 16.0,
                          color: Color.fromRGBO(159, 133, 102, 1.0))),
                ),
              )
        ),
        IconButton(
            onPressed: sendMessage,
            icon: const Icon(
              Icons.send_rounded,
              color: Color.fromRGBO(255, 238, 205, 1.0),)
        )
      ],
    );
  }
}
