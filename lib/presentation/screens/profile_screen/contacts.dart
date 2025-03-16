import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/data/user_model.dart';
import 'package:instagram_clone/logic/media_provider.dart';
import 'package:instagram_clone/logic/user_provider.dart';
import 'package:instagram_clone/presentation/screens/profile_screen/profile_screen.dart';
import 'package:provider/provider.dart';

class Contacts extends StatefulWidget {
  final UserModel user;
  const Contacts({super.key, required this.user});

  @override
  State<Contacts> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  String? userPfp;
  bool? isFollowing;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final mediaProvider = Provider.of<MediaProvider>(context, listen: false);

    final image = await mediaProvider.getImage(
        bucketName: "users", folderName: widget.user.uid, fileName: widget.user.pfpUrl);
    bool follow = await userProvider.checkFollow(widget.user.uid);

    setState(() {
      userPfp = image;
      isFollowing = follow;
    });
  }

  void toggleFollow() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.followProfile(widget.user.uid, context);
    bool follow = await userProvider.checkFollow(widget.user.uid);
    setState(() => isFollowing = follow);
  }

  @override
  Widget build(BuildContext context) {
    if(userPfp == null) return Center(child: CircularProgressIndicator());

    final screen = MediaQuery.of(context).size;
    final theme = Theme.of(context).colorScheme;

    return ListTile(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (context) => ProfileScreen(profileId: widget.user.uid))
      ),
      leading: CircleAvatar(backgroundImage: NetworkImage(userPfp!)),
      title: Text(widget.user.fullName),
      subtitle: Text(widget.user.username, style: TextStyle(color: theme.primary.withOpacity(0.5))),
      trailing: widget.user.uid == Provider.of<UserProvider>(context, listen: false).currentUser!.uid ? null
          : InkWell(
        onTap: toggleFollow,
        child: Container(
          width: screen.width * .25,
          height: screen.height * 0.05,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isFollowing! ? Colors.grey.withOpacity(0.2) : Colors.blue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            isFollowing! ? "unfollow".tr() : "follow".tr(),
            style: TextStyle(color: isFollowing! ? theme.primary : Colors.white),
          ),
        ),
      ),
    );
  }
}
