import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'db_service.dart';
import 'recipe_model.dart';

// ── Matching-algorithm constants ───────────────────────────────────────────────

const List<String> _bigFour = [
  "Proteins",
  "Vegetables",
  "Grains & Carbs",
  "Fruits",
];

const Map<String, String> _ingredientCategory = {
  "Oil": "Basics", "Salt": "Basics", "Sugar": "Basics", "Garlic": "Basics",
  "Rice": "Grains & Carbs", "Pasta": "Grains & Carbs", "Bread": "Grains & Carbs", "Flour": "Grains & Carbs",
  "Milk": "Dairy & Fats", "Butter": "Dairy & Fats", "Cheese": "Dairy & Fats",
  "Chicken": "Proteins", "Beef": "Proteins", "Fish": "Proteins", "Turkey": "Proteins",
  "Egg": "Proteins", "Shrimp": "Proteins", "Tuna": "Proteins", "Salmon": "Proteins",
  "Lentils": "Proteins", "Beans": "Proteins", "Tofu": "Proteins",
  "Potato": "Vegetables", "Onion": "Vegetables", "Tomato": "Vegetables", "Carrot": "Vegetables",
  "Broccoli": "Vegetables", "Cucumber": "Vegetables", "Spinach": "Vegetables", "Pepper": "Vegetables",
  "Zucchini": "Vegetables", "Eggplant": "Vegetables", "Cabbage": "Vegetables", "Corn": "Vegetables",
  "Apple": "Fruits", "Banana": "Fruits", "Orange": "Fruits", "Lemon": "Fruits",
  "Strawberry": "Fruits", "Mango": "Fruits", "Pineapple": "Fruits", "Grapes": "Fruits",
  "Peach": "Fruits", "Avocado": "Fruits",
  "Parsley": "Herbs", "Cilantro": "Herbs", "Basil": "Herbs", "Mint": "Herbs",
  "Oregano": "Herbs", "Thyme": "Herbs", "Rosemary": "Herbs", "Dill": "Herbs",
  "Black Pepper": "Spices", "Paprika": "Spices", "Turmeric": "Spices", "Cumin": "Spices",
  "Cinnamon": "Spices", "Chili Powder": "Spices", "Ginger": "Spices", "Garlic Powder": "Spices",
  "Tomato Sauce": "Pantry", "Soy Sauce": "Pantry", "Vinegar": "Pantry", "Honey": "Pantry",
  "Mustard": "Pantry", "Mayonnaise": "Pantry", "Ketchup": "Pantry",
};

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

List<Recipe> _sortByPriority(
  List<Recipe> recipes,
  List<String> selected,
) {
  final selectedBigFour = selected
      .where((i) => _bigFour.contains(_ingredientCategory[i]))
      .toList();

  // Law 2 — keep only recipes that match at least one bigFour selected ingredient
  recipes = recipes.where((r) {
    return selectedBigFour.any((i) => r.ingredients.contains(i));
  }).toList();

  // Law 3 — sort by bigFour count first, then by category priority
  recipes.sort((a, b) {
    final bigFourA =
        selectedBigFour.where((i) => a.ingredients.contains(i)).length;
    final bigFourB =
        selectedBigFour.where((i) => b.ingredients.contains(i)).length;

    if (bigFourB != bigFourA) return bigFourB.compareTo(bigFourA);

    for (final category in _categoryPriority) {
      final catIngredients =
          selected.where((i) => _ingredientCategory[i] == category).toList();
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

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  final DBService _db = DBService();
  List<Recipe> _recipes = [];
  bool _loading = true;
  bool _showShoppingMessage = false; // Law 1

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
  }

  void _fetchRecipes() async {
    final all = await _db.getAllRecipes();
    setState(() {
      if (widget.category != null) {
        // ── Category browse — simple filter, no priority logic ────────────────
        _recipes = all.where((r) => r.category == widget.category).toList();
      } else if (widget.ingredients != null &&
          widget.ingredients!.isNotEmpty) {
        final selected = widget.ingredients!;

        // ── Law 1 — Shopping message if no bigFour ingredient selected ────────
        final hasBigFour = selected
            .any((i) => _bigFour.contains(_ingredientCategory[i]));

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
        _recipes = _sortByPriority(_recipes, selected);

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

  @override
  Widget build(BuildContext context) {
    final title = widget.category ?? "Search Results";
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

class _ShoppingMessage extends StatelessWidget {
  const _ShoppingMessage();

  static const List<String> _messages = [
    "Looks like your fridge needs a grocery run! 🛒",
    "Even the best chefs need real ingredients. Time to shop! 🛍️",
    "We checked... and checked again. Your cart is calling! 🛒😄",
    "No proteins, veggies, grains, or fruits? That's a season finale cliffhanger! 🍽️",
  ];

  @override
  Widget build(BuildContext context) {
    // Pick a message deterministically (same every time, feels intentional)
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
