import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/logic/chat_provider.dart';
import 'package:instagram_clone/presentation/screens/chat_screen/chat_screen.dart';
import 'package:instagram_clone/presentation/screens/profile_screen/profile_screen.dart';
import 'package:instagram_clone/presentation/screens/splash_screen.dart';
import 'package:instagram_clone/services/notification.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme.dart';
import 'services/firebase_options.dart';
import 'logic/media_provider.dart';
import 'logic/user_provider.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  /// Dependencies
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService().initNotifications();

  await Supabase.initialize(
    url: "https://kwrtcgnmxmdfffqffkin.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt3cnRjZ25teG1kZmZmcWZma2luIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzc5MDAxODUsImV4cCI6MjA1MzQ3NjE4NX0.lwcWfz2YaVs7BxClu0mQM9cA-CZgnCAXqHL0-TZCKZc",
  );

  bool isDarkMode = prefs.getBool("isDarkMode") ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider(isDarkMode ? darkMode : lightMode)..loadTheme()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => MediaProvider()),
        ChangeNotifierProvider(create: (context) => ChatProvider())
      ],
      child: EasyLocalization(
          supportedLocales: [Locale('en'), Locale('ar')],
          path: 'assets/translations',
          fallbackLocale: Locale('en'),
          child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Instagram',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: Provider.of<ThemeProvider>(context).themeData,
      builder: (context, child,) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: child),
      home: SplashScreen(),
      routes: {
        '/chat': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return ChatScreen(chatId: args['chatId'], senderId: args['senderId'], receiverId: args['receiverId']);
        },
        '/profile': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return ProfileScreen(profileId: args['profileId']);
        }
      },
    );
  }
}
