class Recipe {
  final String id;
  final String name;
  final List<String> ingredients;
  final String category;
  final int prepTime;
  final String instructions;
  final String imageUrl;

  Recipe({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.category,
    required this.prepTime,
    required this.instructions,
    required this.imageUrl,
  });

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
