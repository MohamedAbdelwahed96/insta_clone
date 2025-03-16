import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/core/controllers.dart';
import 'package:instagram_clone/data/post_model.dart';
import 'package:instagram_clone/data/user_model.dart';
import 'package:instagram_clone/logic/user_provider.dart';
import 'package:instagram_clone/presentation/screens/search_screen/posts_results.dart';
import 'package:instagram_clone/presentation/screens/search_screen/users_results.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final formControllers = FormControllers();
  List<UserModel>? _users;
  List<PostModel>? _posts;

  @override
  void initState() {
    super.initState();
    Provider.of<UserProvider>(context, listen: false).getAllPosts().then((fetchedPosts) {
      setState(() => _posts = fetchedPosts);
    });
  }

  @override
  void dispose() {
    formControllers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_posts == null) return const Center(child: CircularProgressIndicator());
    final theme = Theme.of(context).colorScheme;

    return Consumer<UserProvider>(builder: (context, provider, _){
      return SafeArea(
        child: Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: TextFormField(
                  controller: formControllers.search,
                  style: TextStyle(color: theme.primary),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: theme.inversePrimary,
                    prefixIcon: Padding(padding: const EdgeInsets.all(16),
                        child: ImageIcon(AssetImage("assets/icons/search.png"))),
                    suffixIcon: formControllers.search.text.isEmpty ? null
                        : IconButton(
                      onPressed: ()=> setState(() => formControllers.search.clear()),
                      icon: Icon(Icons.clear),),
                    hintText: "search".tr(),
                    hintStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: theme.secondary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onFieldSubmitted: (v) async =>
                  _users = await provider.searchUsers(context, formControllers.search.text),
                ),
              ),
                Expanded(
                    child: formControllers.search.text.isEmpty ?
                    GridView.builder(
                      itemCount: _posts!.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 2,
                        crossAxisSpacing: 2),
                      itemBuilder: (context, index) => PostsResults(model: _posts![index]),
                    )
                        : _users!.isEmpty ?
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Text("${"no_results_found".tr()}${formControllers.search.text}"),)
                        : ListView.builder(
                        itemCount: _users!.length,
                        itemBuilder: (context, index){
                          return UsersResults(user: _users![index]);
                        })
                ),
            ],
          ),
        ),
      );
    });
  }
}
