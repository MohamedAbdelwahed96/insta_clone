import 'package:flutter/material.dart';
import 'package:instagram_clone/data/post_model.dart';
import 'package:instagram_clone/data/user_model.dart';
import 'package:instagram_clone/logic/media_provider.dart';
import 'package:instagram_clone/presentation/screens/home_screen/story_widget.dart';
import 'package:instagram_clone/presentation/screens/new_post.dart';
import 'package:instagram_clone/presentation/screens/messages_screen/messages_screen.dart';
import 'package:instagram_clone/presentation/skeleton_loading/home_screen_loading.dart';
import 'package:provider/provider.dart';
import 'package:instagram_clone/logic/user_provider.dart';
import 'package:instagram_clone/presentation/widgets/post_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<UserModel>? users;
  List<String>? pfpUrls;
  List<PostModel>? _posts;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    List<PostModel>? fetchedPosts = await userProvider.getAllPosts();
    List<UserModel> fetchedFollowings = await userProvider.getFollows(userProvider.currentUser!.uid, "following");
    UserModel? currentUser = await userProvider.getUserInfo(userProvider.currentUser!.uid);

    List<UserModel> fetchedUsers = [currentUser!, ...fetchedFollowings];

    List<String> fetchedPfpUrls = await Future.wait(
      fetchedUsers.map((user) => Provider.of<MediaProvider>(context, listen: false).getImage(
        bucketName: "users", folderName: user.uid, fileName: user.pfpUrl),
      ),
    );

    setState(() {
      users = fetchedUsers;
      pfpUrls = fetchedPfpUrls;
      _posts = fetchedPosts;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_posts == null || pfpUrls == null || users == null) return SkeletonHomeScreen();
    final theme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              automaticallyImplyLeading: false,
              flexibleSpace: Material(
                color: theme.surface,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Image.asset("assets/images/Logo.png",
                          width: MediaQuery.of(context).size.width * 0.26,
                          color: theme.primary),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_drop_down),
                      Spacer(),
                      IconButton(
                          onPressed: (){},
                          icon: ImageIcon(AssetImage("assets/icons/like.png"))),
                      IconButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(
                              builder: (context) => MessagesScreen(user: users![0],))),
                          icon: ImageIcon(AssetImage("assets/icons/chat.png"))),
                      IconButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(
                              builder: (context) => NewPostScreen())),
                          icon: ImageIcon(AssetImage("assets/icons/new_post.png"))),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
                child: StoryWidget(users: users!, pfpUrls: pfpUrls!)),
            SliverToBoxAdapter(
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _posts!.length,
                  itemBuilder: (context, index) => PostWidget(post: _posts![index]),
                )
            )
          ],
        ),
      ),
    );
  }
}
