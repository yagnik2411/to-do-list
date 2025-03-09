import 'package:flutter/material.dart';
import 'package:job_task/home/model/user_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:job_task/home/ui/sign_in/register.dart';
import 'package:job_task/home/ui/sign_in/sign_in.dart';
import 'firebase_options.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
  
}
// FlutterNativeSplash.remove();
UserModel? globalUser = UserModel(
  firstName: '',
  lastName: '',
  email: '',
  dateOfBirth: '',
  gender: '',
  country: '',
  isSignIn: false,
  login: '',
  profilePictureLink: '',
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          background: Colors.white,
          primary: Colors.deepPurple,
          secondary: Colors.deepPurpleAccent,
          error: Colors.red,
          surface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.black,
          onError: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: SignInScreen(),
    );
  }
}
