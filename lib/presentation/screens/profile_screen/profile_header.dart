import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/data/user_model.dart';
import 'package:instagram_clone/logic/media_provider.dart';
import 'package:instagram_clone/logic/user_provider.dart';
import 'package:instagram_clone/presentation/screens/chat_screen/chat_screen.dart';
import 'package:instagram_clone/presentation/screens/edit_profile_screen.dart';
import 'package:instagram_clone/presentation/screens/profile_screen/profile_follows.dart';
import 'package:instagram_clone/presentation/skeleton_loading/profile_header_loading.dart';
import 'package:provider/provider.dart';

class ProfileHeader extends StatefulWidget {
  final UserModel user;
  const ProfileHeader({super.key, required this.user});

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  String? img;
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    String? profilePicture = await Provider.of<MediaProvider>(context, listen: false)
        .getImage(bucketName: "users", folderName: widget.user.uid, fileName: widget.user.pfpUrl);
    bool follow = await userProvider.checkFollow(widget.user.uid);
    setState(() {
      img = profilePicture;
      isFollowing = follow;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (img == null) return SkeletonProfileHeader();

    return Consumer<UserProvider>(builder: (context, provider, _){
      final theme = Theme.of(context).colorScheme;
      final screen = MediaQuery.of(context).size;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: theme.inversePrimary,
                backgroundImage: NetworkImage(img!),
              ),
              SizedBox(width: screen.width * 0.15),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    profileStat(widget.user.posts.length, "posts"),
                    InkWell(
                        onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context) =>
                              ProfileFollows(user: widget.user))),
                        child: profileStat(widget.user.followers.length, "followers")),
                    InkWell(
                        onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context) =>
                            ProfileFollows(user: widget.user))),
                        child: profileStat(widget.user.following.length, "following")),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: screen.height * 0.01),
          Text(widget.user.username, style: TextStyle(color: theme.primary, fontWeight: FontWeight.bold)),
          Text(widget.user.bio, style: TextStyle(color: theme.primary)),
          Text(widget.user.website, style: TextStyle(color: Colors.blue)),
          SizedBox(height: screen.height * 0.01),
          provider.currentUser!.uid != widget.user.uid
              ? Row(
            children: [
              Expanded(
                flex: 1,
                child: InkWell(
                    onTap: toggleFollow,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isFollowing ? Color.fromRGBO(239, 239, 239, 0.2) : Color.fromRGBO(0, 163, 255, 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(isFollowing ? "unfollow".tr() : "follow".tr(),
                          style: TextStyle(color: isFollowing ? theme.primary: Colors.white)),
                    )
                ),
              ),
              SizedBox(width: isFollowing ? 10 : 0),
              if (isFollowing)
                Expanded(flex: 1,
                  child: InkWell(
                    onTap: (){
                      final thisUser = provider.currentUser!.uid;
                      final chatID = provider.chatId(widget.user.uid);

                      Navigator.push(context, MaterialPageRoute(builder: (context) =>
                          ChatScreen(chatId: chatID, senderId: thisUser, receiverId: widget.user.uid)));
                      },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(239, 239, 239, 0.2),
                        borderRadius: BorderRadius.circular(8)),
                      alignment: Alignment.center,
                      child: Text("message".tr() , style: TextStyle(color: theme.primary)),
                    )
                ),
              )
            ],
          )
              : Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (context) => EditProfileScreen())),
                  child: Container(
                    height: screen.height * 0.05,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(239, 239, 239, 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text("edit_profile".tr(), style: TextStyle(color: theme.primary)),
                  ),
                ),
              ),
              SizedBox(width: 10),
              InkWell(
                onTap: () {},
                child: Container(
                    width: screen.height * 0.05,
                    height: screen.height * 0.05,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(239, 239, 239, 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.person_add)),
              ),
            ],
          )
        ],
      );
    });
  }

  void toggleFollow() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.followProfile(widget.user.uid, context);
    bool follow = await userProvider.checkFollow(widget.user.uid);
    setState(() {
      isFollowing = follow;
      if (isFollowing) {
        widget.user.followers.add(widget.user.uid);
      } else {
        widget.user.followers.remove(widget.user.uid);
      }
    });
  }
}

Widget profileStat(int count, String label) {
  return Column(
    children: [
      Text(count.toString(), style: TextStyle(fontWeight: FontWeight.w700)),
      Text(label.tr()),
    ],
  );
}
