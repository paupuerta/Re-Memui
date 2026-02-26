import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/data_sources/statistics_remote_data_source.dart';
import '../../data/repositories/statistics_repository_impl.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../../domain/use_cases/get_deck_stats.dart';
import '../../domain/use_cases/get_user_stats.dart';

/// Provider for statistics remote data source
final statisticsRemoteDataSourceProvider =
    Provider<StatisticsRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return StatisticsRemoteDataSource(dio: dio);
});

/// Provider for statistics repository
final statisticsRepositoryProvider = Provider<StatisticsRepository>((ref) {
  final remoteDataSource = ref.watch(statisticsRemoteDataSourceProvider);
  return StatisticsRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Provider for GetUserStats use case
final getUserStatsUseCaseProvider = Provider<GetUserStats>((ref) {
  final repository = ref.watch(statisticsRepositoryProvider);
  return GetUserStats(repository);
});

/// Provider for GetDeckStats use case
final getDeckStatsUseCaseProvider = Provider<GetDeckStats>((ref) {
  final repository = ref.watch(statisticsRepositoryProvider);
  return GetDeckStats(repository);
});
