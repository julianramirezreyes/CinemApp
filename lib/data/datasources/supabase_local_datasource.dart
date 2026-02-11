import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/exceptions.dart';
import '../models/daily_selection_model.dart';
import '../models/interaction_model.dart';

class DailySelectionRow {
  final String? id;
  final String profileId;
  final DateTime date;
  final List<int> movieIds;
  final int remainingRefreshes;
  final List<int> shownMovieIds;

  DailySelectionRow({
    this.id,
    required this.profileId,
    required this.date,
    required this.movieIds,
    this.remainingRefreshes = 3,
    this.shownMovieIds = const [],
  });

  factory DailySelectionRow.fromJson(Map<String, dynamic> json) {
    return DailySelectionRow(
      id: json['id'],
      profileId: json['profile_id'],
      date: DateTime.parse(json['date']),
      movieIds: List<int>.from(json['movie_ids'] ?? []),
      remainingRefreshes: json['remaining_refreshes'] ?? 3,
      shownMovieIds: json['shown_movie_ids'] != null
          ? List<int>.from(json['shown_movie_ids'])
          : [],
    );
  }
}

abstract class SupabaseLocalDataSource {
  Future<DailySelectionRow?> getDailySelection(DateTime date, String profileId);
  Future<void> saveDailySelection(DailySelectionModel selection);
  Future<List<InteractionModel>> getUserInteractions(String profileId);
  Future<void> saveInteraction(InteractionModel interaction);
  Future<void> deleteInteraction(String profileId, int movieId);
}

class SupabaseLocalDataSourceImpl implements SupabaseLocalDataSource {
  final SupabaseClient supabase;

  SupabaseLocalDataSourceImpl({required this.supabase});

  @override
  Future<DailySelectionRow?> getDailySelection(
    DateTime date,
    String profileId,
  ) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final response = await supabase
          .from('CinemApp_daily_selections')
          .select()
          .eq('profile_id', profileId)
          .eq('date', dateStr)
          .maybeSingle();

      if (response != null) {
        return DailySelectionRow.fromJson(response);
      }
      return null;
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<void> saveDailySelection(DailySelectionModel selection) async {
    try {
      await supabase
          .from('CinemApp_daily_selections')
          .upsert(selection.toJson()); // Use upsert to handle overwrite
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<List<InteractionModel>> getUserInteractions(String profileId) async {
    try {
      final response = await supabase
          .from('CinemApp_user_interactions')
          .select()
          .eq('profile_id', profileId);

      return (response as List)
          .map((e) => InteractionModel.fromJson(e))
          .toList();
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<void> saveInteraction(InteractionModel interaction) async {
    try {
      await supabase
          .from('CinemApp_user_interactions')
          .upsert(interaction.toJson());
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<void> deleteInteraction(String profileId, int movieId) async {
    try {
      await supabase
          .from('CinemApp_user_interactions')
          .delete()
          .eq('profile_id', profileId)
          .eq('movie_id', movieId);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }
}
