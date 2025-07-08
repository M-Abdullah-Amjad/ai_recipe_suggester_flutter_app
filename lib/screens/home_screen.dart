import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_ai_app/providers/recipe_provider.dart';
import 'package:recipe_ai_app/screens/recipe_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _ingredientController = TextEditingController();
  final List<String> _ingredients = [];

  @override
  void dispose() {
    _ingredientController.dispose();
    super.dispose();
  }

  void _addIngredient() {
    if (_ingredientController.text.trim().isNotEmpty) {
      setState(() {
        _ingredients.add(_ingredientController.text.trim());
        _ingredientController.clear();
      });
    }
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  void _searchRecipes() {
    if (_ingredients.isNotEmpty) {
      FocusScope.of(context).unfocus();
      Provider.of<RecipeProvider>(context, listen: false).fetchRecipes(_ingredients);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recipeProvider = Provider.of<RecipeProvider>(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('AI Smart Recipe Suggester'),
        // actions: [
        //   if (_ingredients.isNotEmpty)
        //     IconButton(
        //       icon: const Icon(Icons.search),
        //       onPressed: _searchRecipes,
        //     ),
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              child: TextField(
                controller: _ingredientController,
                decoration: InputDecoration(
                  labelText: 'Add an ingredient',
                  labelStyle: TextStyle(color: theme.primaryColor),
                  hintText: 'e.g. chicken, tomatoes',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.add, color: theme.primaryColor),
                    onPressed: _addIngredient,
                  ),
                ),
                onSubmitted: (_) => _addIngredient(),
              ),
            ),
            const SizedBox(height: 16),
            if (_ingredients.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(
                  _ingredients.length,
                      (index) => Chip(
                    label: Text(
                      _ingredients[index],
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: theme.colorScheme.secondary,
                    deleteIcon: const Icon(Icons.close, size: 18, color: Colors.white),
                    onDeleted: () => _removeIngredient(index),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            if (recipeProvider.isLoading)
              Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.primaryColor,
                    ),
                  ),
                ),
              ),
            if (!recipeProvider.isLoading && recipeProvider.error.isNotEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    recipeProvider.error,
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            if (!recipeProvider.isLoading &&
                recipeProvider.error.isEmpty &&
                recipeProvider.recipes.isNotEmpty)
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: recipeProvider.recipes.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (ctx, index) => Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecipeDetailScreen(
                              recipe: recipeProvider.recipes[index],
                            ),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: Image.network(
                              recipeProvider.recipes[index].image,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, error, stackTrace) => Container(
                                height: 180,
                                color: Colors.grey[200],
                                child: Center(
                                  child: Icon(
                                    Icons.fastfood,
                                    size: 50,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recipeProvider.recipes[index].title,
                                  style: theme.textTheme.titleLarge,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.timer,
                                      size: 20,
                                      color: theme.primaryColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${recipeProvider.recipes[index].readyInMinutes} mins',
                                      style: theme.textTheme.bodyLarge,
                                    ),
                                    const SizedBox(width: 24),
                                    Icon(
                                      Icons.people,
                                      size: 20,
                                      color: theme.primaryColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${recipeProvider.recipes[index].servings} servings',
                                      style: theme.textTheme.bodyLarge,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: _ingredients.isNotEmpty
          ? Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Colors.deepOrange, Colors.orangeAccent],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _searchRecipes,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.search, color: Colors.white),
        ),
      )
          : null,

    );
  }
}