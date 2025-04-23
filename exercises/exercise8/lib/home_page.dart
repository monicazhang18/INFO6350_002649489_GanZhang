import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'guest_book.dart';
import 'src/authentication.dart';
import 'src/widgets.dart';
import 'yes_no_selection.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<ApplicationState>();

    Widget authSection;
    if (appState.loggedIn) {
      authSection = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Header('RSVP'),
          YesNoSelection(
            state: appState.attending,
            onSelection: (attending) => appState.attending = attending,
          ),
          const SizedBox(height: 8),
          switch (appState.attendees) {
            1 => const Paragraph('1 person going'),
            >= 2 => Paragraph('${appState.attendees} people going'),
            _ => const Paragraph('No one going'),
          },
          const Header('Discussion'),
          GuestBook(
            addMessage: (message) => appState.addMessageToGuestBook(message),
            messages: appState.guestBookMessages,
          ),
        ],
      );
    } else {
      authSection = const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Header('RSVP'),
          Paragraph('Please sign in to RSVP'),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Meetup'),
        actions: const [AuthenticationButton()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Image.asset('assets/codelab.png'),
          const SizedBox(height: 8),
          const IconAndDetail(Icons.calendar_today, 'October 30'),
          const IconAndDetail(Icons.location_city, 'San Francisco'),
          const Divider(),
          authSection,
        ],
      ),
    );
  }
}
