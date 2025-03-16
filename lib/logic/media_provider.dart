import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/data/post_model.dart';
import 'package:instagram_clone/data/reel_model.dart';
import 'package:instagram_clone/data/story_model.dart';
import 'package:instagram_clone/data/user_model.dart';
import 'package:instagram_clone/logic/user_provider.dart';
import 'package:instagram_clone/services/notification.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:instagram_clone/core/dialogs.dart';

class MediaProvider extends ChangeNotifier{
  final _supa = Supabase.instance.client.storage;
  final _store = FirebaseFirestore.instance;
  String? filename;
  List<String> media=[];
  PlatformFile? mediaFile;
  List<PlatformFile> mediaFiles=[];
  double uploadProgress = 0;

  void _setProgress(double progress) {
    uploadProgress = progress;
    notifyListeners();
  }

  Future notifyFollowers(context, String mediaType) async{
    final user = Provider.of<UserProvider>(context, listen: false);
    final thisUser = await _store.collection("users").doc(user.currentUser!.uid).get();
    List<UserModel> followers = await user.getFollows(user.currentUser!.uid, "followers");
    List<String> fcmTokens = followers
        .map((follower) => follower.fcmToken)
        .where((token) => token.isNotEmpty)
        .toList();

    final Map<String, dynamic> data = {
      "profileId": user.currentUser!.uid,
      "screen": "/profile"
    };

    if (fcmTokens.isNotEmpty) {
      await Future.wait(fcmTokens.map((token) =>
          NotificationService.sendPushNotification(
              token, thisUser["username"], "recently shared a new $mediaType", data)));
    }
  }

  Future selectMedia(FileType type, {bool multiple = false}) async {
    final response = await FilePicker.platform.pickFiles(type: type, allowMultiple: multiple);
    if (response != null) {
      if (multiple) {
        mediaFiles = response.files;
      } else {
        mediaFile = response.files.first;
      }
    }
    notifyListeners();
  }

  Future uploadMedia(context, {required String bucketName, required String folder}) async {
    if (mediaFile == null) {
      showScaffoldMSG(context, "no_image_attached");
      return;
    }
    try {
      filename = "${DateTime.now().millisecondsSinceEpoch}.${mediaFile!.extension}";
      _setProgress(0.1);
      await _supa.from(bucketName).upload("$folder/$filename", File(mediaFile!.path!));
      _setProgress(1);
      showScaffoldMSG(context, "uploaded_successfully");
      notifyListeners();
      mediaFile = null;
    } catch (e) {
      showScaffoldMSG(context, "${"upload_failed".tr()}: ${e.toString()}");
    } finally {
      _setProgress(0.0);
    }
  }

  Future uploadMultimedia(BuildContext context, String id) async {
    if (mediaFiles.isEmpty) {
      showScaffoldMSG(context, "no_media_attached");
      return;
    }
    media=[];
    try {
      for (var file in mediaFiles) {
        if (file.path == null) continue;
        filename = "${DateTime.now().millisecondsSinceEpoch}.${file.extension}";
        media.add(filename!);
        _setProgress(0.1);
        await _supa.from("posts").upload("$id/$filename", File(file.path!));
        _setProgress(1);
      }
      showScaffoldMSG(context, "uploaded_successfully");
      notifyListeners();
      mediaFiles.clear();
    } catch (e) {
      showScaffoldMSG(context, "${"upload_failed".tr()}: ${e.toString()}");
    } finally {
      _setProgress(0.0);
    }
  }

  Future<String> getImage({
    required String bucketName, required String folderName, required String fileName}) async {
    try {
      String img = await _supa.from(bucketName).getPublicUrl("$folderName/$fileName");
      return img;
    } catch (e) {
      return "";
    }
  }

  Future<List<String>>getImages({required String bucketName, required String folderName})async{
    try{
      final response = await _supa.from(bucketName).list(path: folderName);
      final media = response.map((file){
          return _supa.from(bucketName).getPublicUrl("$folderName/${file.name}");}).toList();
        return media;
    }
    catch(e){
      return [];
    }
  }

  Future uploadPost(context, PostModel post) async {
    final user = Provider.of<UserProvider>(context, listen: false);

    try{
      await _store.collection('posts').doc(post.postId).set(post.toMap());
      await _store.collection("users").doc(user.currentUser!.uid).update({"posts":FieldValue.arrayUnion([post.postId])});
      showScaffoldMSG(context, "uploaded_successfully");
      notifyFollowers(context, "post");
    }
    catch(e){
      showScaffoldMSG(context, "upload_failed");
    }
    notifyListeners();
  }

  Future deletePost(context, PostModel post) async {
    try{
      bool? confirmDelete = await showConfirmationDialog(
        context, "delete_post".tr(), "confirm_delete_post".tr(),);
      if (confirmDelete != true) return;

      final user = Provider.of<UserProvider>(context, listen: false).currentUser!.uid;
      await _store.collection('posts').doc(post.postId).delete();
      await _store.collection("users").doc(user).update({"posts":FieldValue.arrayRemove([post.postId])});
      await _supa.from("posts").remove(post.mediaUrls.map((file) => "${post.postId}/$file").toList());
      showScaffoldMSG(context, "deleted_successfully");
    }
    catch(e){
      showScaffoldMSG(context, "${"something_went_wrong".tr()} $e");
    }
    notifyListeners();
  }

  Future uploadStory(context, StoryModel story) async {
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    try{
      await _store.collection('stories').doc(story.storyId).set(story.toMap());
      await _store.collection("users").doc(user!.uid).update({"stories":FieldValue.arrayUnion([story.storyId])});
      showScaffoldMSG(context, "uploaded_successfully");
      notifyFollowers(context, "story");
    }
    catch(e){
      showScaffoldMSG(context, "upload_failed");
    }
    notifyListeners();
  }

  Future deleteStory(context, StoryModel story) async {
    try{
      bool? confirmDelete = await showConfirmationDialog(
        context, "delete_story".tr(), "confirm_delete_story".tr(),);
      if (confirmDelete != true) return;

      final user = Provider.of<UserProvider>(context, listen: false).currentUser!.uid;
      await _store.collection('stories').doc(story.storyId).delete();
      await _store.collection("users").doc(user).update({"stories":FieldValue.arrayRemove([story.storyId])});
      await _supa.from("stories").remove(["${story.storyId}/${story.mediaUrl}"]);
      showScaffoldMSG(context, "deleted_successfully");
    }
    catch(e){
      showScaffoldMSG(context, "${"something_went_wrong".tr()} $e");
    }
    notifyListeners();
  }

  Future uploadReel(context, ReelModel reel) async {
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    try{
      await _store.collection('reels').doc(reel.reelId).set(reel.toMap());
      await _store.collection("users").doc(user!.uid).update({"reels":FieldValue.arrayUnion([reel.reelId])});
      showScaffoldMSG(context, "uploaded_successfully");
      notifyFollowers(context, "reel");
    }
    catch(e){
      showScaffoldMSG(context, "upload_failed");
    }
    notifyListeners();
  }

  Future deleteReel(context, ReelModel reel) async {
    try{
      bool? confirmDelete = await showConfirmationDialog(
        context, "delete_reel".tr(), "confirm_delete_reel".tr(),);
      if (confirmDelete != true) return;

      final user = Provider.of<UserProvider>(context, listen: false).currentUser!.uid;
      await _store.collection('reels').doc(reel.reelId).delete();
      await _store.collection("users").doc(user).update({"reels":FieldValue.arrayRemove([reel.reelId])});
      await _supa.from("reels").remove(["${reel.reelId}/${reel.videoUrl}"]);
      showScaffoldMSG(context, "deleted_successfully");
    }
    catch(e){
      showScaffoldMSG(context, "${"something_went_wrong".tr()} $e");
    }
    notifyListeners();
  }
}
