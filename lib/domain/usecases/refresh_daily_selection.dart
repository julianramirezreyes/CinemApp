import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/daily_selection.dart';
import '../repositories/movie_repository.dart';

class RefreshDailySelection {
  final MovieRepository repository;

  RefreshDailySelection(this.repository);

  Future<Either<Failure, DailySelection>> call(String profileId) async {
    final now = DateTime.now();
    return await repository.refreshDailySelection(now, profileId);
  }
}
