import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/core/controllers.dart';
import 'package:instagram_clone/data/reel_model.dart';
import 'package:instagram_clone/data/user_model.dart';
import 'package:instagram_clone/logic/media_provider.dart';
import 'package:instagram_clone/logic/user_provider.dart';
import 'package:instagram_clone/presentation/widgets/navigation_bot_bar.dart';
import 'package:instagram_clone/presentation/widgets/video_player_widget.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class NewReel extends StatefulWidget {
  const NewReel({super.key});

  @override
  State<NewReel> createState() => _NewReelState();
}

class _NewReelState extends State<NewReel> {
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
          title: Text("new_reel".tr()),
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
                  : () async{
                final reelID = const Uuid().v1();
                await provider.uploadMedia(context, bucketName: "reels", folder: reelID);
                if (provider.filename == null) return;
                await provider.uploadReel(context,
                    ReelModel(
                        reelId: reelID,
                        userId: user!.uid,
                        videoUrl: provider.filename!,
                        createdAt: DateTime.now(),
                        caption: formControllers.caption.text));
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
                  child: provider.mediaFile == null
                      ? Center(child: IconButton(
                      onPressed: () async => await provider.selectMedia(FileType.video),
                      icon: Icon(Icons.add_a_photo, size: 50, color: theme.secondary)),)
                      : Stack(
                    children: [
                      Center(
                          child: VideoPlayerWidget(videoFile: File(provider.mediaFile!.path!)),
                      ),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: TextField(
                controller: formControllers.caption,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "write_caption".tr(),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
