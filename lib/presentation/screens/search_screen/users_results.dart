import 'package:flutter/material.dart';
import 'package:instagram_clone/data/user_model.dart';
import 'package:instagram_clone/logic/media_provider.dart';
import 'package:instagram_clone/presentation/screens/profile_screen/profile_screen.dart';
import 'package:instagram_clone/presentation/skeleton_loading/search_users_loading.dart';
import 'package:provider/provider.dart';

class UsersResults extends StatefulWidget {
  final UserModel user;
  const UsersResults({super.key, required this.user});

  @override
  State<UsersResults> createState() => _UsersResultsState();
}

class _UsersResultsState extends State<UsersResults> {
String? userImg;

@override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    String? firstImg = await Provider.of<MediaProvider>(context, listen: false)
        .getImage(bucketName: "users", folderName: widget.user.uid, fileName: widget.user.pfpUrl);
    setState(() => userImg = firstImg);
  }

@override
void didUpdateWidget(covariant UsersResults oldWidget) {
  super.didUpdateWidget(oldWidget);
  if (oldWidget.user.uid != widget.user.uid) fetchData();
}

  @override
  Widget build(BuildContext context) {
    if (userImg == null) return SkeletonSearchUsers();

    return InkWell(
      onTap: ()=> Navigator.push(context,MaterialPageRoute(
            builder: (context) => ProfileScreen(profileId: widget.user.uid),),),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundImage: NetworkImage(userImg!),
        ),
        title: Text(widget.user.username),
      ),
    );
  }
}
