import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'next_page.dart';

// GLOWING LOGO WIDGET
class GlowingLogo extends StatefulWidget {
  final String imagePath;
  final double height;

  const GlowingLogo({
    super.key,
    required this.imagePath,
    this.height = 100,
  });

  @override
  State<GlowingLogo> createState() => _GlowingLogoState();
}

class _GlowingLogoState extends State<GlowingLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.5 + 2.0 * _controller.value, 0),
              end: Alignment(-0.7 + 2.0 * _controller.value, 0),
              colors: [
                Colors.white.withOpacity(0.0),
                Colors.white.withOpacity(0.9),
                Colors.white.withOpacity(0.0),
              ],
              stops: const [0.4, 0.5, 0.6],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: Image.asset(
            widget.imagePath,
            height: widget.height,
            fit: BoxFit.contain,
          ),
        );
      },
    );
  }
}

// MAIN SCREEN
class ParentingHome extends StatelessWidget {
  const ParentingHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/img1.jpg',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.0),
              colorBlendMode: BlendMode.darken,
            ),
          ),

          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xAAFFFFFF),
                    Color(0x66FFFFFF),
                    Colors.transparent,
                    Color(0xAA000000),
                  ],
                ),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: 20),

                    // Glowing Logo (slightly moved up)
                    Transform.translate(
                      offset: const Offset(0, -160),
                      child: const GlowingLogo(
                        imagePath: 'assets/smilestone_logo.jpg',
                        height: 180,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Motivational Quote (slightly moved up)
                   
                    const SizedBox(height: 50),

                    // Get Started Button with Fade Transition
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 10,
                          shadowColor: Colors.deepPurple,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const FeverTrackerPage(),
                              transitionsBuilder:
                                  (context, animation, secondaryAnimation, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                              transitionDuration: const Duration(milliseconds: 500),
                            ),
                          );
                        },
                        child: Text(
                          "Get Started",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
