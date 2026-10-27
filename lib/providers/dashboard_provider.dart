import 'package:flutter_riverpod/flutter_riverpod.dart';

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void updateQuery(String value) {
    state = value.trim();
  }
}

/// A one-shot route intent consumed by DashboardScreen through ref.listen().
/// Navigation stays outside widget rendering and is triggered by provider state.
final dashboardNavigationProvider =
    NotifierProvider<DashboardNavigationNotifier, String?>(
  DashboardNavigationNotifier.new,
);

class DashboardNavigationNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void navigateTo(String route) {
    state = route;
  }

  void clearRoute() {
    state = null;
  }
}
