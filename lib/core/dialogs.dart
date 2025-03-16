import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/presentation/screens/new_post.dart';
import 'package:instagram_clone/presentation/screens/new_reel.dart';
import 'package:instagram_clone/presentation/screens/new_story.dart';

Future<bool?> showConfirmationDialog(BuildContext context, String title, String message) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("no".tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("yes".tr()),
          ),
        ],
      );
    },
  );
}

void showScaffoldMSG(BuildContext context, String msg) {
  final theme = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg.tr(),
        style: TextStyle(color: theme.primary)),
      backgroundColor: theme.surface,
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: "dismiss".tr(),
        textColor: theme.primary,
        onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
      ),
    ),
  );
}

void showLanguages(BuildContext context) {
  showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  ListTile(
                    onTap: () {
                      context.setLocale(Locale("en"));
                      Navigator.pop(context);
                    },
                    leading: Text("EN"),
                    title: Text("english".tr()),
                  ),
                  ListTile(
                    onTap: () {
                      context.setLocale(Locale("ar"));
                      Navigator.pop(context);
                    },
                    leading: Text("AR"),
                    title: Text("arabic".tr()),
                  ),
                ],
              ),
            ),
          ),
        );
      });
}

void showAddNewList(BuildContext context) {
  showModalBottomSheet(context: context,
    builder: (context) {
      final screen = MediaQuery.of(context).size;
      return SizedBox(
        height: screen.height * 0.33,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Center(child: Text("create".tr(), style: TextStyle(fontSize: 24))),
            ),
            Container(height: 1, width: screen.width,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.05),),
            listTile(context, "reels", screen.width * 0.75, "new reel".tr(), NewReel()),
            listTile(context, Icons.grid_on, screen.width * 0.75, "new post".tr(), NewPostScreen()),
            listTile(context, "story", screen.width * 0.75, "new story".tr(), NewStory()),
          ],
        ),
      );
    },
  );
}

Widget listTile(BuildContext context, dynamic icon, double width, String title, Widget widget) {
  return Column(
    children: [
      ListTile(
        leading: icon is IconData ? Icon(icon) : ImageIcon(AssetImage("assets/icons/$icon.png")),
        title: Text(title, style: TextStyle(fontSize: 18)),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) => widget));
        }),
      Container(height: 1, width: width,
        color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
      )
    ],
  );
}