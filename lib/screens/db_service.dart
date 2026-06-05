import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'recipe_model.dart';

// A service class that handles all Firebase Firestore database operations.
// This exists to abstract recipe retrieval, custom ingredients creation, 
// seeding initial data, and tracking favorite recipes for users.
class DBService {
  // Instance of FirebaseFirestore to interact with the database collections.
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Retrieves all recipes from the 'recipes' collection in Firestore.
  // This exists to fetch the complete set of system and user recipes.
  // Returns: A Future resolving to a list of Recipe objects.
  Future<List<Recipe>> getAllRecipes() async {
    // Query the 'recipes' collection from Firestore
    final snapshot = await _db.collection('recipes').get();
    // Map each document snapshot to a Recipe instance
    return snapshot.docs.map((doc) => Recipe.fromMap(doc.id, doc.data())).toList();
  }

  // Returns public recipes (no uid or empty uid) along with the current user's own recipes.
  // Used by the ingredient search screen so users can find system recipes as well as their own custom recipes.
  // Returns: A Future resolving to a filtered list of Recipe objects.
  Future<List<Recipe>> getAllRecipesForUser(String uid) async {
    // Fetch all recipes from Firestore first
    final snapshot = await _db.collection('recipes').get();
    // Filter the records on client-side to find public or user-specific recipes
    return snapshot.docs
        .where((doc) {
          final data = doc.data();
          // Public: no uid field, or uid is null/empty
          final docUid = data['uid'];
          final isPublic = docUid == null || (docUid is String && docUid.isEmpty);
          // Or belongs to the current user
          final isOwn = docUid == uid;
          return isPublic || isOwn;
        })
        .map((doc) => Recipe.fromMap(doc.id, doc.data()))
        .toList();
  }

  // Deletes a recipe document by its Firestore document ID.
  // This exists to allow users to remove recipes they have created.
  // Modifies: Deletes the corresponding document in the 'recipes' Firestore collection.
  // Returns: Future<void> representing the asynchronous delete operation.
  Future<void> deleteRecipe(String recipeId) async {
    // Target the specific recipe document by ID and trigger deletion
    await _db.collection('recipes').doc(recipeId).delete();
  }


  // Seeds default recipes into Firestore if the database has fewer than 30 canonical recipes.
  // This exists to prepopulate the database with sample recipes for the search feature on new installs.
  // Modifies: Writes multiple default recipes to Firestore 'recipes' collection and deletes stale system recipes.
  // Returns: Future<void> representing the asynchronous seed operation.
  Future<void> seedInitialRecipes() async {
    try {
      // Re-seed whenever we have fewer than 30 canonical (non-user) recipes
      final allSnapshot = await _db.collection('recipes').get();
      final systemRecipes = allSnapshot.docs
          .where((d) => d.data()['isUserRecipe'] != true)
          .toList();

      // Skip seeding if we already have sufficient system-seeded recipes
      if (systemRecipes.length >= 30) return;

      // Delete old system recipes to prevent duplicate accumulation
      final batch = _db.batch();
      for (final doc in systemRecipes) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // ── 24 recipes across 8 categories (3 per category) ────────────────────
      // Covers all 67 ingredients:
      // Basics       : Oil, Salt, Sugar, Garlic
      // Grains&Carbs : Rice, Pasta, Bread, Flour
      // Dairy&Fats   : Milk, Butter, Cheese
      // Proteins     : Chicken, Beef, Fish, Turkey, Egg, Shrimp, Tuna, Salmon,
      //                Lentils, Beans, Tofu
      // Vegetables   : Potato, Onion, Tomato, Carrot, Broccoli, Cucumber,
      //                Spinach, Pepper, Zucchini, Eggplant, Cabbage, Corn
      // Fruits       : Apple, Banana, Orange, Lemon, Strawberry, Mango,
      //                Pineapple, Grapes, Peach, Avocado
      // Herbs        : Parsley, Cilantro, Basil, Mint, Oregano, Thyme,
      //                Rosemary, Dill
      // Spices       : Black Pepper, Paprika, Turmeric, Cumin, Cinnamon,
      //                Chili Powder, Ginger, Garlic Powder
      // Pantry       : Tomato Sauce, Soy Sauce, Vinegar, Honey, Mustard,
      //                Mayonnaise, Ketchup
      final recipes = [

        // ── HIGH PROTEIN (3) ────────────────────────────────────────────────
        {
          'name': 'Grilled Chicken & Rice Bowl',
          'category': 'High Protein',
          'ingredients': ['Chicken', 'Rice', 'Garlic', 'Oil', 'Salt', 'Black Pepper', 'Paprika', 'Lemon', 'Parsley'],
          'prepTime': 35,
          'instructions': 'Season chicken with paprika, garlic powder, salt and black pepper. Grill on medium-high 6–7 min per side. Rest 5 min then slice. Cook rice. Squeeze lemon over chicken. Serve over rice, garnished with parsley.',
          'imageUrl': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&q=80',
        },
        {
          'name': 'Beef & Egg Protein Skillet',
          'category': 'High Protein',
          'ingredients': ['Beef', 'Egg', 'Onion', 'Pepper', 'Garlic', 'Oil', 'Salt', 'Cumin', 'Chili Powder'],
          'prepTime': 25,
          'instructions': 'Brown beef in oil over high heat. Add diced onion, garlic and pepper; cook 3 min. Season with cumin, chili powder and salt. Make wells in the pan and crack in eggs. Cover and cook until eggs set. Serve hot.',
          'imageUrl': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600&q=80',
        },
        {
          'name': 'Turkey & Lentil Power Bowl',
          'category': 'High Protein',
          'ingredients': ['Turkey', 'Lentils', 'Spinach', 'Tomato', 'Garlic', 'Oil', 'Salt', 'Turmeric', 'Cumin', 'Cilantro'],
          'prepTime': 45,
          'instructions': 'Simmer lentils in water with turmeric and salt for 25 min. In a skillet, cook ground turkey in oil with garlic, cumin and salt until done. Wilt spinach in the pan. Layer lentils, turkey mixture and diced tomato. Top with cilantro.',
          'imageUrl': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600&q=80',
        },

        // ── GLUTEN-FREE (3) ─────────────────────────────────────────────────
        {
          'name': 'Tofu Broccoli Stir-Fry',
          'category': 'Gluten-Free',
          'ingredients': ['Tofu', 'Broccoli', 'Carrot', 'Pasta', 'Garlic', 'Ginger', 'Soy Sauce', 'Oil', 'Salt'],
          'prepTime': 20,
          'instructions': 'Cook pasta and set aside. Press and cube tofu; fry in oil until golden and set aside. Stir-fry garlic and ginger 30 sec. Add broccoli, carrot and pasta; stir-fry 4 min. Return tofu, pour in soy sauce and toss. Season with salt and serve immediately.',
          'imageUrl': 'https://images.unsplash.com/photo-1543339308-43e59d6b73a6?w=600&q=80',
        },
        {
          'name': 'Salmon & Avocado Bowl',
          'category': 'Gluten-Free',
          'ingredients': ['Salmon', 'Avocado', 'Cucumber', 'Lemon', 'Salt', 'Black Pepper', 'Dill', 'Oil', 'Vinegar'],
          'prepTime': 20,
          'instructions': 'Season salmon with salt, black pepper and dill. Sear in oil 4 min per side. Slice avocado and cucumber. Dress with lemon juice and a splash of vinegar. Plate salmon with avocado and cucumber on the side.',
          'imageUrl': 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=600&q=80',
        },
        {
          'name': 'Beans & Corn Veggie Chili',
          'category': 'Gluten-Free',
          'ingredients': ['Beans', 'Corn', 'Tomato', 'Onion', 'Zucchini', 'Garlic', 'Pepper', 'Oil', 'Cumin', 'Chili Powder', 'Salt', 'Cilantro'],
          'prepTime': 35,
          'instructions': 'Sauté onion, garlic, pepper and diced zucchini in oil until soft. Add drained beans, corn, diced tomato, cumin and chili powder. Add 1 cup water and simmer 20 min. Season with salt. Garnish with cilantro before serving.',
          'imageUrl': 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=600&q=80',
        },

        // ── SANDWICHES (3) ──────────────────────────────────────────────────
        {
          'name': 'Classic Club Sandwich',
          'category': 'Sandwiches',
          'ingredients': ['Bread', 'Chicken', 'Tomato', 'Cucumber', 'Cheese', 'Mayonnaise', 'Mustard', 'Ketchup', 'Salt', 'Black Pepper'],
          'prepTime': 15,
          'instructions': 'Toast bread slices. Spread mayonnaise, mustard and a drizzle of ketchup on one side. Layer sliced chicken, tomato, cucumber and cheese. Season with salt and black pepper. Close sandwich and cut diagonally. Serve immediately.',
          'imageUrl': 'https://images.unsplash.com/photo-1484723091739-30a097e8f929?w=600&q=80',
        },
        {
          'name': 'Tuna Melt Sandwich',
          'category': 'Sandwiches',
          'ingredients': ['Tuna', 'Bread', 'Cheese', 'Onion', 'Mayonnaise', 'Mustard', 'Lemon', 'Salt', 'Black Pepper', 'Butter'],
          'prepTime': 15,
          'instructions': 'Mix drained tuna with mayonnaise, mustard, finely diced onion, lemon juice, salt and pepper. Butter the outside of bread slices. Fill with tuna mix and cheese. Grill in a pan until cheese melts and bread is golden.',
          'imageUrl': 'https://images.unsplash.com/photo-1539252554453-80ab65ce3586?w=600&q=80',
        },
        {
          'name': 'Avocado & Egg Breakfast Sandwich',
          'category': 'Sandwiches',
          'ingredients': ['Bread', 'Egg', 'Avocado', 'Tomato', 'Spinach', 'Salt', 'Black Pepper', 'Chili Powder', 'Butter'],
          'prepTime': 12,
          'instructions': 'Toast bread and spread mashed avocado seasoned with salt and chili powder. Fry egg in butter sunny-side-up. Layer spinach, egg and sliced tomato on the avocado toast. Season with salt and black pepper. Serve open-faced or closed.',
          'imageUrl': 'https://images.unsplash.com/photo-1525351484163-7529414344d8?w=600&q=80',
        },

        // ── SOUPS (3) ───────────────────────────────────────────────────────
        {
          'name': 'Creamy Tomato Basil Soup',
          'category': 'Soups',
          'ingredients': ['Tomato', 'Tomato Sauce', 'Onion', 'Garlic', 'Butter', 'Milk', 'Salt', 'Black Pepper', 'Basil', 'Sugar', 'Oil'],
          'prepTime': 30,
          'instructions': 'Sauté onion and garlic in butter and oil until soft. Add chopped tomatoes and tomato sauce; stir in sugar, salt and black pepper. Simmer 15 min. Blend until smooth. Stir in milk and fresh basil. Warm through and serve.',
          'imageUrl': 'https://images.unsplash.com/photo-1507048331197-7d4ac70811cf?w=600&q=80',
        },
        {
          'name': 'Lentil & Carrot Soup',
          'category': 'Soups',
          'ingredients': ['Lentils', 'Carrot', 'Potato', 'Onion', 'Garlic', 'Cumin', 'Turmeric', 'Salt', 'Oil', 'Lemon', 'Cilantro'],
          'prepTime': 40,
          'instructions': 'Sauté onion and garlic in oil. Add cumin and turmeric; stir 30 sec. Add lentils, diced carrot, potato and 5 cups water. Season with salt. Boil then simmer 30 min. Squeeze lemon juice. Blend partially if desired. Garnish with cilantro.',
          'imageUrl': 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=600&q=80',
        },
        {
          'name': 'Chicken & Corn Chowder',
          'category': 'Soups',
          'ingredients': ['Chicken', 'Corn', 'Potato', 'Onion', 'Milk', 'Butter', 'Salt', 'Black Pepper', 'Thyme', 'Garlic', 'Flour'],
          'prepTime': 40,
          'instructions': 'Cook chicken in water; shred and reserve broth. Sauté onion and garlic in butter. Add flour and stir 1 min. Pour in broth and milk gradually. Add potato, corn, thyme, salt and pepper. Simmer 20 min until potato is soft. Stir in chicken.',
          'imageUrl': 'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=600&q=80',
        },

        // ── SALADS (3) ──────────────────────────────────────────────────────
        {
          'name': 'Greek-Style Salad',
          'category': 'Salads',
          'ingredients': ['Tomato', 'Cucumber', 'Onion', 'Eggplant', 'Cheese', 'Pepper', 'Oregano', 'Salt', 'Oil', 'Vinegar', 'Black Pepper'],
          'prepTime': 15,
          'instructions': 'Slice eggplant, brush with oil and grill 2 min per side. Chop tomatoes, cucumber and onion into chunks. Slice pepper into rings. Arrange all vegetables on a plate. Crumble cheese on top. Whisk oil, vinegar, oregano, salt and black pepper for dressing. Drizzle over salad and serve.',
          'imageUrl': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600&q=80',
        },
        {
          'name': 'Mango & Cabbage Slaw',
          'category': 'Salads',
          'ingredients': ['Mango', 'Cabbage', 'Carrot', 'Cilantro', 'Lemon', 'Honey', 'Vinegar', 'Salt', 'Chili Powder'],
          'prepTime': 15,
          'instructions': 'Shred cabbage and grate carrot. Dice mango. Whisk lemon juice, honey, vinegar, chili powder and salt for dressing. Toss cabbage, carrot and mango with dressing. Fold in cilantro. Chill 10 min before serving.',
          'imageUrl': 'https://images.unsplash.com/photo-1505253716362-afaea1d3d1af?w=600&q=80',
        },
        {
          'name': 'Spinach, Peach & Walnut Salad',
          'category': 'Salads',
          'ingredients': ['Spinach', 'Peach', 'Avocado', 'Lemon', 'Oil', 'Honey', 'Salt', 'Black Pepper', 'Rosemary'],
          'prepTime': 10,
          'instructions': 'Wash and dry spinach. Slice peach and avocado. Whisk lemon juice, oil, honey, salt and black pepper for dressing. Toss spinach with dressing. Top with peach and avocado slices. Sprinkle chopped rosemary and serve.',
          'imageUrl': 'https://images.unsplash.com/photo-1551248429-40975aa4de74?w=600&q=80',
        },

        // ── DESSERTS (3) ────────────────────────────────────────────────────
        {
          'name': 'Banana Walnut Bread',
          'category': 'Desserts',
          'ingredients': ['Banana', 'Flour', 'Egg', 'Butter', 'Sugar', 'Milk', 'Cinnamon', 'Salt'],
          'prepTime': 65,
          'instructions': 'Preheat oven to 175°C. Mash bananas. Cream butter and sugar. Beat in eggs, then banana and milk. Fold in flour, cinnamon and salt until just combined. Pour into greased loaf tin. Bake 55–60 min until a skewer comes out clean.',
          'imageUrl': 'https://images.unsplash.com/photo-1574085733277-851d9d856a3a?w=600&q=80',
        },
        {
          'name': 'Strawberry Panna Cotta',
          'category': 'Desserts',
          'ingredients': ['Strawberry', 'Milk', 'Sugar', 'Honey', 'Lemon', 'Mint', 'Butter'],
          'prepTime': 20,
          'instructions': 'Warm milk with sugar, honey and a knob of butter until sugar dissolves; do not boil. Remove from heat, add lemon zest. Pour into cups and chill 4 hours. Hull and slice strawberries; macerate with a little sugar and lemon juice. Serve panna cotta topped with strawberries and fresh mint.',
          'imageUrl': 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=600&q=80',
        },
        {
          'name': 'Apple Cinnamon Crumble',
          'category': 'Desserts',
          'ingredients': ['Apple', 'Flour', 'Butter', 'Sugar', 'Cinnamon', 'Salt', 'Orange'],
          'prepTime': 45,
          'instructions': 'Preheat oven to 180°C. Peel and slice apples; toss with sugar, cinnamon and orange zest. Place in baking dish. Rub butter into flour with sugar and a pinch of salt until crumbly. Spread over apples. Bake 30–35 min until golden and bubbling.',
          'imageUrl': 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=600&q=80',
        },

        // ── JUICES (3) ──────────────────────────────────────────────────────
        {
          'name': 'Tropical Mango Pineapple Smoothie',
          'category': 'Juices',
          'ingredients': ['Mango', 'Pineapple', 'Banana', 'Orange', 'Honey', 'Milk', 'Ginger'],
          'prepTime': 5,
          'instructions': 'Peel and chop mango, pineapple and banana. Squeeze orange juice. Add all fruit, orange juice, milk, honey and a small piece of ginger to blender. Blend until completely smooth. Pour over ice and serve immediately.',
          'imageUrl': 'https://images.unsplash.com/photo-1553530666-ba11a7da3888?w=600&q=80',
        },
        {
          'name': 'Berry Blast Smoothie',
          'category': 'Juices',
          'ingredients': ['Strawberry', 'Grapes', 'Banana', 'Milk', 'Honey', 'Lemon', 'Mint'],
          'prepTime': 5,
          'instructions': 'Wash strawberries and grapes. Peel banana. Add all fruit to blender with milk, honey and a squeeze of lemon juice. Blend on high until silky smooth. Pour into glasses and garnish with a sprig of mint.',
          'imageUrl': 'https://images.unsplash.com/photo-1623065422902-30a2d299bbe4?w=600&q=80',
        },
        {
          'name': 'Green Detox Juice',
          'category': 'Juices',
          'ingredients': ['Spinach', 'Cucumber', 'Apple', 'Lemon', 'Ginger', 'Mint', 'Honey'],
          'prepTime': 5,
          'instructions': 'Wash all produce. Chop cucumber and apple. Juice or blend spinach, cucumber, apple and ginger with ½ cup water. Strain through a fine sieve. Stir in lemon juice, honey and fresh mint leaves. Serve over ice.',
          'imageUrl': 'https://images.unsplash.com/photo-1610970881699-44a5587cabec?w=600&q=80',
        },

        // ── SEAFOOD (3) ─────────────────────────────────────────────────────
        {
          'name': 'Garlic Butter Shrimp',
          'category': 'Seafood',
          'ingredients': ['Shrimp', 'Butter', 'Garlic', 'Lemon', 'Parsley', 'Salt', 'Black Pepper', 'Chili Powder', 'Oil'],
          'prepTime': 15,
          'instructions': 'Pat shrimp dry. Season with salt, black pepper and chili powder. Heat oil and butter in a pan over high heat. Add garlic and sauté 30 sec. Add shrimp; cook 1–2 min per side until pink. Squeeze lemon juice and toss with parsley. Serve hot.',
          'imageUrl': 'https://images.unsplash.com/photo-1563379926898-05f4575a45d8?w=600&q=80',
        },
        {
          'name': 'Pan-Seared Salmon with Dill',
          'category': 'Seafood',
          'ingredients': ['Salmon', 'Butter', 'Garlic', 'Dill', 'Lemon', 'Salt', 'Black Pepper', 'Oil', 'Thyme'],
          'prepTime': 20,
          'instructions': 'Season salmon fillets with salt and black pepper. Heat oil in a pan over medium-high. Sear salmon skin-side up 4 min; flip and add butter, garlic and thyme. Baste 3 min. Squeeze lemon and finish with fresh dill.',
          'imageUrl': 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=600&q=80',
        },
        {
          'name': 'Fish Tacos with Slaw',
          'category': 'Seafood',
          'ingredients': ['Fish', 'Cabbage', 'Tomato', 'Corn', 'Avocado', 'Lemon', 'Mayonnaise', 'Garlic Powder', 'Cumin', 'Salt', 'Paprika', 'Cilantro'],
          'prepTime': 25,
          'instructions': 'Season fish with garlic powder, cumin, paprika and salt. Pan-fry in oil 3–4 min per side. Shred cabbage; mix with mayonnaise, lemon juice and salt for slaw. Warm tortillas. Assemble with fish, slaw, diced tomato, corn, avocado slices and cilantro.',
          'imageUrl': 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=600&q=80',
        },

        // ── OTHERS (2) ──────────────────────────────────────────────────────
        {
          'name': 'Shakshuka (Eggs in Tomato Sauce)',
          'category': 'Others',
          'ingredients': ['Egg', 'Tomato Sauce', 'Tomato', 'Onion', 'Pepper', 'Garlic', 'Oil', 'Cumin', 'Paprika', 'Chili Powder', 'Salt', 'Parsley'],
          'prepTime': 25,
          'instructions': 'Heat oil in a wide pan. Sauté onion, garlic and pepper until soft. Add tomato sauce, diced tomato, cumin, paprika and chili powder. Simmer 10 min until sauce thickens. Make wells and crack in eggs. Cover and cook 5–7 min until whites are set but yolks are still runny. Garnish with parsley and serve with bread.',
          'imageUrl': 'https://images.unsplash.com/photo-1590412200988-a436970781fa?w=600&q=80',
        },
        {
          'name': 'Rainbow Buddha Bowl',
          'category': 'Others',
          'ingredients': ['Rice', 'Chickpeas', 'Cucumber', 'Carrot', 'Avocado', 'Spinach', 'Lemon', 'Tahini', 'Garlic', 'Soy Sauce', 'Honey', 'Sesame', 'Salt', 'Black Pepper'],
          'prepTime': 20,
          'instructions': 'Cook rice and let cool slightly. Roast chickpeas with salt and black pepper at 200°C for 15 min. Slice cucumber, carrot and avocado. Whisk lemon juice, tahini, garlic, soy sauce and honey for dressing. Arrange rice, chickpeas, cucumber, carrot, avocado and spinach in a bowl. Drizzle dressing over and serve.',
          'imageUrl': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600&q=80',
        },

        // ── TRADITIONAL (2) ─────────────────────────────────────────────────
        {
          'name': 'Lamb Tagine',
          'category': 'Traditional',
          'ingredients': ['Lamb', 'Potato', 'Carrot', 'Onion', 'Tomato', 'Garlic', 'Cumin', 'Paprika', 'Turmeric', 'Olive Oil', 'Salt'],
          'prepTime': 75,
          'instructions': '1. Cut lamb into chunks and season with cumin, paprika, turmeric, salt.\n2. Heat oil in a deep pot, brown the lamb on all sides.\n3. Add chopped onion and garlic, cook 3 minutes.\n4. Add diced tomatoes, carrots, and potatoes.\n5. Pour 1 cup of water, cover and simmer on low heat for 60 minutes.\n6. Serve hot with bread.',
          'imageUrl': 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=800',
        },
        {
          'name': 'Shakshuka',
          'category': 'Traditional',
          'ingredients': ['Egg', 'Tomato', 'Pepper', 'Onion', 'Garlic', 'Tomato Sauce', 'Cumin', 'Paprika', 'Chili Powder', 'Oil', 'Salt'],
          'prepTime': 25,
          'instructions': '1. Heat oil in a skillet over medium heat.\n2. Sauté diced onion, garlic, and peppers for 5 minutes.\n3. Add diced tomatoes and tomato sauce.\n4. Season with cumin, paprika, chili, and salt.\n5. Simmer sauce for 10 minutes.\n6. Make 4 wells in the sauce and crack an egg into each.\n7. Cover and cook 5–7 minutes until eggs are set.\n8. Serve with bread.',
          'imageUrl': 'https://images.unsplash.com/photo-1590412200988-a436970781fa?w=800',
        },

        // ── BREAKFAST (2) ────────────────────────────────────────────────────
        {
          'name': 'Fluffy Pancakes',
          'category': 'Breakfast',
          'ingredients': ['Flour', 'Egg', 'Milk', 'Butter', 'Sugar', 'Salt', 'Baking Powder'],
          'prepTime': 20,
          'instructions': '1. Mix flour, sugar, salt, and baking powder in a bowl.\n2. In another bowl, whisk egg, milk, and melted butter.\n3. Combine wet and dry ingredients — do not overmix, lumps are fine.\n4. Heat a non-stick pan on medium, add a little butter.\n5. Pour 1/4 cup batter per pancake.\n6. Cook until bubbles form (~2 min), flip and cook 1 more minute.\n7. Serve with honey or fresh fruit.',
          'imageUrl': 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=800',
        },
        {
          'name': 'Avocado Egg Toast',
          'category': 'Breakfast',
          'ingredients': ['Bread', 'Egg', 'Avocado', 'Lemon', 'Salt', 'Black Pepper', 'Chili Powder', 'Olive Oil'],
          'prepTime': 10,
          'instructions': '1. Toast 2 slices of bread until golden and crispy.\n2. Mash avocado with lemon juice, salt, and black pepper.\n3. Spread avocado mixture generously on each slice.\n4. Fry or poach eggs to your liking.\n5. Place egg on top of avocado toast.\n6. Sprinkle with chili powder and a drizzle of olive oil.\n7. Serve immediately.',
          'imageUrl': 'https://images.unsplash.com/photo-1482049016688-2d3e1b311543?w=800',
        },
      ];

      // Add all listed default recipes using a Firestore batch write operation
      final addBatch = _db.batch();
      for (final recipe in recipes) {
        final ref = _db.collection('recipes').doc();
        addBatch.set(ref, recipe);
      }
      await addBatch.commit();

      debugPrint('✅ Seeded 26 recipes to Firestore.');
    } catch (e) {
      debugPrint('Error seeding database: $e');
    }
  }


  // Toggles the favorite status of a recipe for the currently logged-in user.
  // This exists to let users save recipes they like to their profile's favorites list.
  // Modifies: Updates the user's document in the 'users' collection with the modified favorites list.
  // Returns: Future<void> representing the database update.
  Future<void> toggleFavorite(String recipeId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    // Return early if there is no logged-in user
    if (uid == null) return;
    
    final doc = _db.collection('users').doc(uid);
    final snapshot = await doc.get();
    
    // Create new favorites array if user document doesn't exist yet
    if (!snapshot.exists) {
      await doc.set({'favorites': [recipeId]});
    } else {
      List favs = snapshot.data()?['favorites'] ?? [];
      // If already liked, remove; otherwise, add to list
      if (favs.contains(recipeId)) {
        favs.remove(recipeId);
      } else {
        favs.add(recipeId);
      }
      // Update favorites list field in Firestore
      await doc.update({'favorites': favs});
    }
  }

  // Retrieves a real-time stream of the favorite recipe IDs for the currently logged-in user.
  // This exists to dynamically update favorite indicators and lists across the app interface.
  // Returns: A Stream emitting a list of favorite recipe ID strings.
  Stream<List<String>> getFavorites() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    // Return empty stream if no active authentication session
    if (uid == null) return Stream.value([]);
    
    // Listen to real-time changes in the user document and map the favorites field
    return _db.collection('users').doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return [];
      return List<String>.from(snapshot.data()?['favorites'] ?? []);
    });
  }

  // ── Custom Ingredients ─────────────────────────────────────────────────────

  // Saves a new custom ingredient to the global 'custom_ingredients' collection.
  // This exists to allow users to extend the preset list of ingredients.
  // Modifies: Creates a new document under 'custom_ingredients' in Firestore.
  // Returns: Future<void> representing the write operation.
  Future<void> addCustomIngredient(String name, String category) async {
    // Add the new ingredient to Firestore with a creation timestamp
    await _db.collection('custom_ingredients').add({
      'name': name.trim(),
      'category': category,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Provides a real-time stream of all custom ingredients sorted by creation time.
  // This exists to sync and display custom ingredients in the ingredient selection screen.
  // Returns: A Stream emitting a list of maps, where each map contains 'name' and 'category' keys.
  Stream<List<Map<String, String>>> getCustomIngredients() {
    // Return sorted real-time snapshots of the custom ingredients collection
    return _db
        .collection('custom_ingredients')
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = doc.data();
              return {
                'name':     data['name']     as String? ?? '',
                'category': data['category'] as String? ?? '',
              };
            })
            // Ensure only elements containing valid names and categories are returned
            .where((m) => m['name']!.isNotEmpty && m['category']!.isNotEmpty)
            .toList());
  }
}
