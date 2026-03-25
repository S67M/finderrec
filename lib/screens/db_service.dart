import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'recipe_model.dart';

class DBService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Recipe>> getAllRecipes() async {
    final snapshot = await _db.collection('recipes').get();
    return snapshot.docs.map((doc) => Recipe.fromMap(doc.id, doc.data())).toList();
  }

  Future<void> seedInitialRecipes() async {
    try {
      final snapshot = await _db.collection('recipes').limit(1).get();
      if (snapshot.docs.isNotEmpty) return; // already seeded

      final recipes = [
        {
          'name': 'Chocolate Cake',
          'ingredients': ['Flour', 'Sugar', 'Eggs', 'Butter', 'Cocoa', 'Milk'],
          'category': 'Desserts',
          'prepTime': 45,
          'instructions': 'Mix all ingredients in a bowl. Bake at 350F for 30-40 minutes.',
          'imageUrl': 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=600&q=80',
        },
        {
          'name': 'Gluten-Free Pancakes',
          'ingredients': ['Almond Flour', 'Eggs', 'Milk', 'Butter'],
          'category': 'Gluten-Free',
          'prepTime': 15,
          'instructions': 'Whisk almond flour, eggs, and milk. Cook small portions on a skillet until golden.',
          'imageUrl': 'https://images.unsplash.com/photo-1528641973685-236b3b2cb9d7?w=600&q=80',
        },
        {
          'name': 'Grilled Chicken Salad',
          'ingredients': ['Chicken', 'Lettuce', 'Tomato', 'Olive Oil', 'Salt'],
          'category': 'High Protein',
          'prepTime': 20,
          'instructions': 'Season chicken and grill. Chop lettuce and tomatoes, mix with sliced chicken and olive oil.',
          'imageUrl': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&q=80',
        },
        {
          'name': 'Green Detox Juice',
          'ingredients': ['Apple', 'Cucumber', 'Spinach', 'Lemon', 'Mint'],
          'category': 'Juices',
          'prepTime': 10,
          'instructions': 'Wash ingredients and blend until smooth. Serve chilled.',
          'imageUrl': 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=600&q=80',
        },
        {
          'name': 'Classic Cheeseburger',
          'ingredients': ['Beef', 'Cheese', 'Bread', 'Tomato', 'Onion', 'Lettuce'],
          'category': 'Fast Food',
          'prepTime': 20,
          'instructions': 'Grill beef patty. Toast the buns. Assemble with lettuce, tomato, patty, and cheese.',
          'imageUrl': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600&q=80',
        },
        {
          'name': 'Avocado Toast with Egg',
          'ingredients': ['Bread', 'Avocado', 'Salt', 'Eggs'],
          'category': 'Healthy Meals',
          'prepTime': 10,
          'instructions': 'Toast bread. Mash avocado with a pinch of salt. Top with a cooked egg.',
          'imageUrl': 'https://images.unsplash.com/photo-1541519227354-08fa5d50c44d?w=600&q=80',
        }
      ];

      for (var recipe in recipes) {
        await _db.collection('recipes').add(recipe);
      }
    } catch (e) {
      print("Error seeding database: $e");
    }
  }

  Future<void> toggleFavorite(String recipeId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = _db.collection('users').doc(uid);
    final snapshot = await doc.get();
    
    if (!snapshot.exists) {
      await doc.set({'favorites': [recipeId]});
    } else {
      List favs = snapshot.data()?['favorites'] ?? [];
      if (favs.contains(recipeId)) {
        favs.remove(recipeId);
      } else {
        favs.add(recipeId);
      }
      await doc.update({'favorites': favs});
    }
  }

  Stream<List<String>> getFavorites() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value([]);
    return _db.collection('users').doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return [];
      return List<String>.from(snapshot.data()?['favorites'] ?? []);
    });
  }
}
