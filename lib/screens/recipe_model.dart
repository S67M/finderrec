// A data model class representing a recipe.
// This exists to model and map recipe data structured for Firestore documents and application state.
class Recipe {
  // Unique Firestore document ID
  final String id;
  // Name of the recipe
  final String name;
  // List of ingredient names needed for the recipe
  final List<String> ingredients;
  // Category of the recipe (e.g. High Protein, Seafood)
  final String category;
  // Preparation and cooking duration in minutes
  final int prepTime;
  // Text detailing step-by-step instructions
  final String instructions;
  // Network URL or local path to the recipe thumbnail image
  final String imageUrl;

  // Constructor to initialize all required fields for a recipe instance.
  Recipe({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.category,
    required this.prepTime,
    required this.instructions,
    required this.imageUrl,
  });

  // Factory constructor to deserialize a Firestore document snapshot map into a Recipe object.
  // Returns: A new Recipe instance populated with database values.
  factory Recipe.fromMap(String id, Map<String, dynamic> data) {
    return Recipe(
      id: id,
      name: data['name'] ?? 'Unknown Recipe',
      ingredients: List<String>.from(data['ingredients'] ?? []),
      category: data['category'] ?? 'Uncategorized',
      prepTime: data['prepTime'] ?? 0,
      instructions: data['instructions'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  // Serializes the Recipe instance properties into a JSON-compatible map.
  // Returns: A Map containing the database schema field values.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'ingredients': ingredients,
      'category': category,
      'prepTime': prepTime,
      'instructions': instructions,
      'imageUrl': imageUrl,
    };
  }
}
