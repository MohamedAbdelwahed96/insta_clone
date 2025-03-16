import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/data/user_model.dart';
import 'package:instagram_clone/logic/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class StoryHeader extends StatelessWidget {
  final UserModel user;
  final String? profilePic;
  final DateTime createdAt;
  final VoidCallback onDelete;

  const StoryHeader({
    super.key,
    required this.user,
    required this.profilePic,
    required this.createdAt,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    bool isCurrentUser = userProvider.currentUser?.uid == user.uid;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: profilePic != null ? NetworkImage(profilePic!) : null,
            backgroundColor: Colors.grey[800],
            radius: 20,
          ),
          const SizedBox(width: 10),
          Text(
            user.username,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Text(
            timeago.format(createdAt, locale: 'en_short'),
            style: const TextStyle(color: Colors.grey),
          ),
          const Spacer(),
          if (isCurrentUser)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                if (value == 'Delete') {
                  onDelete();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: "Delete",
                  child: Text("delete".tr()),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
