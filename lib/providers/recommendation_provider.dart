import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/recommendation_service.dart';

final recommendationServiceProvider = Provider((_) => RecommendationService());

final personalizedProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  return ref.watch(recommendationServiceProvider).getPersonalized();
});

final trendingProvider = FutureProvider.autoDispose.family<
    List<Map<String, dynamic>>, String>((ref, timeRange) async {
  return ref.watch(recommendationServiceProvider).getTrending(timeRange: timeRange);
});
