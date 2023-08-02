import 'package:chit_chat/firebase_options.dart';
import 'package:chit_chat/screen/auth.dart';
import 'package:chit_chat/screen/chat.dart';
import 'package:chit_chat/screen/splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChitChat',
      theme: ThemeData().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(178, 12, 11, 11),
        ),
      ),
      home: StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return const SplashScreen();
          }
          if(snapshot.hasData){
            return const ChatScreen();
          }

          return const AuthScreen();
        },
      ),
    );
  }
}