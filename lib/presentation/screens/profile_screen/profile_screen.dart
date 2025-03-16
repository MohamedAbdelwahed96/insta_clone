import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/data/user_model.dart';
import 'package:instagram_clone/logic/user_provider.dart';
import 'package:instagram_clone/presentation/screens/profile_screen/profile_header.dart';
import 'package:instagram_clone/presentation/screens/profile_screen/profile_posts.dart';
import 'package:instagram_clone/presentation/screens/profile_screen/profile_reels.dart';
import 'package:instagram_clone/presentation/screens/profile_screen/tagged_posts.dart';
import 'package:instagram_clone/presentation/screens/settings_screen.dart';
import 'package:instagram_clone/core/dialogs.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  final String profileId;
  const ProfileScreen({super.key, required this.profileId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    UserModel? fetchedUser =
    await Provider.of<UserProvider>(context, listen: false).getUserInfo(widget.profileId);
    setState(() => _user = fetchedUser);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, provider, _){
      if (_user == null) return Center(child: CircularProgressIndicator());

      return Scaffold(
        appBar: provider.currentUser!.uid != widget.profileId
            ? AppBar(
          title: Text(_user!.username, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          centerTitle: true,
          leading: Icon(Icons.arrow_back_ios_new),
          actions: [
            IconButton(
              icon: Icon(Icons.notifications_outlined),
              onPressed: () {},
            ),
            moreOptions(),
          ],
        )
            :AppBar(
          title: Text(_user!.username, style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
                onPressed: ()=> showAddNewList(context),
                icon: ImageIcon(AssetImage("assets/icons/new_post.png"))),
            IconButton(
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (context)=>SettingsScreen(user: _user!))),
              icon: Icon(Icons.menu, size: 32),
            ),
          ],
        ),
        body: DefaultTabController(
          length: 3,
          child: NestedScrollView(
            physics: NeverScrollableScrollPhysics(),
            headerSliverBuilder: (context, isScrolled){
              return [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ProfileHeader(user: _user!),
                  ),
                ),
                SliverPersistentHeader(
                  delegate: MyDelegate(
                      TabBar(
                        tabs: [
                          Tab(icon: Icon(Icons.grid_on)),
                          Tab(icon: ImageIcon(AssetImage("assets/icons/reels.png"))),
                          Tab(icon: Icon(Icons.person_pin_outlined)),
                        ],
                        indicatorSize: TabBarIndicatorSize.tab,
                        unselectedLabelColor: Color.fromRGBO(196, 196, 196, 1),
                      )
                  ),
                  floating: true,
                  pinned: true,
                )
              ];
            },
            body: TabBarView(
                children: [
                  ProfilePosts(user: _user!),
                  ProfileReels(user: _user!),
                  TaggedPosts(user: _user!)
                ]
            ),
          ),
        ),
      );
    });
  }

  Widget moreOptions(){
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_horiz),
      color: Theme.of(context).colorScheme.surface,
      onSelected: (String value) {
        Navigator.push(context, MaterialPageRoute(builder: (context) =>
        value == "Photos" ? Container(color: Colors.red)
            : value == "Videos" ? Container(color: Colors.yellow)
            : value == "Settings" ? Container(color: Colors.pink)
            : SizedBox(),
          ),
        );
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: "Photos", child: Text("Photos & Screens")),
        PopupMenuItem(value: "Videos", child: Text("Videos")),
        PopupMenuItem(value: "Settings", child: Text("settings".tr())),
      ],
    );
  }
}

class MyDelegate extends SliverPersistentHeaderDelegate{
  MyDelegate(this.tabBar);
  final TabBar tabBar;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Theme.of(context).colorScheme.surface, child: tabBar);
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}