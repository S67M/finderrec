import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'add_recipe_screen.dart';
import 'recipe_model.dart';

const _kOrange = Color(0xFFF4631E);
const _kBg = Color(0xFFFFF8F3);
const _kDark = Color(0xFF2D3142);
const _kGrey = Color(0xFF9E9E9E);

class MyrecipesScreen extends StatefulWidget {
  const MyrecipesScreen({super.key});

  @override
  State<MyrecipesScreen> createState() => _MyrecipesScreenState();
}

class _MyrecipesScreenState extends State<MyrecipesScreen> {
  List<Recipe> _recipes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyRecipes();
  }

  Future<void> _fetchMyRecipes() async {
    setState(() => _loading = true);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('recipes')
          .where('uid', isEqualTo: uid)
          .get();

      final recipes = snapshot.docs
          .map((doc) => Recipe.fromMap(doc.id, doc.data()))
          .toList();

      if (mounted) {
        setState(() {
          _recipes = recipes;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _navigateToAddRecipe() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddRecipeScreen()),
    );
    // Refresh list after returning from add screen
    _fetchMyRecipes();
  }

  Future<void> _deleteRecipe(Recipe recipe) async {
    // Only allow deletion of user-owned recipes
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFFF8F3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Delete Recipe?',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2D3142),
            fontSize: 18,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${recipe.name}"? This cannot be undone.',
          style: GoogleFonts.dmSans(
            color: const Color(0xFF2D3142),
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.dmSans(
                color: const Color(0xFF9E9E9E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await FirebaseFirestore.instance
          .collection('recipes')
          .doc(recipe.id)
          .delete();
      _fetchMyRecipes();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete recipe: $e',
              style: GoogleFonts.dmSans(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFE53935),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: _kBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kOrange),
        title: Text(
          'My Recipes',
          style: GoogleFonts.playfairDisplay(
            color: _kDark,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddRecipe,
        backgroundColor: _kOrange,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Add Recipe',
          style: GoogleFonts.dmSans(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _kOrange))
          : _recipes.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  color: _kOrange,
                  onRefresh: _fetchMyRecipes,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    itemCount: _recipes.length,
                    separatorBuilder: (ctx, idx) => const SizedBox(height: 20),
                    itemBuilder: (_, index) => _MyRecipeCard(
                      recipe: _recipes[index],
                      onDelete: () => _deleteRecipe(_recipes[index]),
                    ),
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0E8),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFF0E8E0), width: 2),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                size: 48,
                color: _kOrange,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No recipes yet',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: _kDark,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Recipes you add will appear here. Tap the button below to create your first one!',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: _kGrey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _navigateToAddRecipe,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kOrange,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
              ),
              icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
              label: Text(
                'Add Your First Recipe',
                style: GoogleFonts.dmSans(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
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

// ── Card — matches RecipeCard style in recipe_list_screen.dart ────────────────

class _MyRecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onDelete;

  const _MyRecipeCard({required this.recipe, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isLocalFile = recipe.imageUrl.isNotEmpty &&
        !recipe.imageUrl.startsWith('http') &&
        !recipe.imageUrl.startsWith('https');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Image ─────────────────────────────────────────────────────────
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: _buildImage(isLocalFile),
              ),
              // "My Recipe" badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _kOrange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.person_rounded, color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        'My Recipe',
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Delete icon — top right
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFFE53935),
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Details ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recipe name
                Text(
                  recipe.name,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _kDark,
                  ),
                ),
                const SizedBox(height: 10),

                // Timer + Category row
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 18, color: _kOrange),
                    const SizedBox(width: 4),
                    Text(
                      '${recipe.prepTime} mins',
                      style: GoogleFonts.dmSans(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Icon(Icons.category_outlined, size: 18, color: _kOrange),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        recipe.category,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSans(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Ingredients label
                Text(
                  'Ingredients',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _kDark,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: recipe.ingredients.map((ing) => Chip(
                    label: Text(
                      ing,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: _kDark,
                      ),
                    ),
                    backgroundColor: _kOrange.withValues(alpha: 0.1),
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )).toList(),
                ),

                if (recipe.instructions.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    'Instructions',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _kDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    recipe.instructions,
                    style: GoogleFonts.dmSans(
                      color: Colors.black54,
                      height: 1.5,
                      fontSize: 13,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(bool isLocalFile) {
    if (recipe.imageUrl.isEmpty) return _placeholder();

    if (isLocalFile) {
      return Image.file(
        File(recipe.imageUrl),
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, st) => _placeholder(),
      );
    }

    return Image.network(
      recipe.imageUrl,
      height: 180,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (ctx, err, st) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      height: 180,
      color: const Color(0xFFFFF0E8),
      child: const Center(
        child: Icon(Icons.restaurant_rounded, color: _kOrange, size: 50),
      ),
    );
  }
}