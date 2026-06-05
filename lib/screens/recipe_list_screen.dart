import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/ingredients.dart';
import 'db_service.dart';
import 'recipe_model.dart';

// ── Matching-algorithm constants ───────────────────────────────────────────────

// The list of primary food categories that represent substantive ingredients.
// This exists to classify and validate whether the user has selected at least one core ingredient.
const List<String> _bigFour = [
  "Proteins",
  "Vegetables",
  "Grains & Carbs",
  "Fruits",
];

// The hierarchical priority order for sorting recipe search results.
// This exists to order matching recipes based on matches in key food groups first.
const List<String> _categoryPriority = [
  "Proteins",
  "Vegetables",
  "Grains & Carbs",
  "Fruits",
  "Dairy & Fats",
  "Pantry",
  "Herbs",
  "Spices",
  "Basics",
];

// ── Priority sort ──────────────────────────────────────────────────────────────
// [ingredientCategory] is the combined base + custom map built at runtime.

// Sorts and filters the given recipes by priority based on match counts and food group rules.
// This exists to arrange matching recipes so the most relevant/complete meals are displayed first.
// Modifies: Filters and sorts the recipes list argument.
// Returns: A new sorted and filtered list of Recipe objects.
List<Recipe> _sortByPriority(
  List<Recipe> recipes,
  List<String> selected,
  Map<String, String> ingredientCategory,
) {
  // Find which of the user's selected ingredients belong to the core Big Four categories
  final selectedBigFour = selected
      .where((i) => _bigFour.contains(ingredientCategory[i]))
      .toList();

  // Law 2 — Keep only recipes that match at least one bigFour selected ingredient
  recipes = recipes.where((r) {
    return selectedBigFour.any((i) => r.ingredients.contains(i));
  }).toList();

  // Law 3 — Sort by bigFour count first (descending), then by category priority
  recipes.sort((a, b) {
    final bigFourA =
        selectedBigFour.where((i) => a.ingredients.contains(i)).length;
    final bigFourB =
        selectedBigFour.where((i) => b.ingredients.contains(i)).length;

    // Place recipes with more Big Four matches at the top
    if (bigFourB != bigFourA) return bigFourB.compareTo(bigFourA);

    // If Big Four counts are equal, fall back to sorting by category priority hierarchies
    for (final category in _categoryPriority) {
      final catIngredients =
          selected.where((i) => ingredientCategory[i] == category).toList();
      final matchA =
          catIngredients.where((i) => a.ingredients.contains(i)).length;
      final matchB =
          catIngredients.where((i) => b.ingredients.contains(i)).length;
      if (matchB != matchA) return matchB.compareTo(matchA);
    }
    return 0;
  });

  return recipes;
}

// ── Screen ─────────────────────────────────────────────────────────────────────

// A screen widget representing the filtered search results or browsed category recipe list.
// This exists to present recipe matching outputs or group browse listings of the app.
// Returns: A RecipeListScreen widget.
class RecipeListScreen extends StatefulWidget {
  final String? category;
  final List<String>? ingredients;
  final List<String>? excludedIngredients;
  final String? timeFilter;

  const RecipeListScreen({
    super.key,
    this.category,
    this.ingredients,
    this.excludedIngredients,
    this.timeFilter,
  });

  // Creates the mutable state object for this screen.
  // Returns: An instance of _RecipeListScreenState.
  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

// The mutable state class for RecipeListScreen.
// It manages custom ingredient syncing, recipe fetching, priority filtering, and layout building.
class _RecipeListScreenState extends State<RecipeListScreen> {
  // Database service wrapper
  final DBService _db = DBService();
  
  // Local list of loaded/filtered recipes to render
  List<Recipe> _recipes = [];
  
  // Loading status indicator flag
  bool _loading = true;
  
  // Banner visibility indicating if a grocery run is recommended
  bool _showShoppingMessage = false; // Law 1

  // Cache of custom user ingredients loaded from Firestore
  List<Map<String, String>> _customIngredients = [];

  // Initializes screen state, loading ingredients and fetching recipe data.
  // Returns: void.
  @override
  void initState() {
    super.initState();
    _loadAndFetch();
  }

  // Loads custom ingredients first, then runs the recipe fetch + filter logic.
  // This exists to compile the global ingredient database map before executing matches.
  // Modifies: Updates _customIngredients list.
  // Returns: Future<void> representing asynchronous setup steps.
  Future<void> _loadAndFetch() async {
    try {
      // Wait for the first emission of the custom ingredients stream
      final custom = await _db.getCustomIngredients().first;
      if (mounted) setState(() => _customIngredients = custom);
    } catch (_) {
      // If the collection doesn't exist yet, proceed with empty list
    }
    // Fetch and filter recipes based on current configuration
    _fetchRecipes();
  }

  // Performs main recipe loading, category filtering, exclusions, and sorting operations.
  // This exists to execute the search engine rules dynamically based on parameter settings.
  // Modifies: Updates local _recipes list, _showShoppingMessage flag, and _loading status.
  // Returns: void.
  void _fetchRecipes() async {
    // Build the complete ingredient→category map (base + custom)
    final ingredientCategory = buildIngredientCategoryMap(_customIngredients);

    // For ingredient search, include the user's own recipes alongside public ones.
    // For category browse, show every recipe (getAllRecipes).
    List<Recipe> all;
    if (widget.ingredients != null && widget.ingredients!.isNotEmpty) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      all = uid != null
          ? await _db.getAllRecipesForUser(uid)
          : await _db.getAllRecipes();
    } else {
      all = await _db.getAllRecipes();
    }

    setState(() {
      if (widget.category != null) {
        // ── Category browse — simple filter, no priority logic ────────────────
        _recipes = all.where((r) => r.category == widget.category).toList();
      } else if (widget.ingredients != null &&
          widget.ingredients!.isNotEmpty) {
        final selected = widget.ingredients!;

        // ── Law 1 — Shopping message if no bigFour ingredient selected ────────
        final hasBigFour = selected
            .any((i) => _bigFour.contains(ingredientCategory[i]));

        if (!hasBigFour) {
          _showShoppingMessage = true;
          _loading = false;
          return;
        }

        _showShoppingMessage = false;

        // Start with all recipes matching at least one selected ingredient
        _recipes = all
            .where((r) =>
                r.ingredients.any((ing) => selected.contains(ing)))
            .toList();

        // ── Step 1: Apply excluded ingredients ────────────────────────────────
        final excluded = widget.excludedIngredients;
        if (excluded != null && excluded.isNotEmpty) {
          _recipes = _recipes
              .where((r) =>
                  !r.ingredients.any((ing) => excluded.contains(ing)))
              .toList();
        }

        // ── Step 2: Sort by bigFour + category priority ───────────────────────
        _recipes = _sortByPriority(_recipes, selected, ingredientCategory);

        // ── Step 3: Apply time filter ─────────────────────────────────────────
        final tf = widget.timeFilter;
        if (tf != null && tf != "Any") {
          if (tf == "Under 15 min") {
            _recipes = _recipes.where((r) => r.prepTime <= 15).toList();
          } else if (tf == "30 min") {
            _recipes = _recipes.where((r) => r.prepTime <= 30).toList();
          } else if (tf == "1 hour+") {
            _recipes = _recipes.where((r) => r.prepTime >= 60).toList();
          }
        }
      } else {
        _recipes = all;
      }

      _loading = false;
    });
  }


  // Builds the UI layout structure for the recipe list/results screen.
  // Returns: A Scaffold layout containing list view, loading indicator or shopping message.
  @override
  Widget build(BuildContext context) {
    final title = widget.category != null
        ? widget.category!
        : 'Search Results (${_recipes.length})';
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF2D3142),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF2D3142)),
        elevation: 0,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFA559)))
          : _showShoppingMessage
              ? const _ShoppingMessage()
              : _recipes.isEmpty
                  ? const Center(
                      child: Text(
                        "No recipes found.",
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                    )
                  : StreamBuilder<List<String>>(
                      stream: _db.getFavorites(),
                      builder: (context, snapshot) {
                        final favIds = snapshot.data ?? [];
                        return ListView.separated(
                          padding: const EdgeInsets.all(20),
                          itemCount: _recipes.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 20),
                          itemBuilder: (context, index) {
                            final recipe = _recipes[index];
                            final isFav = favIds.contains(recipe.id);
                            return RecipeCard(
                              recipe: recipe,
                              isFavorite: isFav,
                              onFavoriteToggle: () =>
                                  _db.toggleFavorite(recipe.id),
                            );
                          },
                        );
                      },
                    ),
    );
  }
}

// ── Law 1 — Shopping message widget ───────────────────────────────────────────

// A stateless widget presenting a prompt when no core food ingredients are selected.
// This exists to encourage the user to add essential cooking ingredients to make a complete meal.
// Returns: A _ShoppingMessage widget.
class _ShoppingMessage extends StatelessWidget {
  const _ShoppingMessage();

  // List of possible humorous messages recommending a shopping trip
  static const List<String> _messages = [
    "Looks like your fridge needs a grocery run! 🛒",
    "Even the best chefs need real ingredients. Time to shop! 🛍️",
    "We checked... and checked again. Your cart is calling! 🛒😄",
    "No proteins, veggies, grains, or fruits? That's a season finale cliffhanger! 🍽️",
  ];

  // Builds the layout for the shopping message card display.
  // Returns: A Center widget container with details and redirect options.
  @override
  Widget build(BuildContext context) {
    // Pick a message deterministically based on seconds elapsed
    final message = _messages[DateTime.now().second % _messages.length];

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("🛒", style: TextStyle(fontSize: 64)),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D3142),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Add at least one protein, vegetable, grain, or fruit to find great recipes.",
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: Colors.black45,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_rounded,
                  size: 16, color: Color(0xFFF4631E)),
              label: Text(
                "Go back and pick ingredients",
                style: GoogleFonts.dmSans(
                  color: const Color(0xFFF4631E),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// A reusable card widget rendering details of an individual recipe item.
// This exists to show the user the name, preparation duration, ingredients list, and favorites toggle for a recipe.
// Returns: A RecipeCard widget.
class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  // Builds the card layout structure detailing a single recipe.
  // Returns: A Container widget containing thumbnail image, favorite button, and instruction text.
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  recipe.imageUrl, 
                  height: 180, 
                  width: double.infinity,
                  fit: BoxFit.cover, 
                  errorBuilder: (_,__,___) => Container(
                    height: 180, 
                    color: Colors.grey.shade200, 
                    child: const Icon(Icons.restaurant, color: Colors.grey, size: 50)
                  )
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border, 
                      color: const Color(0xFFFFA559)
                    ),
                    onPressed: onFavoriteToggle,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(recipe.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2D3142))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 18, color: Color(0xFFFFA559)),
                    const SizedBox(width: 4),
                    Text("${recipe.prepTime} mins", style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
                    const SizedBox(width: 24),
                    const Icon(Icons.category_outlined, size: 18, color: Color(0xFFFFA559)),
                    const SizedBox(width: 4),
                    Text(recipe.category, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 16),
                const Text("Ingredients", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3142))),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: recipe.ingredients.map((ing) => Chip(
                    label: Text(ing, style: const TextStyle(fontSize: 12, color: Color(0xFF2D3142))),
                    backgroundColor: const Color(0xFFFFA559).withOpacity(0.1),
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                  )).toList(),
                ),
                const SizedBox(height: 16),
                const Text("Instructions", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3142))),
                const SizedBox(height: 6),
                Text(recipe.instructions, style: const TextStyle(color: Colors.black54, height: 1.5, fontSize: 15)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
