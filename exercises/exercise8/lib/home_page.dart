import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;

import 'app_state.dart';
import 'src/widgets.dart';
import 'src/authentication.dart';
import 'guest_book.dart';
import 'yes_no_selection.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Meetup')),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          Image.asset('assets/codelab.png'),
          const SizedBox(height: 8),
          const IconAndDetail(Icons.calendar_today, 'October 30'),
          const IconAndDetail(Icons.location_city, 'San Francisco'),
          Consumer<ApplicationState>(
            builder: (ctx, appState, _) => AuthFunc(
              loggedIn: appState.loggedIn,
              signOut: () => FirebaseAuth.instance.signOut(),
            ),
          ),
          const Divider(),
          const Header("What we'll be doing"),
          const Paragraph(
            'Join us for a day full of Firebase Workshops and Pizza!',
          ),

          // —— RSVP 统计与选择 —— //
          Consumer<ApplicationState>(
            builder: (ctx, appState, _) {
              final count = appState.attendees;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 人数描述
                  if (count == 0)
                    const Paragraph('No one going')
                  else if (count == 1)
                    const Paragraph('1 person going')
                  else
                    Paragraph('$count people going'),
                  // 是/否选择
                  if (appState.loggedIn)
                    YesNoSelection(
                      state: appState.attending,
                      onSelection: (sel) => appState.attending = sel,
                    ),
                ],
              );
            },
          ),

          // —— 留言讨论区 —— //
          Consumer<ApplicationState>(
            builder: (ctx, appState, _) {
              if (!appState.loggedIn) return const SizedBox();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Header('Discussion'),
                  GuestBook(
                    addMessage: appState.addMessageToGuestBook,
                    messages: appState.guestBookMessages,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
