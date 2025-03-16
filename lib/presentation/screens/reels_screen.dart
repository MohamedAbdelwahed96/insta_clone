import 'package:flutter/material.dart';
import 'package:instagram_clone/data/reel_model.dart';
import 'package:instagram_clone/data/user_model.dart';
import 'package:instagram_clone/logic/user_provider.dart';
import 'package:instagram_clone/presentation/screens/reels.dart';
import 'package:instagram_clone/presentation/skeleton_loading/reels_loading.dart';
import 'package:provider/provider.dart';

class ReelsScreen extends StatefulWidget {
  final String userID;
  const ReelsScreen({super.key, this.userID=""});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  List<UserModel>? users;
  List<String>? pfpUrls;
  List<ReelModel>? _reels;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<ReelModel>? fetchedReels =
    widget.userID == "" ? await userProvider.getAllReels()
        : await userProvider.getUserReels(widget.userID);
    setState(() => _reels = fetchedReels);
  }

  @override
  Widget build(BuildContext context) {
    if(_reels == null) return SkeletonReel();

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: _reels!.length,
            itemBuilder: (context, index){
              return Reels(reel: _reels![index]);
        })
      ),
    );
  }
}