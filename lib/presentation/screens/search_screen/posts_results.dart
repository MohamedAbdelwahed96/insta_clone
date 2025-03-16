import 'package:flutter/material.dart';
import 'package:instagram_clone/data/post_model.dart';
import 'package:instagram_clone/logic/media_provider.dart';
import 'package:instagram_clone/presentation/skeleton_loading/search_posts_loading.dart';
import 'package:instagram_clone/presentation/widgets/video_player_widget.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';

class PostsResults extends StatefulWidget {
  final PostModel? model;
  const PostsResults({super.key, required this.model});

  @override
  State<PostsResults> createState() => _PostsResultsState();
}

class _PostsResultsState extends State<PostsResults> {
  String? userMedia;

  @override
  void initState() {
    super.initState();
    Provider.of<MediaProvider>(context, listen: false).getImage(
        bucketName: "posts", folderName: widget.model!.postId, fileName: widget.model!.mediaUrls[0])
    .then((media)=> setState(() => userMedia = media));
  }

  @override
  Widget build(BuildContext context) {
    if (userMedia == null) return SkeletonSearchPosts();

    String extension = userMedia!.substring(userMedia!.lastIndexOf("."));
    bool isVideo = lookupMimeType("file$extension")!.startsWith("video/");

    return isVideo
        ? VideoPlayerWidget(videoUrl: userMedia!)
        : Image.network(userMedia!, fit: BoxFit.cover);
  }
}