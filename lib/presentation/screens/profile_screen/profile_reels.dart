import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/data/reel_model.dart';
import 'package:instagram_clone/data/user_model.dart';
import 'package:instagram_clone/logic/media_provider.dart';
import 'package:instagram_clone/logic/user_provider.dart';
import 'package:instagram_clone/presentation/screens/reels_screen.dart';
import 'package:instagram_clone/presentation/skeleton_loading/profile_posts_loading.dart';
import 'package:instagram_clone/presentation/widgets/video_player_widget.dart';
import 'package:provider/provider.dart';

class ProfileReels extends StatefulWidget {
  final UserModel user;
  const ProfileReels({super.key, required this.user});

  @override
  State<ProfileReels> createState() => _ProfileReelsState();
}

class _ProfileReelsState extends State<ProfileReels> {
  List<ReelModel>? _reels;
  List<String>? _videoUrl;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final mediaProvider = Provider.of<MediaProvider>(context, listen: false);

    List<ReelModel> fetchedReels = await userProvider.getUserReels(widget.user.uid);
    List<String> fetchedReelsURLs = await Future.wait(
      fetchedReels.map((reel) async => await mediaProvider.getImage(
          bucketName: "reels", folderName: reel.reelId, fileName: reel.videoUrl),
      ),
    );

    setState(() {
      _reels = fetchedReels;
      _videoUrl = fetchedReelsURLs;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_reels == null || _videoUrl == null) return SkeletonProfilePost();
    final theme = Theme.of(context).colorScheme;
    return _reels!.isNotEmpty
        ? GridView.builder(
      physics: BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 1,
          mainAxisSpacing: 1),
      itemCount: _reels!.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) =>
              ReelsScreen(userID: widget.user.uid))),
          child: Stack(
            children: [
              SizedBox.expand(
                child: VideoPlayerWidget(videoUrl: _videoUrl![index])
              ),
              Positioned(bottom: 10, left: 10,
                child: Row(
                  children: [
                    Icon(Icons.remove_red_eye_outlined, color: Colors.white),
                    SizedBox(width: 5),
                    Text(_reels![index].views.length.toString(), style: TextStyle(color: Colors.white),)
                  ],
                ),
              )
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
    );
  }
}
