import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'guest_book_message.dart';

enum Attending { yes, no, unknown }

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  // —— Authentication —— //
  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;
  bool _emailVerified = false;
  bool get emailVerified => _emailVerified;

  // —— GuestBook —— //
  StreamSubscription<QuerySnapshot>? _guestBookSubscription;
  List<GuestBookMessage> _guestBookMessages = [];
  List<GuestBookMessage> get guestBookMessages => _guestBookMessages;

  Future<DocumentReference> addMessageToGuestBook(String message) {
    if (!_loggedIn) throw Exception('Must be logged in');
    return FirebaseFirestore.instance
        .collection('guestbook')
        .add({
      'text': message,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'name': FirebaseAuth.instance.currentUser!.displayName,
      'userId': FirebaseAuth.instance.currentUser!.uid,
    });
  }

  // —— RSVP 统计 —— //
  int _attendees = 0;
  int get attendees => _attendees;

  Attending _attending = Attending.unknown;
  Attending get attending => _attending;
  set attending(Attending sel) {
    final userDoc = FirebaseFirestore.instance
        .collection('attendees')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    userDoc.set({'attending': sel == Attending.yes});
  }

  StreamSubscription<DocumentSnapshot>? _attendingSubscription;

  // —— 初始化 —— //
  Future<void> init() async {
    // 1. 初始化 Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // 2. 配置 FirebaseUI Auth Provider
    FirebaseUIAuth.configureProviders([EmailAuthProvider()]);

    // 3. 监听所有 “attendees” 集合用于统计
    FirebaseFirestore.instance
        .collection('attendees')
        .where('attending', isEqualTo: true)
        .snapshots()
        .listen((snap) {
      _attendees = snap.docs.length;
      notifyListeners();
    });

    // 4. 监听登录状态、订阅/取消订阅 GuestBook 和 Attending
    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;
        _emailVerified = user.emailVerified;

        _guestBookSubscription = FirebaseFirestore.instance
            .collection('guestbook')
            .orderBy('timestamp', descending: true)
            .snapshots()
            .listen((snap) {
          _guestBookMessages = snap.docs.map((doc) {
            final data = doc.data();
            return GuestBookMessage(
              name: data['name'] as String,
              message: data['text'] as String,
            );
          }).toList();
          notifyListeners();
        });

        _attendingSubscription = FirebaseFirestore.instance
            .collection('attendees')
            .doc(user.uid)
            .snapshots()
            .listen((doc) {
          final data = doc.data();
          if (data != null && data['attending'] == true) {
            _attending = Attending.yes;
          } else if (data != null && data['attending'] == false) {
            _attending = Attending.no;
          } else {
            _attending = Attending.unknown;
          }
          notifyListeners();
        });
      } else {
        _loggedIn = false;
        _emailVerified = false;
        _guestBookMessages = [];
        _guestBookSubscription?.cancel();
        _attendingSubscription?.cancel();
        notifyListeners();
      }
    });
  }
}
