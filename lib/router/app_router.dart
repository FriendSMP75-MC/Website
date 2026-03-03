import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:server_site/pages/home.dart';
import 'package:server_site/pages/about.dart';
import 'package:server_site/pages/announcement.dart';
import 'package:server_site/pages/dashboard.dart';
import 'package:server_site/pages/gallery.dart';
import 'package:server_site/pages/status.dart';
import 'package:server_site/pages/support_us.dart';
import 'package:server_site/pages/votes.dart';
import 'package:server_site/pages/dashboards/subpage/staff/staff_announcement.dart';
import 'package:server_site/pages/dashboards/subpage/staff/staff_gallary.dart';
import 'package:server_site/sub_page/view_announcements.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const Home(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/about',
        name: 'about',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const About(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/announcements',
        name: 'announcements',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ListAnnouncements(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/announcement/:title',
        name: 'view-announcement',
        pageBuilder: (context, state) {
          final title = Uri.decodeComponent(state.pathParameters['title'] ?? '');
          final body = (state.extra as Map<String, String>?)?['body'] ?? '';
          return CustomTransitionPage(
            key: state.pageKey,
            child: ViewAnnouncement(
              title: title,
              body: body,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const Dashboard(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/gallery',
        name: 'gallery',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const Gallery(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/status',
        name: 'status',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const Status(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/support',
        name: 'support',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SupportUsPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/votes',
        name: 'votes',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const VotePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/staff/announcements',
        name: 'staff-announcements',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const Staffannouncements(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/staff/gallery',
        name: 'staff-gallery',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const StaffGallary(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),
    ],
  );
}
