import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Recipe {
  final int id;
  final String title;
  final String image;
  final int readyInMinutes;
  final String sourceUrl;
  final List<String> ingredients;
  final int servings;
  final String summary;
  final List<String> instructions;

  Recipe({
    required this.id,
    required this.title,
    required this.image,
    required this.readyInMinutes,
    required this.sourceUrl,
    required this.ingredients,
    required this.servings,
    required this.summary,
    required this.instructions,
  });
}

class RecipeProvider with ChangeNotifier {
  List<Recipe> _recipes = [];
  bool _isLoading = false;
  String _error = '';
  List<String> _savedRecipes = [];

  List<Recipe> get recipes => _recipes;
  bool get isLoading => _isLoading;
  String get error => _error;
  List<String> get savedRecipes => _savedRecipes;

  Future<void> fetchRecipes(List<String> ingredients) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final apiKey = dotenv.env['SPOONACULAR_KEY'];
      final ingredientQuery = ingredients.join(',').replaceAll(' ', '+');

      final url = Uri.parse(
          'https://api.spoonacular.com/recipes/findByIngredients?ingredients=$ingredientQuery&apiKey=$apiKey&number=5&ranking=1'
      );

      final response = await http.get(url);
      final responseData = json.decode(response.body) as List;

      if (response.statusCode != 200) {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }

      _recipes = await Future.wait(responseData.map((recipeData) async {
        final detailsUrl = Uri.parse(
            'https://api.spoonacular.com/recipes/${recipeData['id']}/information?apiKey=$apiKey&includeNutrition=false'
        );

        final instructionsUrl = Uri.parse(
            'https://api.spoonacular.com/recipes/${recipeData['id']}/analyzedInstructions?apiKey=$apiKey&stepBreakdown=true'
        );

        final detailsResponse = await http.get(detailsUrl);
        final instructionsResponse = await http.get(instructionsUrl);

        final details = json.decode(detailsResponse.body);
        final instructionsData = json.decode(instructionsResponse.body) as List;

        return Recipe(
          id: recipeData['id'],
          title: recipeData['title'],
          image: recipeData['image'],
          readyInMinutes: details['readyInMinutes'],
          sourceUrl: details['sourceUrl'],
          servings: details['servings'],
          summary: details['summary'],
          ingredients: List<String>.from(
              details['extendedIngredients'].map((i) => i['original'])
          ),
          instructions: instructionsData.isNotEmpty
              ? List<String>.from(
              instructionsData[0]['steps'].map((step) => step['step'])
          )
              : ['No instructions available'],
        );
      }));

      _isLoading = false;
      notifyListeners();
    } catch (err) {
      _isLoading = false;
      _error = 'Failed to fetch recipes: $err';
      Fluttertoast.showToast(msg: _error);
      notifyListeners();
    }
  }

  void toggleSavedRecipe(String recipeId) {
    if (_savedRecipes.contains(recipeId)) {
      _savedRecipes.remove(recipeId);
    } else {
      _savedRecipes.add(recipeId);
    }
    notifyListeners();
  }

  bool isRecipeSaved(String recipeId) {
    return _savedRecipes.contains(recipeId);
  }
}