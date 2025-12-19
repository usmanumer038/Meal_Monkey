import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // TheMealDB - Free Food API
  static const String _mealDbBaseUrl = 'https://www.themealdb.com/api/json/v1/1';

  // Search meals by name
  static Future<List<Map<String, dynamic>>> searchMeals(String query) async {
    if (query.isEmpty) return [];
    final response = await http
        .get(Uri.parse('$_mealDbBaseUrl/search.php?s=${Uri.encodeComponent(query)}'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final meals = data['meals'] as List?;
      if (meals == null) return [];
      return meals.map((m) => m as Map<String, dynamic>).toList();
    }
    return [];
  }

  // Get meal categories
  static Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await http.get(Uri.parse('$_mealDbBaseUrl/categories.php'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final categories = data['categories'] as List?;
      if (categories == null) return [];
      return categories.map((c) => c as Map<String, dynamic>).toList();
    }
    return [];
  }

  // Get meals by category
  static Future<List<Map<String, dynamic>>> getMealsByCategory(String category) async {
    if (category.isEmpty) return [];
    final response =
    await http.get(Uri.parse('$_mealDbBaseUrl/filter.php?c=${Uri.encodeComponent(category)}'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final meals = data['meals'] as List?;
      if (meals == null) return [];
      return meals.map((m) => m as Map<String, dynamic>).toList();
    }
    return [];
  }

  // Get meal details by ID
  static Future<Map<String, dynamic>?> getMealById(String id) async {
    final response = await http.get(Uri.parse('$_mealDbBaseUrl/lookup.php?i=${Uri.encodeComponent(id)}'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final meals = data['meals'] as List?;
      if (meals != null && meals.isNotEmpty) {
        return meals[0] as Map<String, dynamic>;
      }
    }
    return null;
  }

  // Get random meal
  static Future<Map<String, dynamic>?> getRandomMeal() async {
    final response = await http.get(Uri.parse('$_mealDbBaseUrl/random.php'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final meals = data['meals'] as List?;
      if (meals != null && meals.isNotEmpty) {
        return meals[0] as Map<String, dynamic>;
      }
    }
    return null;
  }

  // Get popular meals (for demo use random)
  static Future<List<Map<String, dynamic>>> getPopularMeals() async {
    List<Map<String, dynamic>> meals = [];
    for (int i = 0; i < 5; i++) {
      final meal = await getRandomMeal();
      if (meal != null) meals.add(meal);
    }
    return meals;
  }
}