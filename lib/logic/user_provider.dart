import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/data/reel_model.dart';
import 'package:instagram_clone/data/story_model.dart';
import 'package:instagram_clone/logic/media_provider.dart';
import 'package:provider/provider.dart';
import '/data/post_model.dart';
import '/data/user_model.dart';
import 'package:instagram_clone/core/dialogs.dart';

class UserProvider extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _store = FirebaseFirestore.instance;
  final _msg = FirebaseMessaging.instance;
  User? get currentUser => _auth.currentUser;

  bool _isLogged=false;
  bool get isLogged => _isLogged;

  Future signUp(context, UserModel user, String password) async {
    try{
      final media = Provider.of<MediaProvider>(context, listen: false);
      UserCredential userCd = await _auth.createUserWithEmailAndPassword(email: user.email, password: password);
      await media.uploadMedia(context, bucketName: "users", folder: userCd.user!.uid);
      String? token = await _msg.getToken();
      await _store.collection("users").doc(userCd.user!.uid).set(user.toMap());
      await _store.collection("users").doc(userCd.user!.uid).update({
        "uid":userCd.user!.uid,
        "fcmToken":token,
        "pfpUrl":media.filename
      });
      showScaffoldMSG(context, "created_successfully");
      _isLogged=true;
    }
    catch(e){
      showScaffoldMSG(context, "${"something_went_wrong".tr()} $e");
      _isLogged=false;
    }
    notifyListeners();
  }

  Future signIn(context, String email, password) async {
    try{
      String? token = await _msg.getToken();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await _store.collection("users").doc(currentUser!.uid).update({"fcmToken":token});
      showScaffoldMSG(context, "logged_in_successfully");
      _isLogged = true;
    }
    catch(e){
      showScaffoldMSG(context, "${"something_went_wrong".tr()} $e");
      _isLogged=false;
    }
    notifyListeners();
  }

  Future signOut(context) async{
    await _auth.signOut();
    showScaffoldMSG(context, "signed_out_successfully");
  }

  Future saveInfo(context, String name, username, web, bio, email, phone, gender, pfpUrl) async {
    try {
      if(email!=currentUser!.email) {
        await currentUser!.verifyBeforeUpdateEmail(email);
        showScaffoldMSG(context, "check_email_to_confirm");
      }

      User? updatedUser = _auth.currentUser;
      if (updatedUser != null && updatedUser.email == email) {
        _store.collection("users").doc(currentUser!.uid).update({
          "fullName": name,
          "username": username,
          "website": web,
          "bio": bio,
          "email": email,
          "pNumber": phone,
          "gender": gender,
          "pfpUrl": pfpUrl
        });
        showScaffoldMSG(context, "updated_successfully");
      }
    } catch (e) {
      showScaffoldMSG(context, "${"something_went_wrong".tr()} $e");
    }
  }

  Future<UserModel?> getUserInfo(String userID) async {
    try {
      final userData = await _store.collection("users").doc(userID).get();
      return UserModel.fromMap(userData.data() as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  Future<List<UserModel>> getFollows(String userID, String followType) async {
    try {
      final response = await _store.collection("users").doc(userID).get();
      final followIDs = List<String>.from((response.data() as Map<String, dynamic>)[followType] ?? []);

      if (followIDs.isEmpty) return [];

      List<UserModel> followUsers = [];

      // chunks of 10 (Firestore limit for whereIn)
      for (var i = 0; i < followIDs.length; i += 10) {
        final chunk = followIDs.sublist(i, (i + 10 > followIDs.length) ? followIDs.length : i + 10);

        final response = await _store.collection("users").where("uid", whereIn: chunk).get();

        followUsers.addAll(response.docs.map((doc) => UserModel.fromMap(doc.data())));
      }

      return followUsers;
    } catch (e) {
      return [];
    }
  }

  Future<List<StoryModel>> getRecentStories(String userId) async {
    try {
      final response = await _store.collection("stories").where("userId", isEqualTo: userId).get();

      return response.docs.map((e) => StoryModel.fromMap(e.data())).where((story) =>
          story.createdAt.isAfter(DateTime.now().subtract(Duration(hours: 24)))).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<UserModel>> searchUsers(context, String username) async {
    final response = await _store.collection("users").where("username", isGreaterThanOrEqualTo: username).get();
    notifyListeners();
    return response.docs.map((e)=>UserModel.fromMap(e.data())).toList();
  }

  Future<bool> checkLike({required String mediaType, required String mediaID}) async{
    final response = await _store.collection(mediaType).doc(mediaID).get();
    if ((response.data() as dynamic)["likes"].contains(currentUser!.uid)) return true;
    return false;
  }

  Future like({required String mediaType, required String mediaID, context}) async{
    try{
      final response = await _store.collection(mediaType).doc(mediaID).get();

      if((response.data() as dynamic)["likes"].contains(currentUser!.uid)){
        await _store.collection(mediaType).doc(mediaID).update({"likes":FieldValue.arrayRemove([currentUser!.uid])});
        await _store.collection("users").doc(currentUser!.uid).update({"likes":FieldValue.arrayRemove([mediaID])});
      } else {
        await _store.collection(mediaType).doc(mediaID).update({"likes":FieldValue.arrayUnion([currentUser!.uid])});
        await _store.collection("users").doc(currentUser!.uid).update({"likes":FieldValue.arrayUnion([mediaID])});
      } notifyListeners();
    }
    catch(e){
      showScaffoldMSG(context, "${"something_went_wrong".tr()} $e");
    }
  }

  Future viewReel({required String reelID}) async{
    final response = await _store.collection("reels").doc(reelID).get();
    if(!(response.data() as dynamic)["views"].contains(currentUser!.uid)) {
      await _store.collection("reels").doc(reelID)
          .update({"views": FieldValue.arrayUnion([currentUser!.uid])});
    }
    notifyListeners();
  }

  Future<bool> checkFollow(String followerID) async{
    final response = await _store.collection("users").doc(currentUser!.uid).get();
    if ((response.data() as dynamic)["following"].contains(followerID)) return true;
    return false;
  }

  Future followProfile(userID, context) async{
    try{
      final response = await _store.collection("users").doc(currentUser!.uid).get();

      if((response.data() as dynamic)["following"].contains(userID)){
        await _store.collection("users").doc(userID).update({"followers":FieldValue.arrayRemove([currentUser!.uid])});
        await _store.collection("users").doc(currentUser!.uid).update({"following":FieldValue.arrayRemove([userID])});
      }
      else {
        await _store.collection("users").doc(userID).update({"followers":FieldValue.arrayUnion([currentUser!.uid])});
        await _store.collection("users").doc(currentUser!.uid).update({"following":FieldValue.arrayUnion([userID])});}
      notifyListeners();
    }
    catch(e){
      showScaffoldMSG(context, "${"something_went_wrong".tr()} $e");
    }
  }

  Future<bool> checkSave({required String mediaType, required String mediaID}) async{
   final response = await _store.collection("users").doc(currentUser!.uid).get();
   if ((response.data() as dynamic)["savedPosts"].contains(mediaID)) return true;
   return false;
  }

  Future savePost(context, {required String userID, required String postID}) async{
   try{
     final response = await _store.collection("users").doc(userID).get();

     if((response.data() as dynamic)["savedPosts"].contains(postID)){
       await _store.collection("users").doc(userID).update({"savedPosts":FieldValue.arrayRemove([postID])});
       showScaffoldMSG(context, "removed_from_saved_posts");
     } else {
       await _store.collection("users").doc(userID).update({"savedPosts":FieldValue.arrayUnion([postID])});
       showScaffoldMSG(context, "added_to_saved_posts");
     } notifyListeners();
   }
   catch(e){
     showScaffoldMSG(context, "${"something_went_wrong".tr()} $e");
   }
 }

  Future<List<PostModel>> getUserPosts(String userID) async {
    final response = await _store.collection("posts").where("uid", isEqualTo: userID).get();
    return response.docs.map((e) => PostModel.fromMap(e.data())).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<List<ReelModel>> getUserReels(String userID) async {
    final response = await _store.collection("reels").where("userId", isEqualTo: userID).get();
    return response.docs.map((e) => ReelModel.fromMap(e.data())).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<List<PostModel>> getLikedPosts(String userID) async {
    final response = await _store.collection("posts").where("likes", arrayContains: userID).get();
    return response.docs.map((e) => PostModel.fromMap(e.data())).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<List<PostModel>> getSavedPosts(String userID) async {
    final userDoc = await _store.collection("users").doc(userID).get();
    List<String> savedPostIds = List<String>.from(userDoc.data()!["savedPosts"]);
    if (savedPostIds.isEmpty) return [];

    List<PostModel> posts = [];

    // chunks of 10 (Firestore limit for whereIn)
    for (var i = 0; i < savedPostIds.length; i += 10) {
      final chunk = savedPostIds.sublist(i, i + 10 > savedPostIds.length ? savedPostIds.length : i + 10);
      final response = await _store.collection("posts")
          .where(FieldPath.documentId, whereIn: chunk).get();

      posts.addAll(response.docs.map((e) => PostModel.fromMap(e.data())));
    }

    posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return posts;
  }

  Future<List<PostModel>> getAllPosts() async{
    final response = await _store.collection("posts").get();
    return response.docs.map((e)=>PostModel.fromMap(e.data())).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<List<ReelModel>> getAllReels() async{
    final response = await _store.collection("reels").get();
    return response.docs.map((e)=>ReelModel.fromMap(e.data())).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  String chatId(String userId) => currentUser!.uid.compareTo(userId) < 0 ?
  "${currentUser!.uid}\_$userId" : "$userId\_${currentUser!.uid}";

  // Future changePassword(context, String newPassword) async {
  //   await currentUser!.updatePassword(newPassword);
  //   showScaffoldMSG(context, "password_updated".tr());
  // }
  //
  // Future resetPassword(context, String email) async {
  //   await _auth.sendPasswordResetEmail(email: email);
  //   showScaffoldMSG(context, "password_reset".tr());
  // }
  //
  // Future deleteUser(BuildContext context) async {
  //     User? user = _auth.currentUser!;
  //
  //     await _store.collection("users").doc(user.uid).delete();
  //     final posts = await _store.collection("posts").where("uid", isEqualTo: user.uid).get();
  //     for (var doc in posts.docs) {
  //       await _store.collection("posts").doc(doc.id).delete();
  //     }
  //
  //     final reels = await _store.collection("reels").where("userId", isEqualTo: user.uid).get();
  //     for (var doc in reels.docs) {
  //       await _store.collection("reels").doc(doc.id).delete();
  //     }
  //
  //     final stories = await _store.collection("stories").where("userId", isEqualTo: user.uid).get();
  //     for (var doc in stories.docs) {
  //       await _store.collection("stories").doc(doc.id).delete();
  //     }
  //
  //     final followers = await _store.collection("users").where("followers", arrayContains: user.uid).get();
  //     for (var doc in followers.docs) {
  //       await _store.collection("users").doc(doc.id).update({
  //         "followers": FieldValue.arrayRemove([user.uid])
  //       });
  //     }
  //
  //     final followings = await _store.collection("users").where("following", arrayContains: user.uid).get();
  //     for (var doc in followings.docs) {
  //       await _store.collection("users").doc(doc.id).update({
  //         "following": FieldValue.arrayRemove([user.uid])
  //       });
  //     }
  //
  //     final likedPosts = await _store.collection("posts").where("likes", arrayContains: user.uid).get();
  //     for (var doc in likedPosts.docs) {
  //       await _store.collection("posts").doc(doc.id).update({
  //         "likes": FieldValue.arrayRemove([user.uid])
  //       });
  //     }
  //
  //     final likedReels = await _store.collection("reels").where("likes", arrayContains: user.uid).get();
  //     for (var doc in likedReels.docs) {
  //       await _store.collection("reels").doc(doc.id).update({
  //         "likes": FieldValue.arrayRemove([user.uid])
  //       });
  //     }
  //
  //     final viewedReels = await _store.collection("reels").where("views", arrayContains: user.uid).get();
  //     for (var doc in viewedReels.docs) {
  //       await _store.collection("reels").doc(doc.id).update({
  //         "views": FieldValue.arrayRemove([user.uid])
  //       });
  //     }
  //
  //     await user.delete();
  //     showScaffoldMSG(context, "account_deleted_successfully");
  //     _isLogged = false;
  //   notifyListeners();
  // }
  //
  // Future deleteUser2(BuildContext context) async {
  //   User? user = _auth.currentUser!;
  //   WriteBatch batch = _store.batch();
  //   batch.delete(_store.collection("users").doc(user.uid));
  //
  //   List<Map<String, dynamic>> collections = [
  //     {"collection": "posts", "field": "uid"},
  //     {"collection": "reels", "field": "userId"},
  //     {"collection": "stories", "field": "userId"},
  //   ];
  //
  //   List<Map<String, dynamic>> userFields = [
  //     {"field": "followers", "collection": "users"},
  //     {"field": "following", "collection": "users"},
  //     {"field": "likes", "collection": "posts"},
  //     {"field": "likes", "collection": "reels"},
  //     {"field": "views", "collection": "reels"},
  //   ];
  //
  //   for (var item in collections) {
  //     var snapshot = await _store.collection(item["collection"]!).where(item["field"]!, isEqualTo: user.uid).get();
  //     for (var doc in snapshot.docs) {
  //       batch.delete(doc.reference);
  //     }
  //   }
  //
  //   for (var item in userFields) {
  //     var snapshot = await _store.collection(item["collection"]!).where(item["field"]!, arrayContains: user.uid).get();
  //     for (var doc in snapshot.docs) {
  //       batch.update(doc.reference, {item["field"]!: FieldValue.arrayRemove([user.uid])});
  //     }
  //   }
  //
  //   await batch.commit();
  //   await user.delete();
  //
  //   showScaffoldMSG(context, "account_deleted_successfully");
  //   _isLogged = false;
  //
  // notifyListeners();
  // }
}