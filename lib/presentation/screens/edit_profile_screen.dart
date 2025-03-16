import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instagram_clone/core/controllers.dart';
import 'package:instagram_clone/data/user_model.dart';
import 'package:instagram_clone/logic/media_provider.dart';
import 'package:instagram_clone/presentation/widgets/navigation_bot_bar.dart';
import '/logic/user_provider.dart';
import '/presentation/widgets/edit_text_formfield_widget.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  UserModel? user;
  String? img;
  final formControllers = FormControllers();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    UserModel? fetchedUser =
        await userProvider.getUserInfo(userProvider.currentUser!.uid);
    String? profilePicture = fetchedUser != null
        ? await Provider.of<MediaProvider>(context, listen: false).getImage(
            bucketName: "users",
            folderName: fetchedUser.uid,
            fileName: fetchedUser.pfpUrl)
        : null;
    setState(() {
      user = fetchedUser;
      img = profilePicture;
    });
  }

  @override
  void dispose() {
    formControllers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return Center(child: CircularProgressIndicator());

    return Consumer2<UserProvider, MediaProvider>(
        builder: (context, userProvider, mediaProvider, _) {
      final theme = Theme.of(context).colorScheme;
      formControllers.name.text = user!.fullName;
      formControllers.username.text = user!.username;
      formControllers.website.text = user!.website;
      formControllers.bio.text = user!.bio;
      formControllers.email.text = user!.email;
      formControllers.phone.text = user!.pNumber;
      formControllers.gender.text = user!.gender;

      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (popped, _) {
          mediaProvider.mediaFile = null;
          Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) => NavigationBotBar(index: 4)));
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text("edit_profile".tr()),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                mediaProvider.mediaFile = null;
                Navigator.pushReplacement(context, MaterialPageRoute(
                    builder: (context) => NavigationBotBar(index: 4)));
              },
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  final String name = formControllers.name.text,
                      username = formControllers.username.text,
                      web = formControllers.website.text,
                      bio = formControllers.bio.text,
                      email = formControllers.email.text,
                      phone = formControllers.phone.text,
                      gender = formControllers.gender.text;
                  String pfpUrl = user!.pfpUrl;

                  if (mediaProvider.mediaFile != null) {
                    await mediaProvider.uploadMedia(context,
                        bucketName: "users", folder: user!.uid);
                    pfpUrl = mediaProvider.filename ?? pfpUrl;
                  }

                  await userProvider.saveInfo(context,
                      name, username, web, bio, email, phone, gender, pfpUrl)
                      .then((v) {
                    mediaProvider.mediaFile = null;
                    Navigator.pushReplacement(context, MaterialPageRoute(
                            builder: (context) => NavigationBotBar(index: 4)));
                  });
                },
                child: Text("done".tr(), style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: theme.surface,
                      backgroundImage: mediaProvider.mediaFile == null
                          ? NetworkImage(img!)
                          : FileImage(File(mediaProvider.mediaFile!.path!)),
                    ),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () async => await mediaProvider.selectMedia(FileType.image),
                      child: Text("change_profile_photo".tr(),
                          style: TextStyle(color: Colors.blue)),
                    ),
                  ),
                  EditTextFormfieldWidget(
                      name: "name", controller: formControllers.name),
                  EditTextFormfieldWidget(
                    name: "username", controller: formControllers.username,
                    inputFormats: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s'))
                    ],
                  ),
                  EditTextFormfieldWidget(
                    name: "website", controller: formControllers.website,
                    inputFormats: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s'))
                    ],
                  ),
                  EditTextFormfieldWidget(
                      name: "bio", controller: formControllers.bio,
                      maxLines: 2,
                      lineEnabled: false),
                  Container(
                      height: 1,
                      color: theme.primary.withOpacity(0.15)),
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 29),
                    child: InkWell(
                      onTap: () {},
                      child: Text("switch_to_professional_account".tr(),
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 15,
                              fontWeight: FontWeight.w400)),
                    ),
                  ),
                  Text(
                    "private_information".tr(),
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 14),
                  EditTextFormfieldWidget(
                    name: "email", controller: formControllers.email,
                  ),
                  EditTextFormfieldWidget(
                    name: "phone", controller: formControllers.phone,
                    keyboardType: TextInputType.number,
                    inputFormats: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  EditTextFormfieldWidget(
                      name: "gender", controller: formControllers.gender,
                      dropDown: true,
                      lineEnabled: false),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
