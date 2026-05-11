import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'recipe_list_screen.dart';

// ── Three-state enum ──────────────────────────────────────────────────────────
enum IngredientState { none, selected, excluded }

class IngredientSelectorScreen extends StatefulWidget {
  const IngredientSelectorScreen({super.key});

  @override
  State<IngredientSelectorScreen> createState() =>
      _IngredientSelectorScreenState();
}

class _IngredientSelectorScreenState extends State<IngredientSelectorScreen> {
  // Three-state ingredient map
  Map<String, IngredientState> ingredientStates = {};

  // Info banner visibility
  bool _showInfoBanner = true;

  // ── Cooking time filter ────────────────────────────────────────────────────
  final List<String> _timeFilters = ["Any", "Under 15 min", "30 min", "1 hour+"];
  String _selectedTimeFilter = "Any";

  // ── Ingredient categories ──────────────────────────────────────────────────
  final Map<String, List<String>> ingredientCategories = {
    "🫙 Basics": ["Oil", "Salt", "Sugar", "Garlic"],
    "🌾 Grains & Carbs": ["Rice", "Pasta", "Bread", "Flour"],
    "🧈 Dairy & Fats": ["Milk", "Butter", "Cheese"],
    "🥩 Proteins": ["Chicken", "Beef", "Fish", "Turkey", "Egg", "Shrimp", "Tuna", "Salmon", "Lentils", "Beans", "Tofu"],
    "🥕 Vegetables": ["Potato", "Onion", "Tomato", "Carrot", "Broccoli", "Cucumber", "Spinach", "Pepper", "Zucchini", "Eggplant", "Cabbage", "Corn"],
    "🍎 Fruits": ["Apple", "Banana", "Orange", "Lemon", "Strawberry", "Mango", "Pineapple", "Grapes", "Peach", "Avocado"],
    "🌿 Herbs": ["Parsley", "Cilantro", "Basil", "Mint", "Oregano", "Thyme", "Rosemary", "Dill"],
    "🌶 Spices": ["Black Pepper", "Paprika", "Turmeric", "Cumin", "Cinnamon", "Chili Powder", "Ginger", "Garlic Powder"],
    "🥫 Pantry": ["Tomato Sauce", "Soy Sauce", "Vinegar", "Honey", "Mustard", "Mayonnaise", "Ketchup"],
  };

  // ── State cycling logic ────────────────────────────────────────────────────
  void onIngredientTap(String ingredient) {
    setState(() {
      final current = ingredientStates[ingredient] ?? IngredientState.none;
      if (current == IngredientState.none) {
        ingredientStates[ingredient] = IngredientState.selected;
      } else if (current == IngredientState.selected) {
        ingredientStates[ingredient] = IngredientState.excluded;
      } else {
        ingredientStates[ingredient] = IngredientState.none;
      }
    });
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  List<String> get _selectedList => ingredientStates.entries
      .where((e) => e.value == IngredientState.selected)
      .map((e) => e.key)
      .toList();

  List<String> get _excludedList => ingredientStates.entries
      .where((e) => e.value == IngredientState.excluded)
      .map((e) => e.key)
      .toList();

  // ── Chip builder ───────────────────────────────────────────────────────────
  Widget _buildChip(String ing) {
    final state = ingredientStates[ing] ?? IngredientState.none;

    final Color bgColor;
    final Color borderColor;
    final Color textColor;

    switch (state) {
      case IngredientState.selected:
        bgColor = const Color(0xFFFFF0E8);
        borderColor = const Color(0xFFF4631E);
        textColor = const Color(0xFFF4631E);
        break;
      case IngredientState.excluded:
        bgColor = const Color(0xFFFFEBEB);
        borderColor = const Color(0xFFE53935);
        textColor = const Color(0xFFE53935);
        break;
      case IngredientState.none:
        bgColor = const Color(0xFFFFFDFB);
        borderColor = Colors.grey.shade200;
        textColor = const Color(0xFF2D3142);
        break;
    }

    return GestureDetector(
      onTap: () => onIngredientTap(ing),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: state != IngredientState.none
              ? [
                  BoxShadow(
                    color: borderColor.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (state == IngredientState.excluded) ...[
              Icon(Icons.close_rounded, size: 14, color: textColor),
              const SizedBox(width: 4),
            ],
            Text(
              ing,
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w600,
                color: textColor,
                fontSize: 14,
              ),
            ),
            if (state == IngredientState.selected) ...[
              const SizedBox(width: 4),
              Icon(Icons.check_rounded, size: 14, color: textColor),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = _selectedList.length;
    final excludedCount = _excludedList.length;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F3),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Pick Ingredients',
          style: GoogleFonts.playfairDisplay(
            color: const Color(0xFF2D3142),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xFFFFF8F3),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFF4631E)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          Text(
            "What's in your kitchen?",
            style: GoogleFonts.playfairDisplay(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D3142),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Select ingredients to find matching recipes",
            style: GoogleFonts.dmSans(fontSize: 15, color: Colors.black54),
          ),
          const SizedBox(height: 24),

          // ── Hero banner ─────────────────────────────────────────────────────
          Container(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF4631E).withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                )
              ],
              image: const DecorationImage(
                image: NetworkImage(
                  "https://images.unsplash.com/photo-1495521821757-a1efb6729352?auto=format&fit=crop&q=80&w=800",
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
              ),
              padding: const EdgeInsets.all(20),
              alignment: Alignment.bottomLeft,
              child: Text(
                "Featured Recipes\nof the Day",
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Dismissible info banner ──────────────────────────────────────────
          if (_showInfoBanner)
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8F3),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF4631E).withOpacity(0.40)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("💡", style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Tap once to include ✓ an ingredient, tap again to exclude ✗ it from results, tap a third time to clear.",
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: const Color(0xFF888888),
                        height: 1.45,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _showInfoBanner = false),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Color(0xFFF4631E),
                    ),
                  ),
                ],
              ),
            ),

          // ── Cooking Time Filter ──────────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.timer_outlined, size: 18, color: Color(0xFFF4631E)),
              const SizedBox(width: 6),
              Text(
                "⏱ Cooking Time",
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D3142),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _timeFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _timeFilters[index];
                final isSelected = _selectedTimeFilter == filter;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTimeFilter = filter),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFF4631E) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFF4631E) : Colors.grey.shade300,
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: const Color(0xFFF4631E).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
                          : [],
                    ),
                    child: Text(
                      filter,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF2D3142),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 28),

          // ── Active selections summary ─────────────────────────────────────────
          if (selectedCount > 0 || excludedCount > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Wrap(
                spacing: 10,
                children: [
                  if (selectedCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0E8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFF4631E).withOpacity(0.5)),
                      ),
                      child: Text(
                        "✓ $selectedCount included",
                        style: GoogleFonts.dmSans(fontSize: 12, color: const Color(0xFFF4631E), fontWeight: FontWeight.w600),
                      ),
                    ),
                  if (excludedCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEB),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE53935).withOpacity(0.5)),
                      ),
                      child: Text(
                        "✗ $excludedCount excluded",
                        style: GoogleFonts.dmSans(fontSize: 12, color: const Color(0xFFE53935), fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
            ),

          // ── Ingredient Categories ────────────────────────────────────────────
          ...ingredientCategories.entries.map((category) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.key,
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 12,
                    children: category.value.map(_buildChip).toList(),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 80), // Padding for FAB
        ],
      ),
      floatingActionButton: selectedCount >= 3
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecipeListScreen(
                      ingredients: _selectedList,
                      excludedIngredients: _excludedList,
                      timeFilter: _selectedTimeFilter,
                    ),
                  ),
                );
              },
              backgroundColor: const Color(0xFFF4631E),
              elevation: 4,
              icon: const Icon(Icons.search, color: Colors.white),
              label: Text(
                "Find Recipes ($selectedCount)",
                style: GoogleFonts.dmSans(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
