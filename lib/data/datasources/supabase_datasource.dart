import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/exceptions.dart';
import '../models/daily_selection_model.dart';
import '../models/interaction_model.dart';

abstract class SupabaseLocalDataSource {
  Future<Map<String, dynamic>?> getDailySelection(
    String profileId,
    DateTime date,
  );
  Future<void> saveDailySelection(DailySelectionModel selection);
  Future<List<InteractionModel>> getInteractions(String profileId);
  Future<void> saveInteraction(InteractionModel interaction);
  Future<void> deleteInteraction(String profileId, int movieId);
}

class SupabaseLocalDataSourceImpl implements SupabaseLocalDataSource {
  final SupabaseClient supabase;

  SupabaseLocalDataSourceImpl({required this.supabase});

  @override
  Future<Map<String, dynamic>?> getDailySelection(
    String profileId,
    DateTime date,
  ) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final response = await supabase
          .from('CinemApp_daily_selections')
          .select()
          .eq('profile_id', profileId)
          .eq('date', dateStr)
          .maybeSingle();

      return response;
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<void> saveDailySelection(DailySelectionModel selection) async {
    try {
      await supabase
          .from('CinemApp_daily_selections')
          .insert(selection.toJson());
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<List<InteractionModel>> getInteractions(String profileId) async {
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
