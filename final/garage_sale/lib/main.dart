import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:garage_sale/browse_posts_activity.dart';
import 'package:garage_sale/splash_screen.dart';
import 'package:garage_sale/login_screen.dart'; // 添加登录页面导入
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 添加 Firebase Auth

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Garage Sale',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
      ),
      home: const SplashPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 统一设置状态栏颜色
    await FlutterStatusbarcolor.setStatusBarColor(Colors.deepPurple);

    // 并行处理：同时等待2秒和用户状态检查
    final results = await Future.wait([
      Future.delayed(const Duration(seconds: 2)),
      _checkLoginStatus(),
    ]);

    if (!mounted) return;

    // 获取登录检查结果（第二个Future的结果）
    final isLoggedIn = results[1] as bool;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder:
            (context) =>
                isLoggedIn ? const BrowsePostsActivity() : LoginScreen(),
      ),
    );
  }

  Future<bool> _checkLoginStatus() async {
    try {
      // 使用idToken刷新机制确保状态最新
      await FirebaseAuth.instance.currentUser?.getIdToken(true);
      return FirebaseAuth.instance.currentUser != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
