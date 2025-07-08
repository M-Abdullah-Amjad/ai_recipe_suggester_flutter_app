import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_ai_app/providers/recipe_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  Future<void> _launchUrl(BuildContext context) async {
    final uri = Uri.parse(recipe.sourceUrl);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $uri');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open recipe: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                recipe.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      blurRadius: 4,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
              background: Hero(
                tag: recipe.id,
                child: Image.network(
                  recipe.image,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, error, stackTrace) => Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: Icon(
                        Icons.fastfood,
                        size: 100,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  recipeProvider.isRecipeSaved(recipe.id.toString())
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: Colors.red[400],
                ),
                onPressed: () {
                  recipeProvider.toggleSavedRecipe(recipe.id.toString());
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        recipeProvider.isRecipeSaved(recipe.id.toString())
                            ? 'Recipe saved!'
                            : 'Recipe removed',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _InfoChip(
                        icon: Icons.timer,
                        value: '${recipe.readyInMinutes} mins',
                        color: theme.primaryColor,
                      ),
                      _InfoChip(
                        icon: Icons.people,
                        value: '${recipe.servings} servings',
                        color: theme.primaryColor,
                      ),
                      // Removed calories chip since it's not in Recipe model
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'About this recipe',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    recipe.summary.replaceAll(RegExp(r'<[^>]*>'), ''),
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Ingredients',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  ...recipe.ingredients.map((ingredient) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 8,
                          color: theme.primaryColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            ingredient,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 24),
                  Text(
                    'Instructions',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  ...recipe.instructions.asMap().entries.map((entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      onPressed: () => _launchUrl(context),
                      child: const Text(
                        'VIEW FULL RECIPE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: color.withOpacity(0.1),
      avatar: Icon(icon, size: 18, color: color),
      label: Text(
        value,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[700],
        ),
      ),
    );
  }
}