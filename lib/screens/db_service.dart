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
      // Skip if the collection already has all 15 new recipes
      final snapshot = await _db.collection('recipes').get();
      if (snapshot.docs.length >= 15) return;

      // Clear any old/partial seeds first
      final batch = _db.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // ── 15 sample recipes ──────────────────────────────────────────────────
      final recipes = [
        {
          'name': 'Chicken Tomato Stew',
          'category': 'Healthy Meals',
          'ingredients': ['Chicken', 'Tomato', 'Onion', 'Garlic', 'Pepper', 'Salt', 'Oil'],
          'prepTime': 40,
          'instructions': 'Heat oil in a pot. Sauté onion and garlic until soft. Add chicken pieces and brown on all sides. Stir in diced tomatoes, pepper, and salt. Cover and simmer for 30 minutes until chicken is tender.',
          'imageUrl': 'https://images.unsplash.com/photo-1604909052743-94e838986d24?w=600&q=80',
        },
        {
          'name': 'Beef Rice Bowl',
          'category': 'High Protein',
          'ingredients': ['Beef', 'Rice', 'Onion', 'Soy Sauce', 'Garlic', 'Ginger', 'Oil'],
          'prepTime': 35,
          'instructions': 'Cook rice according to package instructions. In a pan, heat oil and stir-fry onion, garlic and ginger. Add sliced beef and cook until browned. Add soy sauce and stir well. Serve over rice.',
          'imageUrl': 'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=600&q=80',
        },
        {
          'name': 'Pasta Tomato Sauce',
          'category': 'Fast Food',
          'ingredients': ['Pasta', 'Tomato Sauce', 'Cheese', 'Garlic', 'Basil', 'Salt', 'Oil'],
          'prepTime': 20,
          'instructions': 'Boil pasta in salted water until al dente. In a pan, heat oil and sauté garlic for 1 minute. Add tomato sauce and basil and simmer for 5 minutes. Toss with drained pasta and top with cheese.',
          'imageUrl': 'https://images.unsplash.com/photo-1621996346565-e3dbc353d2ac?w=600&q=80',
        },
        {
          'name': 'Salmon Lemon Herbs',
          'category': 'Healthy Meals',
          'ingredients': ['Salmon', 'Lemon', 'Parsley', 'Garlic', 'Butter', 'Salt'],
          'prepTime': 25,
          'instructions': 'Preheat oven to 400°F. Place salmon on a lined baking sheet. Melt butter with garlic and pour over salmon. Season with salt and lemon juice. Top with parsley and bake for 15–18 minutes until flaky.',
          'imageUrl': 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=600&q=80',
        },
        {
          'name': 'Vegetable Omelette',
          'category': 'Fast Food',
          'ingredients': ['Egg', 'Tomato', 'Onion', 'Pepper', 'Cheese', 'Salt', 'Butter'],
          'prepTime': 10,
          'instructions': 'Beat eggs with salt. Melt butter in a non-stick pan and sauté diced onion, tomato and pepper for 2 minutes. Pour in the eggs and cook until edges set. Add cheese and fold the omelette. Serve immediately.',
          'imageUrl': 'https://images.unsplash.com/photo-1510693206972-df098062cb71?w=600&q=80',
        },
        {
          'name': 'Banana Strawberry Smoothie',
          'category': 'Juices',
          'ingredients': ['Banana', 'Strawberry', 'Milk', 'Honey'],
          'prepTime': 5,
          'instructions': 'Peel and slice banana. Wash strawberries. Add banana, strawberries, milk and honey to a blender. Blend on high for 60 seconds until smooth and creamy. Pour and serve chilled.',
          'imageUrl': 'https://images.unsplash.com/photo-1553530666-ba11a7da3888?w=600&q=80',
        },
        {
          'name': 'Chocolate Cake',
          'category': 'Desserts',
          'ingredients': ['Flour', 'Sugar', 'Butter', 'Egg', 'Milk', 'Cinnamon'],
          'prepTime': 60,
          'instructions': 'Preheat oven to 350°F. Cream butter and sugar together. Beat in eggs one by one. Sift in flour and cinnamon, alternating with milk. Pour into a greased tin and bake for 35–40 minutes. Cool before serving.',
          'imageUrl': 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=600&q=80',
        },
        {
          'name': 'Tuna Pasta Salad',
          'category': 'Fast Food',
          'ingredients': ['Tuna', 'Pasta', 'Cucumber', 'Tomato', 'Mayonnaise', 'Lemon', 'Salt'],
          'prepTime': 15,
          'instructions': 'Cook pasta and rinse under cold water. Drain tuna. Dice cucumber and tomato. Combine pasta, tuna, cucumber, and tomato in a large bowl. Mix in mayonnaise and lemon juice. Season with salt and refrigerate 5 minutes.',
          'imageUrl': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&q=80',
        },
        {
          'name': 'Lentil Soup',
          'category': 'Healthy Meals',
          'ingredients': ['Lentils', 'Onion', 'Tomato', 'Cumin', 'Turmeric', 'Garlic', 'Oil', 'Salt'],
          'prepTime': 45,
          'instructions': 'Heat oil in a pot and sauté onion and garlic until golden. Add cumin and turmeric and stir for 1 minute. Add rinsed lentils, diced tomato, and 4 cups water. Season with salt. Bring to a boil, then simmer 35 minutes until lentils are soft.',
          'imageUrl': 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=600&q=80',
        },
        {
          'name': 'Mango Avocado Salad',
          'category': 'Healthy Meals',
          'ingredients': ['Mango', 'Avocado', 'Lemon', 'Honey', 'Mint', 'Salt'],
          'prepTime': 10,
          'instructions': 'Dice mango and avocado into cubes. Whisk together lemon juice, honey, and a pinch of salt as dressing. Gently toss mango and avocado with dressing. Garnish with fresh mint leaves and serve immediately.',
          'imageUrl': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600&q=80',
        },
        {
          'name': 'Shrimp Garlic Pasta',
          'category': 'Fast Food',
          'ingredients': ['Shrimp', 'Pasta', 'Garlic', 'Butter', 'Parsley', 'Lemon', 'Salt'],
          'prepTime': 20,
          'instructions': 'Cook pasta in salted boiling water. In a pan, melt butter and sauté garlic for 1 minute. Add shrimp and cook 2–3 minutes per side until pink. Squeeze lemon juice over shrimp. Toss with drained pasta and garnish with parsley.',
          'imageUrl': 'https://images.unsplash.com/photo-1563379926898-05f4575a45d8?w=600&q=80',
        },
        {
          'name': 'Chicken Rice Curry',
          'category': 'High Protein',
          'ingredients': ['Chicken', 'Rice', 'Onion', 'Tomato', 'Turmeric', 'Cumin', 'Paprika', 'Garlic', 'Oil'],
          'prepTime': 50,
          'instructions': 'Heat oil and fry onion and garlic until golden. Add cumin, turmeric and paprika and stir for 30 seconds. Add chicken pieces and cook until sealed. Stir in diced tomato and 1 cup water. Simmer 30 minutes. Cook rice separately and serve curry on top.',
          'imageUrl': 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=600&q=80',
        },
        {
          'name': 'French Toast',
          'category': 'Desserts',
          'ingredients': ['Bread', 'Egg', 'Milk', 'Butter', 'Sugar', 'Cinnamon'],
          'prepTime': 15,
          'instructions': 'Whisk eggs, milk, sugar, and cinnamon together in a bowl. Dip bread slices in the egg mixture, coating both sides. Melt butter in a hot pan. Cook bread 2–3 minutes per side until golden brown. Serve with extra sugar or fruit.',
          'imageUrl': 'https://images.unsplash.com/photo-1484723091739-30a097e8f929?w=600&q=80',
        },
        {
          'name': 'Beef Vegetable Soup',
          'category': 'Healthy Meals',
          'ingredients': ['Beef', 'Potato', 'Carrot', 'Onion', 'Tomato', 'Garlic', 'Salt', 'Pepper'],
          'prepTime': 60,
          'instructions': 'Cut beef into cubes and brown in a pot. Add diced onion and garlic and cook 2 minutes. Add chopped tomato, potato, and carrot with 5 cups water. Season with salt and pepper. Bring to a boil then simmer 45 minutes until beef and vegetables are tender.',
          'imageUrl': 'https://images.unsplash.com/photo-1607330289024-1535c6b4e1c1?w=600&q=80',
        },
        {
          'name': 'Tofu Stir Fry',
          'category': 'Gluten-Free',
          'ingredients': ['Tofu', 'Broccoli', 'Pepper', 'Soy Sauce', 'Ginger', 'Garlic', 'Oil'],
          'prepTime': 20,
          'instructions': 'Press and cube tofu. Heat oil in a wok and fry tofu until golden. Remove and set aside. In the same wok, stir-fry garlic, ginger, broccoli, and sliced pepper for 3 minutes. Return tofu and add soy sauce. Toss everything together and serve hot.',
          'imageUrl': 'https://images.unsplash.com/photo-1543339308-43e59d6b73a6?w=600&q=80',
        },
      ];

      final addBatch = _db.batch();
      for (final recipe in recipes) {
        final ref = _db.collection('recipes').doc();
        addBatch.set(ref, recipe);
      }
      await addBatch.commit();

      print('✅ Seeded 15 recipes to Firestore.');
    } catch (e) {
      print('Error seeding database: $e');
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
