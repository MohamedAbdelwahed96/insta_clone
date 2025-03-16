import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/logic/user_provider.dart';
import 'package:instagram_clone/presentation/screens/chat_screen/chat_screen.dart';
import 'package:instagram_clone/presentation/screens/messages_screen/new_message_screen.dart';
import 'package:provider/provider.dart';
import 'package:instagram_clone/data/chat_model.dart';
import 'package:instagram_clone/data/user_model.dart';
import 'package:instagram_clone/logic/chat_provider.dart';
import 'package:instagram_clone/logic/media_provider.dart';

class MessagesScreen extends StatefulWidget {
  final UserModel user;
  const MessagesScreen({super.key, required this.user});

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<ChatModel> chats = [];
  List<UserModel> users = [];
  List<String?> usersPfp = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchChats();
  }

  Future<void> fetchChats() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final mediaProvider = Provider.of<MediaProvider>(context, listen: false);

    List<ChatModel> fetchedChats = await chatProvider.getUserChats(widget.user.uid);
    List<UserModel> fetchedUsers = [];
    List<String?> fetchedImages = [];

    for (ChatModel chat in fetchedChats) {
      String userId = chat.senderId == widget.user.uid ? chat.receiverId : chat.senderId;

      UserModel? user = await userProvider.getUserInfo(userId);
      if (user != null) {
        String? profilePic = await mediaProvider.getImage(
          bucketName: "users", folderName: user.uid, fileName: user.pfpUrl);

        fetchedUsers.add(user);
        fetchedImages.add(profilePic);
      }
    }

    setState(() {
      chats = fetchedChats;
      users = fetchedUsers;
      usersPfp = fetchedImages;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.username,
          style: TextStyle(fontWeight: FontWeight.bold),),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: IconButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(
                    builder: (context) => NewMessageScreen(currentUserId: widget.user.uid))),
                icon: ImageIcon(AssetImage("assets/icons/new_message.png"), size: 32)),
          )
        ],
      ),
      body: isLoading ? Center(child: CircularProgressIndicator())
          : chats.isEmpty ? Center(child: Text("no_recent_messages".tr()))
          : ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chat = chats[index];
          final user = users[index];

          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(usersPfp[index]!)),
            title: Text(user.fullName),
            subtitle: Text(
                (chat.senderId == widget.user.uid ? "${"you".tr()}: " : "") + chat.message,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
              maxLines: 1,
                overflow: TextOverflow.ellipsis),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) =>
                ChatScreen(chatId: chat.chatId, senderId: widget.user.uid, receiverId: user.uid),
              ),
            ),
          );
        },
      ),
    );
  }
}
