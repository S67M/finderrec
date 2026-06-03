import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'db_service.dart';
import 'recipe_list_screen.dart';
import 'recipe_model.dart';

// ── Design constants ──────────────────────────────────────────────────────────
const _kOrange = Color(0xFFF4631E);
const _kBg = Color(0xFFFFF8F3);
const _kDark = Color(0xFF2D3142);
const _kGrey = Color(0xFF9E9E9E);

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  // ── Categories — Others excluded ──────────────────────────────────────────
  final List<Map<String, String>> categories = const [
    {'name': 'High Protein',  'image': 'https://images.unsplash.com/photo-1532550907401-a500c9a57435?w=500'},
    {'name': 'Gluten-Free',   'image': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500'},
    {'name': 'Seafood',       'image': 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=500'},
    {'name': 'Sandwiches',    'image': 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=500'},
    {'name': 'Soups',         'image': 'https://images.unsplash.com/photo-1476718406336-bb5a9690ee2a?w=500'},
    {'name': 'Salads',        'image': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=500'},
    {'name': 'Desserts',      'image': 'https://images.unsplash.com/photo-1551024601-bec78aea704b?w=500'},
    {'name': 'Juices',        'image': 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=500'},
    {'name': 'Traditional',   'image': 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=800'},
    {'name': 'Breakfast',     'image': 'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?w=800'},
  ];

  // ── All-recipes state ─────────────────────────────────────────────────────
  final DBService _db = DBService();
  List<Recipe> _allRecipes = [];
  bool _loadingRecipes = true;

  @override
  void initState() {
    super.initState();
    _fetchAllRecipes();
  }

  Future<void> _fetchAllRecipes() async {
    try {
      final recipes = await _db.getAllRecipes();
      if (mounted) {
        setState(() {
          _allRecipes = recipes;
          _loadingRecipes = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingRecipes = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        leading: const BackButton(color: _kDark),
        centerTitle: true,
        title: Text(
          'All Recipes',
          style: GoogleFonts.playfairDisplay(
            color: _kDark,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: _kOrange,
        onRefresh: _fetchAllRecipes,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [

            // ── 2-column category grid ──────────────────────────────────────
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 130,
              ),
              itemBuilder: (context, index) {
                final cat = categories[index];
                return _CategoryCard(
                  name: cat['name']!,
                  imageUrl: cat['image']!,
                );
              },
            ),

            const SizedBox(height: 24),

            // ── All recipes — no title, flows naturally ─────────────────────
            if (_loadingRecipes)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: CircularProgressIndicator(color: _kOrange),
                ),
              )
            else if (_allRecipes.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    'No recipes found.',
                    style: GoogleFonts.dmSans(fontSize: 15, color: _kGrey),
                  ),
                ),
              )
            else
              StreamBuilder<List<String>>(
                stream: _db.getFavorites(),
                builder: (context, snapshot) {
                  final favIds = snapshot.data ?? [];
                  return Column(
                    children: List.generate(_allRecipes.length, (index) {
                      final recipe = _allRecipes[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: RecipeCard(
                          recipe: recipe,
                          isFavorite: favIds.contains(recipe.id),
                          onFavoriteToggle: () => _db.toggleFavorite(recipe.id),
                        ),
                      );
                    }),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

// ── Background-image category card ───────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  final String name;
  final String imageUrl;

  const _CategoryCard({required this.name, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RecipeListScreen(category: name)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Background image ────────────────────────────────────────────
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFFFF0E8),
                child: const Icon(Icons.restaurant_rounded,
                    color: _kOrange, size: 36),
              ),
            ),

            // ── Dark gradient overlay ───────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.60),
                  ],
                ),
              ),
            ),

            // ── Category name ───────────────────────────────────────────────
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  shadows: [
                    const Shadow(
                      color: Colors.black54,
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
