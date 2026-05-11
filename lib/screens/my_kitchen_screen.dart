import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'add_recipe_screen.dart';
import 'myrecipes_screen.dart';

// ── Brand colours (mirrored from home_screen) ─────────────────────────────────
const _kOrange = Color(0xFFF4631E);
const _kBg = Color(0xFFFFF8F3);

class MyKitchenScreen extends StatelessWidget {
  const MyKitchenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'My Kitchen',
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        children: [
          Text(
            'My Kitchen',
            style: GoogleFonts.playfairDisplay(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D3142),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Manage your recipes and pantry',
            style: GoogleFonts.dmSans(fontSize: 14, color: Colors.black45),
          ),
          const SizedBox(height: 28),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.95,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              _KitchenCard(
                icon: Icons.add_circle_outline,
                title: 'Add Recipe',
                subtitle: 'Create a new recipe',
                cardIndex: 0,
              ),
              _KitchenCard(
                icon: Icons.book_outlined,
                title: 'My Recipes',
                subtitle: 'View your recipes',
                cardIndex: 1,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Kitchen card (identical style to home screen _FeatureCard) ────────────────

class _KitchenCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int cardIndex;

  const _KitchenCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.cardIndex,
  });

  @override
  State<_KitchenCard> createState() => _KitchenCardState();
}

class _KitchenCardState extends State<_KitchenCard>
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

  void _onTap(BuildContext context) {
    if (widget.cardIndex == 0) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => AddRecipeScreen()));
    } else {
    Navigator.push(context, MaterialPageRoute(builder: (_) => MyrecipesScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        _onTap(context);
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
                // ── Orange top accent ──────────────────────────────────────────
                Positioned(
                  top: 0, left: 0, right: 0,
                  child: Container(height: 3, color: _kOrange),
                ),

                // ── Faint background decoration ───────────────────────────────
                ..._cardDecorations(widget.cardIndex),

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
                        child: Icon(widget.icon, color: _kOrange, size: 24),
                      ),
                      const Spacer(),
                      Text(
                        widget.title,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.subtitle,
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

// ── Faint card decorations (reusing home screen patterns) ─────────────────────

List<Widget> _cardDecorations(int index) {
  switch (index) {
    case 0: // Add Recipe — circles
      return [
        Positioned(
          bottom: 8, right: 8,
          child: Opacity(
            opacity: 0.06,
            child: Container(
              width: 45, height: 45,
              decoration: const BoxDecoration(color: _kOrange, shape: BoxShape.circle),
            ),
          ),
        ),
        Positioned(
          bottom: 28, right: 42,
          child: Opacity(
            opacity: 0.06,
            child: Container(
              width: 25, height: 25,
              decoration: const BoxDecoration(color: _kOrange, shape: BoxShape.circle),
            ),
          ),
        ),
        Positioned(
          bottom: 14, right: 60,
          child: Opacity(
            opacity: 0.06,
            child: Container(
              width: 15, height: 15,
              decoration: const BoxDecoration(color: _kOrange, shape: BoxShape.circle),
            ),
          ),
        ),
      ];
    case 1: // My Recipes — rounded rectangles
      return [
        Positioned(
          bottom: 14, right: 8,
          child: Opacity(
            opacity: 0.06,
            child: Container(
              width: 35, height: 8,
              decoration: BoxDecoration(color: _kOrange, borderRadius: BorderRadius.circular(4)),
            ),
          ),
        ),
        Positioned(
          bottom: 26, right: 14,
          child: Opacity(
            opacity: 0.06,
            child: Container(
              width: 25, height: 8,
              decoration: BoxDecoration(color: _kOrange, borderRadius: BorderRadius.circular(4)),
            ),
          ),
        ),
        Positioned(
          bottom: 38, right: 8,
          child: Opacity(
            opacity: 0.06,
            child: Container(
              width: 20, height: 8,
              decoration: BoxDecoration(color: _kOrange, borderRadius: BorderRadius.circular(4)),
            ),
          ),
        ),
      ];
    default:
      return [];
  }
}
