import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/daily_selection.dart';
import 'providers.dart';

// Using AsyncNotifier for better AsyncValue handling
class DailySelectionNotifier extends AsyncNotifier<DailySelection?> {
  // Temporary profile ID since we don't have auth yet.
  final String _profileId = 'default_user_v1';

  @override
  FutureOr<DailySelection?> build() async {
    return _fetchDailySelection();
  }

  Future<DailySelection?> _fetchDailySelection() async {
    final result = await ref
        .read(getDailySelectionUseCaseProvider)
        .call(_profileId);

    return result.fold((failure) {
      // We can throw the failure message to let AsyncValue handle the error state
      throw failure.message;
    }, (selection) => selection);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchDailySelection());
  }
}

final dailySelectionProvider =
    AsyncNotifierProvider<DailySelectionNotifier, DailySelection?>(() {
      return DailySelectionNotifier();
    });
