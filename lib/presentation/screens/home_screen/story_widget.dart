import 'package:flutter/material.dart';
import 'package:instagram_clone/data/story_model.dart';
import 'package:instagram_clone/data/user_model.dart';
import 'package:instagram_clone/logic/user_provider.dart';
import 'package:instagram_clone/presentation/screens/new_story.dart';
import 'package:instagram_clone/presentation/screens/story_screen/story_screen.dart';
import 'package:provider/provider.dart';

class StoryWidget extends StatefulWidget {
  final List<UserModel> users;
  final List<String> pfpUrls;
  const StoryWidget({super.key, required this.users, required this.pfpUrls});

  @override
  State<StoryWidget> createState() => _StoryWidgetState();
}

class _StoryWidgetState extends State<StoryWidget> {
  List<List<StoryModel>>? fetchedStories;

  @override
  void initState() {
    super.initState();
    fetchStories();
  }

  void fetchStories() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<List<StoryModel>> storiesList = await Future.wait(
      widget.users.map((user) => userProvider.getRecentStories(user.uid)),
    );
    setState(() => fetchedStories = storiesList);
  }

  @override
  Widget build(BuildContext context) {
    if (fetchedStories == null) return SizedBox.shrink();
    final screen = MediaQuery.of(context).size;
    final theme = Theme.of(context).colorScheme;
    return SizedBox(
      height: screen.width * 0.22,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.users.length,
        itemBuilder: (context, index) {
          if (index != 0 && fetchedStories![index].isEmpty) return SizedBox();
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: screen.width * 0.01),
            child: InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) =>
              fetchedStories![index].isNotEmpty ? StoryScreen(user: widget.users[index])
                  : NewStory(),),),
              child: Stack(
                children: [
                  Container(
                    decoration: fetchedStories![index].isEmpty ? BoxDecoration() :
                    BoxDecoration(shape: BoxShape.circle,
                      gradient: LinearGradient(
                          colors: [Colors.pink, Colors.orange, Colors.yellow],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight)),
                    padding: EdgeInsets.all(4),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.surface),
                      padding: EdgeInsets.all(3),
                      child: CircleAvatar(
                        radius: screen.width * 0.08,
                        backgroundImage: NetworkImage(widget.pfpUrls[index]),
                      ),
                    ),
                  ),
                  if (index == 0)
                    Positioned(
                      bottom: screen.width * 0.02,
                      right: screen.width * 0.001,
                      child: InkWell(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => NewStory())),
                        child: CircleAvatar(
                          radius: screen.width * 0.036,
                          backgroundColor: theme.surface,
                          child: CircleAvatar(
                            radius: screen.width * 0.03,
                            backgroundColor: Colors.blue,
                            child: Icon(Icons.add,
                              color: Colors.white,
                              size: screen.width * 0.05,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
