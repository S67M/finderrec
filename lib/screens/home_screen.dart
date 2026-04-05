import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'categories_screen.dart';
import 'recipe_list_screen.dart';
import 'fav_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  Set<String> selectedIngredients = {};

  final Map<String, List<String>> homeIngredients = {
    "🧂 Essentials": ["Oil","Salt","Sugar","Butter","Garlic","Flour","Rice","Pasta","Milk","Eggs","Bread","Cheese"],
    "🥩 Proteins": ["Chicken","Beef","Fish","Turkey","Egg","Shrimp","Tuna","Salmon","Lentils","Beans","Tofu"],
    "🥕 Vegetables": ["Potato","Onion","Tomato","Carrot","Broccoli","Cucumber","Spinach","Pepper","Zucchini","Eggplant","Cabbage","Corn"],
    "🍎 Fruits": ["Apple","Banana","Orange","Lemon","Strawberry","Mango","Pineapple","Grapes","Peach","Avocado"],
    "🌿 Herbs": ["Parsley","Cilantro","Basil","Mint","Oregano","Thyme","Rosemary","Dill"],
    "🌶 Spices": ["Black Pepper","Paprika","Turmeric","Cumin","Cinnamon","Chili Powder","Ginger","Garlic Powder"],
    "🥫 Pantry": ["Tomato Sauce","Soy Sauce","Vinegar","Honey","Mustard","Mayonnaise","Ketchup"]
  };

  void toggleIngredient(String ingredient) {
    setState(() {
      if (selectedIngredients.contains(ingredient)) {
        selectedIngredients.remove(ingredient);
      } else {
        selectedIngredients.add(ingredient);
      }
    });
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F3),
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset('assets/logo.png', height: 32)),
            const SizedBox(width: 12),
            const Text("Recipe Finder", style: TextStyle(color: Color(0xFF2D3142), fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFFFA559)), 
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
        backgroundColor: const Color(0xFFFFF9F3),
        elevation: 0,
      ),
      body: currentIndex == 0 ? _buildIngredientSelector() 
          : currentIndex == 1 ? const CategoriesScreen() 
          : const FavoritesScreen(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) => setState(() => currentIndex = index),
            selectedItemColor: const Color(0xFFFFA559),
            unselectedItemColor: Colors.black38,
            backgroundColor: const Color(0xFFFFFDFB),
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined), activeIcon: Icon(Icons.grid_view), label: "Categories"),
              BottomNavigationBarItem(icon: Icon(Icons.favorite_outline), activeIcon: Icon(Icons.favorite), label: "Favorites"),
            ],
          ),
        ),
      ),
      floatingActionButton: (currentIndex == 0 && selectedIngredients.length >= 3) 
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeListScreen(ingredients: selectedIngredients.toList())));
              },
              backgroundColor: const Color(0xFFFFA559),
              elevation: 4,
              icon: const Icon(Icons.search, color: Colors.white),
              label: Text("Find Recipes (${selectedIngredients.length})", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ) 
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildIngredientSelector() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text("What's in your kitchen?", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF2D3142))),
        const SizedBox(height: 8),
        const Text("Select ingredients to find matching recipes", style: TextStyle(fontSize: 16, color: Colors.black54)),
        const SizedBox(height: 24),
        Container(
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFA559).withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              )
            ],
            image: const DecorationImage(
              image: NetworkImage("https://images.unsplash.com/photo-1495521821757-a1efb6729352?auto=format&fit=crop&q=80&w=800"),
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
            child: const Text(
              "Featured Recipes\nof the Day",
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, height: 1.2),
            ),
          ),
        ),
        const SizedBox(height: 32),
        ...homeIngredients.entries.map((category) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.key,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D3142)),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 16,
                  children: category.value.map((ing) {
                    final isSelected = selectedIngredients.contains(ing);
                    return GestureDetector(
                      onTap: () => toggleIngredient(ing),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFFFA559) : const Color(0xFFFFFDFB),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: isSelected ? [
                            BoxShadow(color: const Color(0xFFFFA559).withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))
                          ] : [
                            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))
                          ],
                          border: isSelected ? Border.all(color: Colors.transparent) : Border.all(color: Colors.grey.shade200, width: 1.5),
                        ),
                        child: Text(
                          ing, 
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            color: isSelected ? Colors.white : const Color(0xFF2D3142),
                            fontSize: 15
                          )
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 80), // Padding for FAB
      ],
    );
  }
}
