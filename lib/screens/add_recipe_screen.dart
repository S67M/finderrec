import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const _kOrange = Color(0xFFF4631E);
const _kBg = Color(0xFFFFF8F3);

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _nameController = TextEditingController();
  final _durationController = TextEditingController();
  final _photoController = TextEditingController();
  final _instructionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedCategory = 'High Protein';
  final List<String> _categories = [
    'High Protein', 'Gluten-Free', 'Sandwiches',
    'Soups', 'Salads', 'Desserts', 'Juices', 'Seafood', 'Others',
  ];

  final List<String> _selectedIngredients = [];

  // Photo mode: 'url' or 'gallery'
  String _photoMode = 'url';
  File? _pickedImageFile;
  bool _isSaving = false;

  final Map<String, List<String>> _ingredientCategories = {
    "🫙 Basics": ["Oil", "Salt", "Sugar", "Garlic"],
    "🌾 Grains & Carbs": ["Rice", "Pasta", "Bread", "Flour"],
    "🧈 Dairy & Fats": ["Milk", "Butter", "Cheese"],
    "🥩 Proteins": ["Chicken", "Beef", "Fish", "Turkey", "Egg", "Shrimp", "Tuna", "Salmon", "Lentils", "Beans", "Tofu"],
    "🥕 Vegetables": ["Potato", "Onion", "Tomato", "Carrot", "Broccoli", "Cucumber", "Spinach", "Pepper", "Zucchini", "Eggplant", "Cabbage", "Corn"],
    "🍎 Fruits": ["Apple", "Banana", "Orange", "Lemon", "Strawberry", "Mango", "Pineapple", "Grapes", "Peach", "Avocado"],
    "🌿 Herbs": ["Parsley", "Cilantro", "Basil", "Mint", "Oregano", "Thyme", "Rosemary", "Dill"],
    "🌶 Spices": ["Black Pepper", "Paprika", "Turmeric", "Cumin", "Cinnamon", "Chili Powder", "Ginger", "Garlic Powder"],
    "🥫 Pantry": ["Tomato Sauce", "Soy Sauce", "Vinegar", "Honey", "Mustard", "Mayonnaise", "Ketchup"],
  };

  void _openIngredientPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _kBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.85,
              maxChildSize: 0.95,
              minChildSize: 0.5,
              builder: (_, scrollController) {
                return ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Pick Ingredients',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2D3142),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_selectedIngredients.length} selected',
                      style: GoogleFonts.dmSans(fontSize: 13, color: Colors.black45),
                    ),
                    const SizedBox(height: 20),
                    ..._ingredientCategories.entries.map((category) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.key,
                              style: GoogleFonts.dmSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2D3142),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 10,
                              children: category.value.map((ing) {
                                final isSelected = _selectedIngredients.contains(ing);
                                return GestureDetector(
                                  onTap: () {
                                    setModalState(() {
                                      setState(() {
                                        if (isSelected) {
                                          _selectedIngredients.remove(ing);
                                        } else {
                                          _selectedIngredients.add(ing);
                                        }
                                      });
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFFFFF0E8) : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected ? _kOrange : Colors.grey.shade200,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          ing,
                                          style: GoogleFonts.dmSans(
                                            fontWeight: FontWeight.w600,
                                            color: isSelected ? _kOrange : const Color(0xFF2D3142),
                                            fontSize: 13,
                                          ),
                                        ),
                                        if (isSelected) ...[
                                          const SizedBox(width: 4),
                                          const Icon(Icons.check_rounded, size: 13, color: _kOrange),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kOrange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        'Done (${_selectedIngredients.length})',
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() {
        _pickedImageFile = File(picked.path);
      });
    }
  }

  // ── Ingredient validation lists ─────────────────────────────────────────────
  static const _kProteins   = ['Chicken', 'Beef', 'Fish', 'Turkey', 'Egg', 'Shrimp', 'Tuna', 'Salmon', 'Lentils', 'Beans', 'Tofu'];
  static const _kVegetables = ['Potato', 'Onion', 'Tomato', 'Carrot', 'Broccoli', 'Cucumber', 'Spinach', 'Pepper', 'Zucchini', 'Eggplant', 'Cabbage', 'Corn'];
  static const _kFruits     = ['Apple', 'Banana', 'Orange', 'Lemon', 'Strawberry', 'Mango', 'Pineapple', 'Grapes', 'Peach', 'Avocado'];
  static const _kGrains     = ['Rice', 'Pasta', 'Bread', 'Flour'];

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.dmSans(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFD84315),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    // ── Ingredient validation ────────────────────────────────────────────────
    if (_selectedIngredients.length < 3) {
      _showErrorSnackBar(
        'Please select at least 3 ingredients (${_selectedIngredients.length} selected).',
      );
      return;
    }

    final hasSubstantive = _selectedIngredients.any(
      (i) => _kProteins.contains(i) || _kVegetables.contains(i) ||
             _kFruits.contains(i)   || _kGrains.contains(i),
    );
    if (!hasSubstantive) {
      _showErrorSnackBar(
        'Add at least 1 ingredient from: Proteins, Vegetables, Fruits, or Grains & Carbs.',
      );
      return;
    }
    // ────────────────────────────────────────────────────────────────────────

    // Determine the imageUrl value
    final String imageUrl = _photoMode == 'url'
        ? _photoController.text.trim()
        : (_pickedImageFile?.path ?? '');

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to save a recipe.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance.collection('recipes').add({
        'name': _nameController.text.trim(),
        'category': _selectedCategory,
        'ingredients': _selectedIngredients,
        'prepTime': int.tryParse(_durationController.text.trim()) ?? 0,
        'instructions': _instructionController.text.trim(),
        'imageUrl': imageUrl,
        'uid': uid,
        'isUserRecipe': true,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Recipe saved successfully! 🎉',
              style: GoogleFonts.dmSans(color: Colors.white),
            ),
            backgroundColor: _kOrange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving recipe: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.dmSans(color: Colors.black45),
      prefixIcon: Icon(icon, color: _kOrange, size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _kOrange, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Add Recipe',
          style: GoogleFonts.playfairDisplay(
            color: const Color(0xFF2D3142),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        backgroundColor: _kBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kOrange),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'New Recipe',
              style: GoogleFonts.playfairDisplay(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D3142),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Fill in the details below',
              style: GoogleFonts.dmSans(fontSize: 14, color: Colors.black45),
            ),
            const SizedBox(height: 28),

            // Name
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration('Recipe Name', Icons.restaurant_menu),
              style: GoogleFonts.dmSans(),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            // Duration
            TextFormField(
              controller: _durationController,
              decoration: _inputDecoration('Duration (minutes)', Icons.timer_outlined),
              keyboardType: TextInputType.number,
              style: GoogleFonts.dmSans(),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            // ── Photo Section ───────────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.image_outlined, color: _kOrange, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        'Recipe Photo',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2D3142),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Toggle buttons: URL / Gallery
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0E8E0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      children: [
                        _photoModeButton('url', Icons.link_rounded, 'Enter URL'),
                        _photoModeButton('gallery', Icons.photo_library_outlined, 'Pick from Gallery'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // URL mode
                  if (_photoMode == 'url') ...[
                    TextFormField(
                      controller: _photoController,
                      decoration: _inputDecoration('Photo URL (optional)', Icons.link_rounded),
                      style: GoogleFonts.dmSans(),
                      keyboardType: TextInputType.url,
                    ),
                  ],

                  // Gallery mode
                  if (_photoMode == 'gallery') ...[
                    GestureDetector(
                      onTap: _pickImageFromGallery,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: _pickedImageFile != null ? 160 : 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0E8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _pickedImageFile != null ? _kOrange : Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        child: _pickedImageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(11),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.file(
                                      _pickedImageFile!,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      bottom: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: _pickImageFromGallery,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: _kOrange,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.edit, color: Colors.white, size: 13),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Change',
                                                style: GoogleFonts.dmSans(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.add_photo_alternate_outlined, color: _kOrange, size: 28),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Tap to pick a photo',
                                    style: GoogleFonts.dmSans(
                                      color: _kOrange,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Category Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  icon: const Icon(Icons.keyboard_arrow_down, color: _kOrange),
                  style: GoogleFonts.dmSans(color: const Color(0xFF2D3142), fontSize: 14),
                  items: _categories.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val!),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Pick Ingredients Button
            GestureDetector(
              onTap: _openIngredientPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _selectedIngredients.isEmpty ? Colors.grey.shade200 : _kOrange,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.kitchen_outlined, color: _kOrange, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedIngredients.isEmpty
                            ? 'Pick Ingredients'
                            : '${_selectedIngredients.length} ingredients selected',
                        style: GoogleFonts.dmSans(
                          color: _selectedIngredients.isEmpty ? Colors.black45 : _kOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black26),
                  ],
                ),
              ),
            ),

            // Selected ingredients preview
            if (_selectedIngredients.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedIngredients.map((ing) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0E8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _kOrange.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      ing,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: _kOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 16),

            // Instructions
            TextFormField(
              controller: _instructionController,
              decoration: _inputDecoration('Instructions', Icons.menu_book_outlined),
              maxLines: 5,
              style: GoogleFonts.dmSans(),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),

            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _isSaving ? null : _saveRecipe,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kOrange,
                disabledBackgroundColor: _kOrange.withValues(alpha: 0.6),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 3,
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      'Save Recipe',
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _photoModeButton(String mode, IconData icon, String label) {
    final isActive = _photoMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _photoMode = mode;
          _pickedImageFile = null;
          _photoController.clear();
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isActive ? _kOrange : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: isActive ? Colors.white : const Color(0xFF9E9E9E)),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : const Color(0xFF9E9E9E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _photoController.dispose();
    _instructionController.dispose();
    super.dispose();
  }
}