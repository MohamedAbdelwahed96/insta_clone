import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/data/user_model.dart';
import 'package:instagram_clone/data/story_model.dart';
import 'package:instagram_clone/logic/media_provider.dart';
import 'package:instagram_clone/logic/user_provider.dart';
import 'package:instagram_clone/presentation/widgets/video_player_widget.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:video_player/video_player.dart';

class StoryScreen extends StatefulWidget {
  final UserModel user;
  const StoryScreen({super.key, required this.user});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  List<StoryModel> stories = [];
  List<String> mediaUrls = [];
  String? pfp;

  PageController pageController = PageController();
  int currentIndex = 0;
  List<double> _progressList = [];
  bool isPaused = false;
  Timer? _timer;
  Duration _videoDuration = Duration(seconds: 10);

  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _fetchStories();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _videoController?.dispose();
    super.dispose();
  }

  void _fetchStories() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final mediaProvider = Provider.of<MediaProvider>(context, listen: false);

    final fetchedStories = await userProvider.getRecentStories(widget.user.uid);
    final profilePic = await mediaProvider.getImage(
        bucketName: "users", folderName: widget.user.uid, fileName: widget.user.pfpUrl);

    final storyMediaUrls = await Future.wait(
      fetchedStories.map((story) => mediaProvider.getImage(
        bucketName: "stories", folderName: story.storyId, fileName: story.mediaUrl,
      )),
    );

    if (mounted) {
      setState(() {
        pfp = profilePic;
        mediaUrls = storyMediaUrls;
        stories = fetchedStories;
        _progressList = List.filled(mediaUrls.length, 0.0);
      });
      if (mediaUrls.isNotEmpty) _startProgress();
    }
  }

  void _startProgress() {
    _timer?.cancel();
    if (isPaused ||
        (stories[currentIndex].isVideo &&
            (_videoController?.value.isPlaying != true ||
                _videoController?.value.buffered.isEmpty == true))) {
      return;
    }

    int duration = stories[currentIndex].isVideo ? (_videoDuration.inMilliseconds) : 3000;

    _timer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      if (mounted && !isPaused) {
        setState(() {
          _progressList[currentIndex] += 50 / duration;
          if (_progressList[currentIndex] >= 1.0) _onNextStory();
        });
      }
    });
  }

  void _onNextStory() {
    if (currentIndex < mediaUrls.length - 1) {
      _progressList[currentIndex] = 1.0;
      setState(() => currentIndex++);
      pageController.animateToPage(currentIndex,
          duration: Duration(milliseconds: 300), curve: Curves.easeIn);
      _startProgress();
    } else {
      _timer?.cancel();
      Navigator.pop(context);
    }
  }

  void _onPreviousStory() {
    if (currentIndex > 0) {
      setState(() {
        _progressList = List.filled(mediaUrls.length, 0.0);
        currentIndex--;
      });
      pageController.animateToPage(currentIndex,
          duration: Duration(milliseconds: 300), curve: Curves.easeIn);
      _startProgress();
    } else {
      setState(() => _progressList = List.filled(mediaUrls.length, 0.0));
      _startProgress();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (mediaUrls.isEmpty) return Center(child: CircularProgressIndicator());

    return Consumer2<MediaProvider, UserProvider>(
        builder: (context, mediaProvider, userProvider, _) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                PageView.builder(
                  controller: pageController,
                  itemCount: mediaUrls.length,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return stories[currentIndex].isVideo
                        ? VideoPlayerWidget(
                      videoUrl: mediaUrls[index],
                      autoPlay: true,
                      onPlay: () {
                        _startProgress();
                        isPaused = false;
                      },
                      onPause: () {
                        _timer?.cancel();
                        isPaused = true;
                      },
                      onDuration: (duration) => setState(() => _videoDuration = duration),
                      onControllerInitialized: (controller) {
                        _videoController = controller;
                        _videoController!.addListener(() {
                          if (_videoController!.value.position >= _videoController!.value.duration) {
                            _onNextStory();
                          }
                          if (_videoController!.value.isPlaying && _videoController!.value.buffered.isNotEmpty) {
                            _startProgress();
                          }
                        });
                        if (_videoController!.value.isPlaying && _videoController!.value.buffered.isNotEmpty) {
                          _startProgress();
                        }
                      },
                    )
                        : Image.network(mediaUrls[index],
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress != null) {
                          _startProgress();
                        }
                        return child;
                      },
                    );
                  },
                ),
                GestureDetector(
                  onTapUp: (details) {
                    final width = MediaQuery.of(context).size.width;
                    if (details.globalPosition.dx < width / 5) {
                      _onPreviousStory();
                    } else {
                      _onNextStory();
                    }
                  },
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: List.generate(
                          mediaUrls.length,
                              (index) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2.0),
                              child: LinearProgressIndicator(
                                value: _progressList[index],
                                backgroundColor: Colors.grey.shade800,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
                      child: Row(
                        spacing: 10,
                        children: [
                          CircleAvatar(backgroundImage: NetworkImage(pfp!)),
                          Text(widget.user.username,
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            timeago.format(stories[currentIndex].createdAt, locale: 'en_short'),
                            style: TextStyle(color: Colors.grey),
                          ),
                          Spacer(),
                          PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert, color: Colors.white),
                            onOpened: () {
                              isPaused = true;
                              _timer?.cancel();
                              _videoController?.pause();
                            },
                            onCanceled: () {
                              isPaused = false;
                              _startProgress();
                              _videoController?.play();
                            },
                            onSelected: (value) async{
                              if (value == 'Delete') {
                                await mediaProvider.deleteStory(context, stories[currentIndex]);
                                _onNextStory();
                              }
                            },
                            itemBuilder: (context) => [
                              if (stories[currentIndex].userId == userProvider.currentUser!.uid)
                                PopupMenuItem(value: "Delete", child: Text("delete".tr())),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          );
        });
  }
}