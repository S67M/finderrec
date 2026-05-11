import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'recipe_list_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  final List<Map<String, String>> categories = const [
   {'name': 'High Protein', 'image': 'https://images.unsplash.com/photo-1532550907401-a500c9a57435?w=500'},
    {'name': 'Gluten-Free', 'image': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500'},
    {'name': 'Seafood', 'image': 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=500'},
    {'name': 'Sandwiches', 'image': 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=500'},
    {'name': 'Soups', 'image': 'https://images.unsplash.com/photo-1476718406336-bb5a9690ee2a?w=500'},
    {'name': 'Salads', 'image': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=500'},
    {'name': 'Desserts', 'image': 'https://images.unsplash.com/photo-1551024601-bec78aea704b?w=500'},
    {'name': 'Juices', 'image': 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=500'},
    {'name': 'Others', 'image': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=500'},
  ];

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
          'Recipes',
          style: GoogleFonts.playfairDisplay(
            color: const Color(0xFF2D3142),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeListScreen(category: cat['name'])));
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: NetworkImage(cat['image']!), 
                  fit: BoxFit.cover, 
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.35), BlendMode.darken)
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                cat['name']!, 
                textAlign: TextAlign.center, 
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
              ),
            ),
          );
        },
      ),
    );
  }
}
