import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/data/user_model.dart';
import 'package:instagram_clone/logic/media_provider.dart';
import 'package:instagram_clone/logic/user_provider.dart';
import 'package:instagram_clone/presentation/screens/reels_screen.dart';
import 'package:instagram_clone/presentation/screens/search_screen/search_screen.dart';
import 'package:provider/provider.dart';
import '../screens/home_screen/home_screen.dart';
import '../screens/profile_screen/profile_screen.dart';

class NavigationBotBar extends StatefulWidget {
  final int index;
  const NavigationBotBar({super.key, this.index=0});

  @override
  State<NavigationBotBar> createState() => _NavigationBotBarState();
}

class _NavigationBotBarState extends State<NavigationBotBar> {
  UserModel? user;
  String? img;
  int _selectedPageIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    fetchData();
    _selectedPageIndex = widget.index;
    _pageController = PageController(initialPage: _selectedPageIndex);
  }

  void fetchData() async {
    final userProvider =  Provider.of<UserProvider>(context, listen: false);
    final mediaProvider = Provider.of<MediaProvider>(context, listen: false);
    UserModel? fetchedUser = await userProvider.getUserInfo(userProvider.currentUser!.uid);
    String? pfp = fetchedUser == null ? null :
    await mediaProvider.getImage(bucketName: "users", folderName: fetchedUser.uid, fileName: fetchedUser.pfpUrl);
    setState(() {
      user = fetchedUser;
      img = pfp;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (img == null || user == null) return Center(child: CircularProgressIndicator());

    return Consumer<MediaProvider>(builder: (context, provider, _){
      final theme = Theme.of(context).colorScheme;
      return Scaffold(
        body: PageView(
            controller: _pageController,
            onPageChanged: (index)=> setState(() => _selectedPageIndex=index),
            scrollDirection: Axis.horizontal,
            children: [
              HomeScreen(),
              SearchScreen(),
              ReelsScreen(),
              Center(child: Text("coming_soon".tr())),
              ProfileScreen(profileId: user!.uid)
            ]),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(splashFactory: NoSplash.splashFactory), // disable the splash effect
          child: Container(
            decoration: BoxDecoration(
                border: Border(top: BorderSide(color: theme.primary.withOpacity(0.1)))),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              currentIndex: _selectedPageIndex,
              onTap: (index) => _pageController.animateToPage(index, duration: Duration(milliseconds: 100), curve: Curves.ease),
              items: List.generate(4, (index) => _items(index))
                ..add(BottomNavigationBarItem(
                  icon: CircleAvatar(radius: 18, backgroundImage: NetworkImage(img!)),
                  label: "",
                )),
            ),
          ),
        ) ,
      );
    });
  }

  BottomNavigationBarItem _items(int index) {
    const icons = ["home", "search", "reels", "shop"];
    String iconName = icons[index];
    return BottomNavigationBarItem(
      icon: ImageIcon(AssetImage(
          "assets/icons/${_selectedPageIndex == index ? '${iconName}_bold' : iconName}.png"),
          color: Theme.of(context).colorScheme.primary), label: "");
  }
}