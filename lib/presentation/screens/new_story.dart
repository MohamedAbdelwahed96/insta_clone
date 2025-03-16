import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/data/story_model.dart';
import 'package:instagram_clone/data/user_model.dart';
import 'package:instagram_clone/logic/media_provider.dart';
import 'package:instagram_clone/logic/user_provider.dart';
import 'package:instagram_clone/presentation/widgets/navigation_bot_bar.dart';
import 'package:instagram_clone/presentation/widgets/video_player_widget.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class NewStory extends StatefulWidget {
  const NewStory({super.key});

  @override
  State<NewStory> createState() => _NewStoryState();
}

class _NewStoryState extends State<NewStory> {
  bool _isVideo = false;
  UserModel? user;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    final usr = Provider.of<UserProvider>(context, listen: false);
    UserModel? fetchedUser = await usr.getUserInfo(usr.currentUser!.uid);
    setState(() => user = fetchedUser);
  }

  @override
  Widget build(BuildContext context) {

    return Consumer<MediaProvider>(builder: (context, provider, _){
      final theme = Theme.of(context).colorScheme;
      return Scaffold(
        appBar: AppBar(
          title: Text("add_to_story".tr()),
          centerTitle: true,
          leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () {
            provider.mediaFile = null;
            Navigator.pop(context);
          }),
          actions: [
            provider.uploadProgress > 0 && provider.uploadProgress < 1.0
                ? Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CircularProgressIndicator())
                : IconButton(
              icon: Icon(Icons.upload, color: provider.mediaFile != null ? theme.primary : theme.primary.withOpacity(0.5)),
              onPressed: provider.mediaFile == null ? null
                  : () async {
                final storyID = const Uuid().v1();
                await provider.uploadMedia(context, bucketName: "stories", folder: storyID);
                if (provider.filename == null) return;
                await provider.uploadStory(context, StoryModel(
                        storyId: storyID,
                        userId: user!.uid,
                        mediaUrl: provider.filename!,
                        isVideo: _isVideo,
                        createdAt: DateTime.now()));
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>NavigationBotBar()));
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                height: MediaQuery.of(context).size.height*0.3,
                width: MediaQuery.of(context).size.width,
                color: theme.inversePrimary,
                child: provider.mediaFile==null
                    ? Center(child: IconButton(
                    onPressed: () async {
                      await provider.selectMedia(FileType.media);
                      setState(() => _isVideo = lookupMimeType(provider.mediaFile!.path!)!.startsWith("video/"));
                    },
                    icon: Icon(Icons.add_a_photo, size: 50, color: theme.secondary)),)
                    : Stack(
                  children: [
                    Center(child: _isVideo ?
                    VideoPlayerWidget(videoFile: File(provider.mediaFile!.path!))
                        : Image.file(File(provider.mediaFile!.path!), fit: BoxFit.fitHeight)),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: IconButton(
                        icon: Icon(Icons.close, size: 30),
                        onPressed: () {
                          provider.mediaFile=null;
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
