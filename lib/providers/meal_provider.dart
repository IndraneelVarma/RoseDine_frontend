import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/meal_repository.dart';

final httpClientProvider = Provider<http.Client>((ref) => http.Client());

final mealRepositoryProvider = Provider<MealRepository>((ref) {
  return MealRepository(httpClient: ref.read(httpClientProvider));
});

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final selectedMealTypeProvider = StateProvider<String>((ref) => '');

final menuItemsProvider = FutureProvider.family<List<dynamic>, DateTime>((ref, selectedDate) {
  return ref.read(mealRepositoryProvider).fetchMenuItems(selectedDate, ref.watch(selectedMealTypeProvider));
});

final recommendationsNotifierProvider = StateNotifierProvider<RecommendationsNotifier, Map<String, dynamic>>((ref) {
  return RecommendationsNotifier(ref.read(mealRepositoryProvider));
});

class RecommendationsNotifier extends StateNotifier<Map<String, dynamic>> {
  final MealRepository mealRepository;

  RecommendationsNotifier(this.mealRepository) : super({});

  Future<void> fetchRecommendations(DateTime selectedDate, String mealType) async {
    final recommendations = await mealRepository.fetchRecommendations(selectedDate, mealType);
    state = recommendations;
  }

  void clearRecommendations() {
    state = {};
  }

  Future<void> fetchNotificationFoods() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId != null) {
      final notificationFoods = await mealRepository.getNotificationFoods(int.parse(userId));
      state = {
        'notificationFoods': notificationFoods,
      };
    } else {
      state = {
        'notificationFoods': [],
      };
    }
  }
}