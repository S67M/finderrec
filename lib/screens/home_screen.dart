import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'categories_screen.dart';
import 'fav_screen.dart';
import 'ingredient_selector_screen.dart';
import 'my_kitchen_screen.dart';
import 'myrecipes_screen.dart';
import 'profile_screen.dart';

// ── Brand colours ─────────────────────────────────────────────────────────────
const _kOrange = Color(0xFFF4631E);
const _kBg = Color(0xFFFFF8F3);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static const List<Widget> _tabs = [
    _HomeGrid(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset('assets/logo.png', height: 32),
            ),
            const SizedBox(width: 12),
            Text(
              "Recipe Finder",
              style: GoogleFonts.playfairDisplay(
                color: const Color(0xFF2D3142),
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
        backgroundColor: _kBg,
        elevation: 0,
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            selectedItemColor: _kOrange,
            unselectedItemColor: Colors.black38,
            backgroundColor: const Color(0xFFFFFDFB),
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: GoogleFonts.playfairDisplay(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.playfairDisplay(
              fontSize: 11,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 2×2 Feature Grid ──────────────────────────────────────────────────────────

class _HomeGrid extends StatelessWidget {
  const _HomeGrid();

  @override
  Widget build(BuildContext context) {
    final cards = [
      _FeatureCardData(
        label: 'Pick Ingredients',
        subtitle: 'Pick ingredients & search',
        icon: Icons.search_rounded,
        cardIndex: 0,
        destination: const IngredientSelectorScreen(),
      ),
      _FeatureCardData(
        label: 'All Recipes',
        subtitle: 'Browse by category',
        icon: Icons.menu_book,
        cardIndex: 1,
        destination: const CategoriesScreen(),
      ),
      _FeatureCardData(
        label: 'Favorites',
        subtitle: 'Your saved recipes',
        icon: Icons.favorite_rounded,
        cardIndex: 2,
        destination: const FavoritesScreen(),
      ),
      _FeatureCardData(
        label: 'My Recipes',
        subtitle: 'Your added recipes',
        icon: Icons.receipt_long_rounded,
        cardIndex: 3,
        destination: const MyrecipesScreen(),
      ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      children: [
        // ── Greeting ──────────────────────────────────────────────────────────
        RichText(
          text: TextSpan(
            style: GoogleFonts.dmSans(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2D3142),
            ),
            children: const [
              TextSpan(text: 'Welcome back! '),
              TextSpan(text: '👋', style: TextStyle(fontSize: 24)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'What would you like to do today?',
          style: GoogleFonts.dmSans(fontSize: 14, color: Colors.black45),
        ),
        const SizedBox(height: 28),

        // ── 2×2 Grid ──────────────────────────────────────────────────────────
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.95,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: cards.map((data) => _FeatureCard(data: data)).toList(),
        ),

        const SizedBox(height: 28),

        // ── Tip of the Day ────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _kBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _kOrange.withOpacity(0.30), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _kOrange.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: _kOrange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tip of the day',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _kOrange,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select 3 or more ingredients to get the best recipe matches!',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: const Color(0xFF5A5A5A),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── Inspirational footer ───────────────────────────────────────────────
        Center(
          child: Text(
            'Cook something amazing today ✦',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: Colors.grey,
              letterSpacing: 0.4,
            ),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}

// ── Card data model ───────────────────────────────────────────────────────────

class _FeatureCardData {
  final String label;
  final String subtitle;
  final IconData icon;
  final int cardIndex;
  final Widget destination;

  const _FeatureCardData({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.cardIndex,
    required this.destination,
  });
}

// ── Card background decoration helpers ───────────────────────────────────────

List<Widget> _cardDecorations(int index) {
  switch (index) {
    case 0: // Pick Ingredients — scattered circles
      return [
        Positioned(
          bottom: 8, right: 8,
          child: Opacity(
            opacity: 0.06,
            child: Container(
              width: 45, height: 45,
              decoration: const BoxDecoration(
                color: _kOrange,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 28, right: 42,
          child: Opacity(
            opacity: 0.06,
            child: Container(
              width: 25, height: 25,
              decoration: const BoxDecoration(
                color: _kOrange,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 14, right: 60,
          child: Opacity(
            opacity: 0.06,
            child: Container(
              width: 15, height: 15,
              decoration: const BoxDecoration(
                color: _kOrange,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ];

    case 1: // Categories — rounded rectangles
      return [
        Positioned(
          bottom: 14, right: 8,
          child: Opacity(
            opacity: 0.06,
            child: Container(
              width: 35, height: 8,
              decoration: BoxDecoration(
                color: _kOrange,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 26, right: 14,
          child: Opacity(
            opacity: 0.06,
            child: Container(
              width: 25, height: 8,
              decoration: BoxDecoration(
                color: _kOrange,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 38, right: 8,
          child: Opacity(
            opacity: 0.06,
            child: Container(
              width: 20, height: 8,
              decoration: BoxDecoration(
                color: _kOrange,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ];

    case 2: // Favorites — large faint heart
      return [
        Positioned(
          bottom: 4, right: 4,
          child: Opacity(
            opacity: 0.07,
            child: const Icon(
              Icons.favorite,
              color: _kOrange,
              size: 56,
            ),
          ),
        ),
      ];

    case 3: // My Recipes — circles + small rounded square
      return [
        Positioned(
          bottom: 8, right: 8,
          child: Opacity(
            opacity: 0.06,
            child: Container(
              width: 38, height: 38,
              decoration: const BoxDecoration(
                color: _kOrange,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 26, right: 44,
          child: Opacity(
            opacity: 0.06,
            child: Container(
              width: 20, height: 20,
              decoration: const BoxDecoration(
                color: _kOrange,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 10, right: 50,
          child: Opacity(
            opacity: 0.06,
            child: Container(
              width: 14, height: 14,
              decoration: BoxDecoration(
                color: _kOrange,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ];

    default:
      return [];
  }
}

// ── Feature Card ──────────────────────────────────────────────────────────────

class _FeatureCard extends StatefulWidget {
  final _FeatureCardData data;
  const _FeatureCard({required this.data});

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => widget.data.destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        _onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF0E8E0), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // ── Orange top accent ────────────────────────────────────────
                Positioned(
                  top: 0, left: 0, right: 0,
                  child: Container(height: 3, color: _kOrange),
                ),

                // ── Per-card faint background decoration ─────────────────────
                ..._cardDecorations(widget.data.cardIndex),

                // ── Card content ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 22, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _kOrange.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(widget.data.icon, color: _kOrange, size: 24),
                      ),
                      const Spacer(),
                      Text(
                        widget.data.label,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.data.subtitle,
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: const Color(0xFF9E9E9E),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
