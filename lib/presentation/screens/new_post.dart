import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/core/controllers.dart';
import 'package:instagram_clone/data/user_model.dart';
import 'package:instagram_clone/presentation/widgets/navigation_bot_bar.dart';
import 'package:instagram_clone/presentation/widgets/video_player_widget.dart';
import 'package:mime/mime.dart';
import 'package:uuid/uuid.dart';
import '/data/post_model.dart';
import '/logic/media_provider.dart';
import '/logic/user_provider.dart';
import 'package:provider/provider.dart';

class NewPostScreen extends StatefulWidget {
  @override
  _NewPostScreenState createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final formControllers = FormControllers();
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
  void dispose() {
    formControllers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MediaProvider>(builder: (context, provider, _){
      final theme = Theme.of(context).colorScheme;
          return Scaffold(
            appBar: AppBar(
              title: Text("new_post".tr()),
              centerTitle: true,
              leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () {
                provider.mediaFiles = [];
                Navigator.pop(context);
              }),
              actions: [
                provider.uploadProgress > 0 && provider.uploadProgress < 1.0
                    ? Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CircularProgressIndicator())
                    : IconButton(
                  icon: Icon(Icons.upload, color: provider.mediaFiles.isNotEmpty ? theme.primary : theme.primary.withOpacity(0.5)),
                  onPressed: provider.mediaFiles.isEmpty ? null
                  : () async {
                    final postID = const Uuid().v1();
                    await provider.uploadMultimedia(context, postID);
                    if (provider.filename == null) return;
                    await provider.uploadPost(context, PostModel(
                        postId: postID,
                        uid: user!.uid,
                        username: user!.username,
                        userProfileImage: user!.pfpUrl,
                        mediaUrls: provider.media,
                        caption: formControllers.caption.text,
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
                    child: provider.mediaFiles.isEmpty ? Center(
                          child: IconButton(
                          onPressed: ()async => await provider.selectMedia(FileType.media, multiple: true),
                          icon: Icon(Icons.add_a_photo, size: 50, color: theme.secondary)),
                        ) :
                    PageView.builder(
                        controller: formControllers.page,
                        itemCount: provider.mediaFiles.length,
                        itemBuilder: (context, index) {
                          final file = provider.mediaFiles[index];
                          final path = file.path!;

                          return Stack(
                            children: [
                              if(lookupMimeType(path)!.startsWith("video/"))
                                Center(child: VideoPlayerWidget(videoFile: File(path), tapToPlayPause: true))
                              else if(lookupMimeType(path)!.startsWith("image/"))
                                Center(child: Image.file(File(file.path!), fit: BoxFit.fitHeight,)),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: IconButton(
                                  icon: Icon(Icons.close, size: 30),
                                  onPressed: () {
                                    provider.mediaFiles.removeAt(index);
                                    setState(() {});
                                  },
                                ),
                              ),
                            ],
                          );
                        }),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: TextField(
                    controller: formControllers.caption,
                    decoration: InputDecoration(
                      hintText: "write_caption".tr(),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ),
              ],
            ),
          );
          },
    );
  }
}
