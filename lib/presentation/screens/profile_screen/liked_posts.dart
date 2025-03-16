import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/data/post_model.dart';
import 'package:instagram_clone/data/user_model.dart';
import 'package:instagram_clone/logic/media_provider.dart';
import 'package:instagram_clone/logic/user_provider.dart';
import 'package:instagram_clone/presentation/screens/profile_screen/posts_screen.dart';
import 'package:instagram_clone/presentation/skeleton_loading/profile_posts_loading.dart';
import 'package:instagram_clone/presentation/widgets/video_player_widget.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';

class LikedPosts extends StatefulWidget {
  final UserModel user;
  const LikedPosts({super.key, required this.user});

  @override
  State<LikedPosts> createState() => _LikedPostsState();
}

class _LikedPostsState extends State<LikedPosts> {
  List<PostModel>? _posts;
  List<String>? _mediaUrls;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final mediaProvider = Provider.of<MediaProvider>(context, listen: false);

    List<PostModel> fetchedPosts = await userProvider.getLikedPosts(widget.user.uid);
    List<String> fetchedMediaUrls = await Future.wait(
      fetchedPosts.map((post) async => await mediaProvider.getImage(
          bucketName: "posts", folderName: post.postId, fileName: post.mediaUrls[0]),
      ),
    );

    setState(() {
      _posts = fetchedPosts;
      _mediaUrls = fetchedMediaUrls;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_posts == null || _mediaUrls == null) return SkeletonProfilePost();
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text("favorite".tr()),
      ),
      body: _posts!.isNotEmpty
          ? GridView.builder(
        physics: BouncingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1),
        itemCount: _posts!.length,
        itemBuilder: (context, index) {
          String extension = _mediaUrls![index].substring(_mediaUrls![index].lastIndexOf("."));
          String mimeType = lookupMimeType("file$extension")!;
          bool isVideo = mimeType.startsWith("video/");

          return InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) =>
                PostsScreen(user: widget.user, posts: _posts!,initialIndex: index
                ))),
            child: Stack(
              children: [
                SizedBox.expand(
                  child: isVideo
                      ? VideoPlayerWidget(videoUrl: _mediaUrls![index])
                      : Image.network(_mediaUrls![index], fit: BoxFit.cover),
                ),
                _posts![index].mediaUrls.length > 1
                    ? Positioned(top: 10, right: 10,
                  child:
                    ImageIcon(AssetImage("assets/icons/multiple.png"), color: Colors.white)
                )
                    : SizedBox(),
              ],
            ),
          );
        },
      )
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 65,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: theme.surface,
              child: Icon(
                Icons.photo_camera_outlined,
                size: 80,
                color: theme.primary,
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            "no_posts_yet".tr(),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
