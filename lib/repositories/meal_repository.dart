import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../url_config.dart';

class MealRepository {
  final http.Client httpClient;

  MealRepository({required this.httpClient});

  final int ipSwitcher = 0;


  Future<List<dynamic>> fetchMenuItems(DateTime selectedDate, String mealType) async {
    final dateString = selectedDate.toIso8601String().split('T')[0];
    final url = Uri.parse(Config.getUrl('menuItems', {'date': dateString, 'type': mealType}));
    final response = await httpClient.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load menu items');
    }
  }

  Future<int> getUserRating(int userId, int menuItemId) async {
    final url = Uri.parse(Config.getUrl('userRating', {'menuItemId': menuItemId.toString(), 'userId': userId.toString()}));
    final response = await httpClient.get(url);
    if (response.statusCode == 200) {
      final rating = json.decode(response.body);
      return rating != null ? rating as int : 0;
    } else {
      throw Exception('Failed to get user rating');
    }
  }

  Future<void> sendReview(int userId, int menuItemId, int rating) async {
    final url = Uri.parse(Config.getUrl('sendReview', {'menuItemId': menuItemId.toString(), 'userId': userId.toString(), 'stars': rating.toString()}));
    final response = await httpClient.post(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to send review');
    }
  }

  Future<Map<String, dynamic>> fetchRecommendations(DateTime selectedDate, String mealType) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    if (userId != null) {
      final url = Uri.parse(Config.getUrl('recommendations', {'userId': userId, 'mealType': mealType, 'date': formattedDate}));
      final response = await httpClient.get(url);
      if (response.statusCode == 200) {
        List<dynamic> rawData = json.decode(response.body);
        if (rawData.isNotEmpty) {
          List<Map<String, dynamic>> cleanedData = rawData.map<Map<String, dynamic>>((item) {
            return {
              "item": item['item'],
            };
          }).toList();

          Map<String, dynamic> totals = {
            'totalProtein': rawData[0]['totalProtein'] ?? 0,
            'totalCarbs': rawData[0]['totalCarbs'] ?? 0,
            'totalFats': rawData[0]['totalFats'] ?? 0,
            'totalCalories': rawData[0]['totalCalories'] ?? 0,
          };

          return {
            'items': cleanedData,
            'totals': totals
          };
        }
      }
    }
    print('No data fetched or error occurred');
    return {};
  }

  Future<List<dynamic>> getNotificationFoods(int userId) async {
    final url = Uri.parse(Config.getUrl('notifications', {'userId': userId.toString()}));
    final response = await httpClient.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load notification foods');
    }
  }
}