import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/data/post_model.dart';
import 'package:instagram_clone/data/user_model.dart';
import 'package:instagram_clone/presentation/widgets/post_widget.dart';

class PostsScreen extends StatefulWidget {
  final UserModel user;
  final List<PostModel> posts;
  final int initialIndex;
  const PostsScreen({super.key, required this.user, required this.posts, required this.initialIndex});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _postKeys = [];

  @override
  void initState() {
    super.initState();
    _postKeys.addAll(List.generate(widget.posts.length, (index) => GlobalKey()));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToInitialPost();
    });
  }

  void _scrollToInitialPost() {
    double offset = 0;
    for (int i = 0; i < widget.initialIndex; i++) {
      final keyContext = _postKeys[i].currentContext;
      if (keyContext != null) {
        final box = keyContext.findRenderObject() as RenderBox;
        offset += box.size.height;
      }
    }
    _scrollController.jumpTo(offset);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("posts".tr(),
              style: TextStyle(fontWeight: FontWeight.bold)),
        scrolledUnderElevation: 0,
      ),
      body: CustomScrollView(
        controller: _scrollController,
        physics: BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
              child: ListView.builder(
                controller: _scrollController,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.user.posts.length,
                itemBuilder: (context, index) {
                  return Container(
                    key: _postKeys[index],
                    child: PostWidget(post: widget.posts[index]),
                  );
                },
              )
          )
        ],
      ),
    );
  }
}
