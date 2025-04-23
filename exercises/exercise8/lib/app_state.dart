import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'firebase_options.dart';
import 'guest_book_message.dart';

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  StreamSubscription<QuerySnapshot>? _guestBookSubscription;

  List<GuestBookMessage> _guestBookMessages = [];
  List<GuestBookMessage> get guestBookMessages => _guestBookMessages;

  bool? _attending;
  bool? get attending => _attending;

  int _attendees = 0;
  int get attendees => _attendees;

  set attending(bool? value) {
    final userDoc = FirebaseFirestore.instance
        .collection('attendees')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    if (value == true) {
      userDoc.set({'attending': true});
    } else {
      userDoc.set({'attending': false});
    }

    _attending = value;
    notifyListeners();
  }

  Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
    ]);

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;

        _guestBookSubscription = FirebaseFirestore.instance
            .collection('guestbook')
            .orderBy('timestamp', descending: true)
            .snapshots()
            .listen((snapshot) {
          _guestBookMessages = snapshot.docs.map((doc) {
            final data = doc.data();
            return GuestBookMessage(
              name: data['name'] ?? 'Anonymous',
              message: data['text'] ?? '',
            );
          }).toList();
          notifyListeners();
        });

        FirebaseFirestore.instance
            .collection('attendees')
            .doc(user.uid)
            .snapshots()
            .listen((doc) {
          if (doc.exists) {
            _attending = doc.data()?['attending'] as bool?;
            notifyListeners();
          }
        });

        FirebaseFirestore.instance
            .collection('attendees')
            .where('attending', isEqualTo: true)
            .snapshots()
            .listen((snapshot) {
          _attendees = snapshot.docs.length;
          notifyListeners();
        });
      } else {
        _loggedIn = false;
        _guestBookMessages = [];
        _guestBookSubscription?.cancel();
        notifyListeners();
      }
    });
  }

  Future<DocumentReference> addMessageToGuestBook(String message) {
    if (!_loggedIn) {
      throw Exception('Must be logged in to add a message');
    }

    return FirebaseFirestore.instance.collection('guestbook').add({
      'text': message,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'name': FirebaseAuth.instance.currentUser!.displayName,
      'userId': FirebaseAuth.instance.currentUser!.uid,
    });
  }
}
