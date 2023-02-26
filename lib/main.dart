import 'package:clone_tiktok/constant.dart';
import 'package:clone_tiktok/controllers/auth_controller.dart';
import 'package:clone_tiktok/views/screens/auth/login_screen.dart';
import 'package:clone_tiktok/views/screens/auth/signup_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp().then((value) {
    Get.put(
        AuthController()); // 메모리에 컨트롤러를 올림. 시작하자마자 바로 올려서 처음에 바로 접근하고 uid를 앱 어디서든 접근할 수 있도록 만듬.
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TikTok Clone',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: backgroundColor,
      ),
      home: SignupScreen(),
    );
  }
}
