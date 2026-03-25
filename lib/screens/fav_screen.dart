import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'db_service.dart';
import 'recipe_model.dart';
import 'recipe_list_screen.dart'; // We can reuse the same card layout if we want, or build it here.

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final DBService _db = DBService();
  List<Recipe> _allRecipes = [];

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  void _loadRecipes() async {
    final recipes = await _db.getAllRecipes();
    setState(() {
      _allRecipes = recipes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: StreamBuilder<List<String>>(
        stream: _db.getFavorites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || _allRecipes.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFFA559)));
          }

          final favIds = snapshot.data ?? [];
          final favRecipes = _allRecipes.where((r) => favIds.contains(r.id)).toList();

          if (favRecipes.isEmpty) {
            return const Center(
              child: Text(
                "No favorites added yet.", 
                style: TextStyle(fontSize: 18, color: Colors.black54)
              )
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: favRecipes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 20),
            itemBuilder: (context, index) {
              final recipe = favRecipes[index];
              return RecipeCard(recipe: recipe, isFavorite: true, onFavoriteToggle: () => _db.toggleFavorite(recipe.id));
            },
          );
        },
      ),
    );
  }
}
