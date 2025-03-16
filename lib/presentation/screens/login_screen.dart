import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/core/controllers.dart';
import '/logic/user_provider.dart';
import 'sign_up_screen.dart';
import '/presentation/widgets/button_widget.dart';
import '/presentation/widgets/navigation_bot_bar.dart';
import '/presentation/widgets/text_formfield_widget.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formControllers = FormControllers();

  @override
  void dispose() {
    formControllers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/Logo.png",
                width: MediaQuery.of(context).size.width*0.56,
                color: theme.primary),
              TextFormfieldWidget(hintText: "email".tr(), controller: formControllers.email),
              SizedBox(height: 21),
              TextFormfieldWidget(hintText: "password".tr(), controller: formControllers.password, obsecure: true),
              SizedBox(height: 21),
              InkWell(
                onTap: () async{
                  final email = formControllers.email.text.trimRight();
                  final pass = formControllers.password.text;
                  final user = Provider.of<UserProvider>(context, listen: false);
                  await user.signIn(context, email, pass);
                  user.isLogged?Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) => NavigationBotBar())):null;
                },
                child: ButtonWidget(text: "login".tr()),
              ),
              SizedBox(height: 21),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "do_not_have_an_email".tr(),
                      style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13, color: theme.secondary),
                    ),
                    TextSpan(
                      text: "register".tr(),
                      style: TextStyle(fontWeight: FontWeight.bold, color: theme.primary),
                      recognizer: TapGestureRecognizer()..onTap = () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignUpScreen(),),),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
