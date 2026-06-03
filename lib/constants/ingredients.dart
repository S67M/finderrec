/// Shared ingredient data for the Recipe Finder app.
///
/// All screens that display or process ingredients must import this file
/// instead of duplicating the ingredient lists locally.

// ── Base ingredient categories (emoji-prefixed keys used in UI pickers) ────────

const Map<String, List<String>> kBaseIngredients = {
  "🫙 Basics":         ["Oil", "Salt", "Sugar", "Garlic"],
  "🌾 Grains & Carbs": ["Rice", "Pasta", "Bread", "Flour"],
  "🧈 Dairy & Fats":   ["Milk", "Butter", "Cheese"],
  "🥩 Proteins":       [
    "Chicken", "Beef", "Fish", "Turkey", "Egg", "Shrimp",
    "Tuna", "Salmon", "Lentils", "Beans", "Tofu",
  ],
  "🥕 Vegetables": [
    "Potato", "Onion", "Tomato", "Carrot", "Broccoli", "Cucumber",
    "Spinach", "Pepper", "Zucchini", "Eggplant", "Cabbage", "Corn",
  ],
  "🍎 Fruits": [
    "Apple", "Banana", "Orange", "Lemon", "Strawberry",
    "Mango", "Pineapple", "Grapes", "Peach", "Avocado",
  ],
  "🌿 Herbs":  ["Parsley", "Cilantro", "Basil", "Mint", "Oregano", "Thyme", "Rosemary", "Dill"],
  "🌶 Spices": ["Black Pepper", "Paprika", "Turmeric", "Cumin", "Cinnamon", "Chili Powder", "Ginger", "Garlic Powder"],
  "🥫 Pantry": ["Tomato Sauce", "Soy Sauce", "Vinegar", "Honey", "Mustard", "Mayonnaise", "Ketchup"],
};

// ── Plain category names — used in Firestore storage and dropdowns ─────────────

const List<String> kCategoryNames = [
  "Basics",
  "Grains & Carbs",
  "Dairy & Fats",
  "Proteins",
  "Vegetables",
  "Fruits",
  "Herbs",
  "Spices",
  "Pantry",
];

/// Maps a plain category name → its emoji-prefixed key in [kBaseIngredients].
const Map<String, String> kCategoryEmojiKey = {
  "Basics":         "🫙 Basics",
  "Grains & Carbs": "🌾 Grains & Carbs",
  "Dairy & Fats":   "🧈 Dairy & Fats",
  "Proteins":       "🥩 Proteins",
  "Vegetables":     "🥕 Vegetables",
  "Fruits":         "🍎 Fruits",
  "Herbs":          "🌿 Herbs",
  "Spices":         "🌶 Spices",
  "Pantry":         "🥫 Pantry",
};

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Merges Firestore [custom] ingredients into the [base] ingredient map.
///
/// - [base] uses emoji-prefixed keys (e.g. "🌾 Grains & Carbs").
/// - [custom] is a list of `{name, category}` maps where `category` is a
///   plain name (e.g. "Grains & Carbs") as stored in Firestore.
/// - Returns a new deep-copied map — never mutates [base].
Map<String, List<String>> mergeIngredients(
  Map<String, List<String>> base,
  List<Map<String, String>> custom,
) {
  // Deep-copy base to avoid mutating the const
  final merged = <String, List<String>>{
    for (final e in base.entries) e.key: List<String>.from(e.value),
  };

  for (final item in custom) {
    final name     = item['name']     ?? '';
    final plainCat = item['category'] ?? '';
    if (name.isEmpty || plainCat.isEmpty) continue;

    // Resolve to the emoji-prefixed key when possible; fall back to plain name
    final key = kCategoryEmojiKey[plainCat] ?? plainCat;

    merged.putIfAbsent(key, () => []);
    if (!merged[key]!.contains(name)) {
      merged[key]!.add(name);
    }
  }

  return merged;
}

/// Builds the flat `ingredient → plain-category` map used by the matching
/// algorithm in RecipeListScreen.
///
/// Starts from [_kBaseIngredientCategory] and appends any [custom] entries
/// with their stored plain category names.
Map<String, String> buildIngredientCategoryMap(
  List<Map<String, String>> custom,
) {
  final map = Map<String, String>.from(_kBaseIngredientCategory);
  for (final item in custom) {
    final name = item['name'] ?? '';
    final cat  = item['category'] ?? '';
    if (name.isNotEmpty && cat.isNotEmpty) map[name] = cat;
  }
  return map;
}

// ── Internal base flat map (ingredient → plain category) ─────────────────────

const Map<String, String> _kBaseIngredientCategory = {
  // Basics
  "Oil": "Basics", "Salt": "Basics", "Sugar": "Basics", "Garlic": "Basics",
  // Grains & Carbs
  "Rice": "Grains & Carbs", "Pasta": "Grains & Carbs",
  "Bread": "Grains & Carbs", "Flour": "Grains & Carbs",
  // Dairy & Fats
  "Milk": "Dairy & Fats", "Butter": "Dairy & Fats", "Cheese": "Dairy & Fats",
  // Proteins
  "Chicken": "Proteins", "Beef": "Proteins",   "Fish": "Proteins",
  "Turkey":  "Proteins", "Egg":  "Proteins",   "Shrimp": "Proteins",
  "Tuna":    "Proteins", "Salmon": "Proteins", "Lentils": "Proteins",
  "Beans":   "Proteins", "Tofu": "Proteins",
  // Vegetables
  "Potato":   "Vegetables", "Onion":    "Vegetables", "Tomato":   "Vegetables",
  "Carrot":   "Vegetables", "Broccoli": "Vegetables", "Cucumber": "Vegetables",
  "Spinach":  "Vegetables", "Pepper":   "Vegetables", "Zucchini": "Vegetables",
  "Eggplant": "Vegetables", "Cabbage":  "Vegetables", "Corn":     "Vegetables",
  // Fruits
  "Apple":     "Fruits", "Banana":     "Fruits", "Orange":    "Fruits",
  "Lemon":     "Fruits", "Strawberry": "Fruits", "Mango":     "Fruits",
  "Pineapple": "Fruits", "Grapes":     "Fruits", "Peach":     "Fruits",
  "Avocado":   "Fruits",
  // Herbs
  "Parsley":  "Herbs", "Cilantro": "Herbs", "Basil":    "Herbs", "Mint":  "Herbs",
  "Oregano":  "Herbs", "Thyme":    "Herbs", "Rosemary": "Herbs", "Dill":  "Herbs",
  // Spices
  "Black Pepper":   "Spices", "Paprika":       "Spices", "Turmeric": "Spices",
  "Cumin":          "Spices", "Cinnamon":      "Spices",
  "Chili Powder":   "Spices", "Ginger":        "Spices",
  "Garlic Powder":  "Spices",
  // Pantry
  "Tomato Sauce": "Pantry", "Soy Sauce":  "Pantry", "Vinegar":    "Pantry",
  "Honey":        "Pantry", "Mustard":    "Pantry", "Mayonnaise": "Pantry",
  "Ketchup":      "Pantry",
};
