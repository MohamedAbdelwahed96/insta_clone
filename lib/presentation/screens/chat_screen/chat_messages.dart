import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/data/chat_model.dart';
import 'package:instagram_clone/presentation/screens/profile_screen/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:instagram_clone/logic/chat_provider.dart';

class ChatMessages extends StatelessWidget {
  final String chatId;
  final String currentUserId;
  final String? userImg;
  final List<ChatModel> messages;

  const ChatMessages({
    super.key,
    required this.chatId,
    required this.currentUserId,
    required this.userImg,
    required this.messages,
  });

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final provider = Provider.of<ChatProvider>(context);

    return Expanded(
      child: ListView.builder(
        reverse: true,
        padding: EdgeInsets.all(8),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final bool isMe = messages[index].senderId == currentUserId;
          final bool isPreviousSameUser = index < messages.length - 1 &&
              messages[index].senderId == messages[index + 1].senderId;
          final bool isLastFromUser = index == 0 ||
              messages[index].senderId != messages[index - 1].senderId;

          final bool isNextSameUser = index > 0 &&
              messages[index].senderId == messages[index - 1].senderId;

          BorderRadius messageBorder = BorderRadius.only(
            topLeft: Radius.circular(isMe ? 18 : isPreviousSameUser ? 2 : 18),
            topRight: Radius.circular(isMe ? (isPreviousSameUser ? 2 : 18) : 18),
            bottomLeft: Radius.circular(isMe ? 18 : isNextSameUser ? 2 : 18),
            bottomRight: Radius.circular(isMe ? (isNextSameUser ? 2 : 18) : 18),
          );

          return Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isMe && isLastFromUser)
                InkWell(
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (context) => ProfileScreen(profileId: messages[index].senderId)),),
                  child: CircleAvatar(foregroundImage: NetworkImage(userImg!)),
                ),
              if (!isMe && !isLastFromUser) SizedBox(width: screen.width * 0.1),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == "delete") await provider.deleteMessage(context, chatId, messages[index].messageId!);
                },
                itemBuilder: (context) => [
                  if (isMe)
                    PopupMenuItem(value: "delete",
                      child: ListTile(
                        leading: Icon(Icons.delete),
                        title: Text("delete_message".tr()),
                      ),
                    ),
                ],
                child: Container(
                  constraints: BoxConstraints(maxWidth: screen.width * 0.7),
                  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.blue : Colors.grey[300],
                    borderRadius: messageBorder,
                  ),
                  child: Text(messages[index].message,
                    style: TextStyle(color: isMe ? Colors.white : Colors.black),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
