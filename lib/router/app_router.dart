import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/accommodations_list_screen.dart';
import '../screens/post_request_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/chat_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/accommodations',
      name: 'accommodations',
      builder: (context, state) => const AccommodationsListScreen(),
      routes: [
        GoRoute(
          path: 'post',
          name: 'postRequest',
          builder: (context, state) => const PostRequestScreen(),
        ),
        GoRoute(
          path: 'edit/:id',
          name: 'editRequest',
          builder: (context, state) {
            final accommodation = state.extra as dynamic;
            return PostRequestScreen(editing: accommodation);
          },
        ),
        GoRoute(
          path: 'chat/:title',
          name: 'chatScreen',
          builder: (context, state) {
            final title = state.pathParameters['title'] ?? '';
            return ChatScreen(title: title);
          },
        ),
      ],
    ),
  ],
);