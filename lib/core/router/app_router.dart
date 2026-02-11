import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/pages/home_page.dart';
import '../../presentation/pages/catalog_page.dart';
import '../../presentation/pages/history_page.dart';
import '../../presentation/pages/details_page.dart';
import '../../presentation/widgets/scaffold_with_nav.dart';
import '../../domain/entities/movie.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomePage(),
          routes: [
            GoRoute(
              path: 'details',
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) {
                final movie = state.extra as Movie;
                return DetailsPage(movie: movie);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/catalog',
          builder: (context, state) => const CatalogPage(),
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) => const HistoryPage(),
        ),
      ],
    ),
  ],
);
