import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../cards/data/data_sources/api_config.dart';
import '../../data/data_sources/statistics_remote_data_source.dart';
import '../../data/repositories/statistics_repository_impl.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../../domain/use_cases/get_deck_stats.dart';
import '../../domain/use_cases/get_user_stats.dart';

/// Provider for HTTP client
final httpClientProvider = Provider<http.Client>((ref) {
  return http.Client();
});

/// Provider for statistics remote data source
final statisticsRemoteDataSourceProvider =
    Provider<StatisticsRemoteDataSource>((ref) {
  final client = ref.watch(httpClientProvider);
  return StatisticsRemoteDataSource(
    client: client,
    baseUrl: ApiConfig.baseUrl,
  );
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
