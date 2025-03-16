import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/data/user_model.dart';
import 'package:instagram_clone/logic/user_provider.dart';
import 'package:instagram_clone/presentation/screens/profile_screen/contacts.dart';
import 'package:provider/provider.dart';

class ProfileFollows extends StatefulWidget {
  final UserModel user;
  const ProfileFollows({super.key, required this.user});

  @override
  State<ProfileFollows> createState() => _ProfileFollowsState();
}

class _ProfileFollowsState extends State<ProfileFollows> {
  List<UserModel> followingUsers = [];
  List<UserModel> followersUsers = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final fetchedFollowing = await userProvider.getFollows(widget.user.uid, "following");
    final fetchedFollowers = await userProvider.getFollows(widget.user.uid, "followers");

    setState(() {
      followingUsers = fetchedFollowing;
      followersUsers = fetchedFollowers;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.user.username),
          bottom: TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            unselectedLabelColor: theme.secondary.withOpacity(.5),
            tabs: [
              Tab(text: "${widget.user.followers.length} ${"followers".tr()}"),
              Tab(text: "${widget.user.following.length} ${"following".tr()}")
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView.builder(
              itemCount: followersUsers.length,
              itemBuilder: (context, index) {
                return Contacts(user: followersUsers[index]);
              },
            ),
            ListView.builder(
              itemCount: followingUsers.length,
              itemBuilder: (context, index) {
                return Contacts(user: followingUsers[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildUserList(BuildContext context) {
  //   final screen = MediaQuery.of(context).size;
  //   final theme = Theme.of(context).colorScheme;
  //   return ListView.builder(
  //     itemCount: followingUsers.length,
  //     itemBuilder: (context, index) {
  //       final user = followingUsers[index];
  //       return ListTile(
  //         onTap: () => Navigator.push(context,
  //             MaterialPageRoute(builder: (context) => ProfileScreen(profileID: user.uid))
  //         ),
  //         leading: CircleAvatar(backgroundImage: NetworkImage(usersPfp[index] ?? "")),
  //         title: Text(user.fullName),
  //         subtitle: Text(user.username, style: TextStyle(color: theme.primary.withOpacity(0.5))),
  //         trailing: GestureDetector(
  //           onTap: toggleFollow,
  //           child: Container(
  //             width: screen.width * .25,
  //             alignment: Alignment.center,
  //             decoration: BoxDecoration(
  //               color: isFollowing ? Colors.grey.withOpacity(0.2) : Colors.blue,
  //               borderRadius: BorderRadius.circular(8),
  //             ),
  //             child: Text(
  //               isFollowing ? "unfollow".tr() : "follow".tr(),
  //               style: TextStyle(color: isFollowing ? theme.primary : Colors.white),
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
}
