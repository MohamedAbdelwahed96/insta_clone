import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/core/controllers.dart';
import '/data/user_model.dart';
import '/logic/media_provider.dart';
import '/logic/user_provider.dart';
import '/presentation/screens/login_screen.dart';
import '/presentation/widgets/button_widget.dart';
import '/presentation/widgets/navigation_bot_bar.dart';
import '/presentation/widgets/text_formfield_widget.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  FormControllers formControllers = FormControllers();
  UserModel? userModel;

  @override
  void dispose() {
    formControllers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    final screen = MediaQuery.of(context).size;
    return Consumer2<UserProvider, MediaProvider>(
        builder: (context, userProvider, mediaProvider, _){
          bool isEnabled = (formControllers.email.text.isNotEmpty
              && formControllers.password.text.isNotEmpty
              && formControllers.username.text.isNotEmpty
              && formControllers.name.text.isNotEmpty
              && mediaProvider.mediaFile!=null);

      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: SingleChildScrollView(
              child: Column(
                spacing: screen.height*0.025,
                children: [
                  Image.asset("assets/images/Logo.png",
                    width: screen.width * 0.56,
                    color: theme.primary),
                  TextFormfieldWidget(hintText: "email".tr(), controller: formControllers.email,),
                  TextFormfieldWidget(hintText: "password".tr(), controller: formControllers.password, obsecure: true),
                  TextFormfieldWidget(hintText: "age".tr(), controller: formControllers.age),
                  TextFormfieldWidget(hintText: "username".tr(), controller: formControllers.username),
                  TextFormfieldWidget(hintText: "full_name".tr(), controller: formControllers.name),
                  InkWell(
                    onTap: ()=> mediaProvider.selectMedia(FileType.image),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 21),
                      child: CircleAvatar(radius: 60,
                          backgroundColor: theme.inversePrimary,
                          foregroundImage: mediaProvider.mediaFile==null?null:FileImage(File(mediaProvider.mediaFile!.path!)),
                          child: Image.asset("assets/icons/pfp.png", color: theme.primary)),
                    ),
                  ),
                  InkWell(
                    onTap: !isEnabled ? null : () async {
                      final email = formControllers.email.text.trimRight();
                      final pass = formControllers.password.text;
                      final userName = formControllers.username.text;
                      final fullName= formControllers.name.text;

                      await userProvider.signUp(context,
                          UserModel(username: userName, fullName: fullName, email: email, time: DateTime.now()),
                          pass);

                      if (userProvider.isLogged) {
                        Navigator.pushReplacement(context, CupertinoPageRoute(
                            builder: (context) => NavigationBotBar()));
                      }
                    },
                    child: ButtonWidget(text: "register".tr(), isEnabled: isEnabled),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "already_have_an_email".tr(),
                          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13, color: theme.secondary),
                        ),
                        TextSpan(
                          text: "login".tr(),
                          style: TextStyle(fontWeight: FontWeight.bold, color: theme.primary),
                          recognizer: TapGestureRecognizer()..onTap = () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen(),),),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
