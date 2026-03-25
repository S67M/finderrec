import 'package:flutter/material.dart';
import 'recipe_list_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  final List<Map<String, String>> categories = const [
    {'name': 'Desserts', 'image': 'https://images.unsplash.com/photo-1551024506-0bccd828d307?w=500'},
    {'name': 'Gluten-Free', 'image': 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=500'},
    {'name': 'High Protein', 'image': 'https://images.unsplash.com/photo-1544025162-d76694265947?w=500'},
    {'name': 'Juices', 'image': 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=500'},
    {'name': 'Fast Food', 'image': 'https://images.unsplash.com/photo-1561758033-d89a9ad46330?w=500'},
    {'name': 'Healthy Meals', 'image': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
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
