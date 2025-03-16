import 'dart:async';
import 'package:flutter/material.dart';
import 'package:instagram_clone/data/story_model.dart';
import 'package:instagram_clone/data/user_model.dart';
import 'package:instagram_clone/logic/media_provider.dart';
import 'package:instagram_clone/logic/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class StoryController {
  final UserModel user;
  final BuildContext context;
  final Function setState;
  late PageController pageController;
  List<StoryModel> stories = [];
  List<String> mediaUrls = [];
  String? pfp;
  List<double> progressList = [];
  int currentIndex = 0;
  bool isPaused = false;
  Timer? _timer;
  Duration _videoDuration = const Duration(seconds: 10);
  VideoPlayerController? _videoController;

  StoryController(this.user, this.context, this.setState) {
    pageController = PageController();
  }

  void fetchStories() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final mediaProvider = Provider.of<MediaProvider>(context, listen: false);

    final fetchedStories = await userProvider.getRecentStories(user.uid);
    final profilePic = await mediaProvider.getImage(
        bucketName: "users", folderName: user.uid, fileName: user.pfpUrl);

    final storyMediaUrls = await Future.wait(
      fetchedStories.map((story) => mediaProvider.getImage(
        bucketName: "stories", folderName: story.storyId, fileName: story.mediaUrl,
      )),
    );

    setState(() {
      pfp = profilePic;
      mediaUrls = storyMediaUrls;
      stories = fetchedStories;
      progressList = List.filled(mediaUrls.length, 0.0);
      startProgress();
    });
  }

  void startProgress() {
    if (isPaused || (stories[currentIndex].isVideo && _videoController?.value.isBuffering == true)) return;

    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        progressList[currentIndex] += 50 / (_videoDuration.inMilliseconds);
        if (progressList[currentIndex] >= 1.0) onNextStory();
      });
    });
  }

  void onNextStory() {
    if (currentIndex < mediaUrls.length - 1) {
      setState(() {
        progressList[currentIndex] = 1.0;
        currentIndex++;
      });
      pageController.animateToPage(currentIndex, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
      startProgress();
    } else {
      _timer?.cancel();
      Navigator.pop(context);
    }
  }

  void onPreviousStory() {
    if (currentIndex > 0) {
      setState(() {
        progressList = List.filled(mediaUrls.length, 0.0);
        currentIndex--;
      });
      pageController.animateToPage(currentIndex, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
      startProgress();
    }
  }

  void updateVideoDuration(Duration duration) {
    _videoDuration = duration;
  }

  void setVideoController(VideoPlayerController controller) {
    _videoController = controller;
    _videoController?.addListener(() {
      if (_videoController!.value.position >= _videoController!.value.duration) {
        onNextStory();
      }
    });
  }

  Future<void> deleteCurrentStory() async {
    final mediaProvider = Provider.of<MediaProvider>(context, listen: false);
    await mediaProvider.deleteStory(context, stories[currentIndex]);
    onNextStory();
  }

  void dispose() {
    _timer?.cancel();
    _videoController?.dispose();
  }
}
