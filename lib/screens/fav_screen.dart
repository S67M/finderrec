import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'db_service.dart';
import 'recipe_model.dart';
import 'recipe_list_screen.dart'; // We can reuse the same card layout if we want, or build it here.

// A screen widget representing the user's favorite recipes view.
// This exists to compile and display all recipes bookmarked/liked by the current user.
// Returns: A FavoritesScreen widget.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  // Creates the mutable state object for this widget.
  // Returns: An instance of _FavoritesScreenState.
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

// The mutable state class for FavoritesScreen.
// It manages loading recipes, filtering favorites from the stream, and building list layout.
class _FavoritesScreenState extends State<FavoritesScreen> {
  // Instance of the database service wrapper
  final DBService _db = DBService();
  
  // Local cache of all recipes fetched from Firestore
  List<Recipe> _allRecipes = [];

  // Initializes widget state, loading the complete list of recipes.
  // This exists to sync data before matching favorites.
  // Returns: void.
  @override
  void initState() {
    super.initState();
    // Load the base list of recipes immediately on startup
    _loadRecipes();
  }

  // Fetches the entire collection of recipes asynchronously.
  // This exists to cache recipes in memory to easily query by their ID matches.
  // Modifies: Updates the _allRecipes state list.
  // Returns: void.
  void _loadRecipes() async {
    final recipes = await _db.getAllRecipes();
    setState(() {
      _allRecipes = recipes;
    });
  }

  // Builds the UI layout structure for the user's favorites screen.
  // This exists to listen to the favorites Stream and render corresponding RecipeCards.
  // Returns: A Scaffold layout populated with favorited recipes or placeholder text.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8F3),
        elevation: 0,
        leading: const BackButton(color: Color(0xFF2D3142)),
        centerTitle: true,
        title: Text(
          'Favorites',
          style: GoogleFonts.playfairDisplay(
            color: const Color(0xFF2D3142),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: StreamBuilder<List<String>>(
        // Stream of favorite recipe document IDs
        stream: _db.getFavorites(),
        builder: (context, snapshot) {
          // Display a spinner while waiting for firebase records
          if (snapshot.connectionState == ConnectionState.waiting || _allRecipes.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFFA559)));
          }

          final favIds = snapshot.data ?? [];
          // Filter cached recipes list matching the bookmarked IDs
          final favRecipes = _allRecipes.where((r) => favIds.contains(r.id)).toList();

          // Inform user if no favorites exist yet
          if (favRecipes.isEmpty) {
            return const Center(
              child: Text(
                "No favorites added yet.", 
                style: TextStyle(fontSize: 18, color: Colors.black54)
              )
            );
          }

          // Render list of matching recipe cards
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
