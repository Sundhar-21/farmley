import 'package:flutter_riverpod/flutter_riverpod.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

class RecentSearchesNotifier extends StateNotifier<List<String>> {
  RecentSearchesNotifier() : super([]);

  void addSearch(String query) {
    if (query.trim().isEmpty) return;
    state = [
      query,
      ...state.where((q) => q != query),
    ].take(10).toList();
  }

  void removeSearch(String query) {
    state = state.where((q) => q != query).toList();
  }

  void clearAll() {
    state = [];
  }
}

final recentSearchesProvider = StateNotifierProvider<RecentSearchesNotifier, List<String>>((ref) {
  return RecentSearchesNotifier();
});
