import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) =>
    const MaterialApp(home: MyHomePage(title: 'Exercise 8'));
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String _status = '还没写入';
  final _db = FirebaseFirestore.instance;

  void _onPressed() async {
    setState(() {
      _counter++;
      _status = '写入中…';
    });
    try {
      await _db.collection('test').add({
        'count': _counter,
        'ts': FieldValue.serverTimestamp(),
      });
      setState(() {
        _status = '已写入 (count=$_counter)';
      });
    } catch (e) {
      setState(() {
        _status = '写入失败：$e';
      });
    }
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('已点击: $_counter 次'),
            const SizedBox(height: 8),
            Text('Firestore 状态: $_status'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onPressed,
        child: const Icon(Icons.send),
      ),
    );
  }
}
