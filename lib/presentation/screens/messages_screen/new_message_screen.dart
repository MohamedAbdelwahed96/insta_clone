import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/logic/user_provider.dart';
import 'package:instagram_clone/presentation/screens/chat_screen/chat_screen.dart';
import 'package:provider/provider.dart';
import 'package:instagram_clone/data/user_model.dart';
import 'package:instagram_clone/logic/media_provider.dart';

class NewMessageScreen extends StatefulWidget {
  final String currentUserId;
  const NewMessageScreen({super.key, required this.currentUserId});

  @override
  _NewMessageScreenState createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends State<NewMessageScreen> {
  List<UserModel> users = [];
  List<String?> usersPfp = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final mediaProvider = Provider.of<MediaProvider>(context, listen: false);

    List<UserModel> fetchedUsers = await userProvider.getFollows(userProvider.currentUser!.uid, "following");
    List<String?> fetchedImages = [];

    for (var user in fetchedUsers) {
      String? profilePic = await mediaProvider.getImage(
          bucketName: "users", folderName: user.uid, fileName: user.pfpUrl);
      fetchedImages.add(profilePic);
    }

    setState(() {
      users = fetchedUsers;
      usersPfp = fetchedImages;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("new_message".tr(), style: TextStyle(fontWeight: FontWeight.bold))),
      body: isLoading ? Center(child: CircularProgressIndicator())
          : users.isEmpty ? Center(child: Text("no_users_available".tr()))
          : ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];

          return InkWell(
            onTap: () {
            String chatId = Provider.of<UserProvider>(context, listen: false).chatId(user.uid);
            Navigator.push(context, MaterialPageRoute(builder: (context) =>
                ChatScreen(chatId: chatId, senderId: widget.currentUserId, receiverId: user.uid),),
            );
          },
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(usersPfp[index]!),
              ),
              title: Text(user.fullName, style: TextStyle(fontWeight: FontWeight.bold),),
              subtitle: Text(user.username,
                  style: TextStyle(color: Theme.of(context).colorScheme.primary.withOpacity(0.5))),
            ),
          );
        },
      ),
    );
  }
}
