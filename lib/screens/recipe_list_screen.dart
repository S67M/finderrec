import 'package:flutter/material.dart';
import 'db_service.dart';
import 'recipe_model.dart';

class RecipeListScreen extends StatefulWidget {
  final String? category;
  final List<String>? ingredients;

  const RecipeListScreen({super.key, this.category, this.ingredients});

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  final DBService _db = DBService();
  List<Recipe> _recipes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
  }

  void _fetchRecipes() async {
    final all = await _db.getAllRecipes();
    setState(() {
      if (widget.category != null) {
        _recipes = all.where((r) => r.category == widget.category).toList();
      } else if (widget.ingredients != null && widget.ingredients!.isNotEmpty) {
        // Find recipes that contain at least one of the selected ingredients
        _recipes = all.where((r) => 
          r.ingredients.any((ing) => widget.ingredients!.contains(ing))
        ).toList();
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
        title: Text(title, style: const TextStyle(color: Color(0xFF2D3142), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF2D3142)),
        elevation: 0,
      ),
      body: _loading ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFA559)))
          : _recipes.isEmpty ? const Center(child: Text("No recipes found.", style: TextStyle(fontSize: 18, color: Colors.black54)))
          : StreamBuilder<List<String>>(
              stream: _db.getFavorites(),
              builder: (context, snapshot) {
                final favIds = snapshot.data ?? [];
                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _recipes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    final recipe = _recipes[index];
                    final isFav = favIds.contains(recipe.id);
                    return RecipeCard(
                      recipe: recipe, 
                      isFavorite: isFav, 
                      onFavoriteToggle: () => _db.toggleFavorite(recipe.id)
                    );
                  },
                );
              }
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
