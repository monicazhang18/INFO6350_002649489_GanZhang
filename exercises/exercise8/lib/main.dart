import 'package:firebase_ui_auth/firebase_ui_auth.dart'; // new
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';               // new
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';                 // new

import 'app_state.dart';
import 'home_page.dart';



final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
      routes: [
        GoRoute(
          path: 'sign-in',
          builder: (context, state) {
            return SignInScreen(
              actions: [
                ForgotPasswordAction((context, email) {
                  final uri = Uri(
                    path: '/sign-in/forgot-password',
                    queryParameters: {'email': email},
                  );
                  context.push(uri.toString());
                }),
                AuthStateChangeAction((context, state) {
                  final user = switch (state) {
                    SignedIn state => state.user,
                    UserCreated state => state.credential.user,
                    _ => null
                  };
                  if (user == null) return;
                  if (state is UserCreated) {
                    user.updateDisplayName(user.email!.split('@')[0]);
                  }
                  if (!user.emailVerified) {
                    user.sendEmailVerification();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please verify your email')),
                    );
                  }
                  context.pushReplacement('/');
                }),
              ],
            );
          },
          routes: [
            GoRoute(
              path: 'forgot-password',
              builder: (context, state) {
                final args = state.uri.queryParameters;
                return ForgotPasswordScreen(
                  email: args['email'],
                  headerMaxExtent: 200,
                );
              },
            )
          ],
        ),
        GoRoute(
          path: 'profile',
          builder: (context, state) => ProfileScreen(
            providers: const [],
            actions: [SignedOutAction((context) => context.pushReplacement('/'))],
          ),
        ),
      ],
    ),
  ],
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ChangeNotifierProvider(
    create: (context) => ApplicationState(),
    builder: ((context, child) => const App()),
  ));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Firebase Meetup',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        textTheme: GoogleFonts.robotoTextTheme(),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}
