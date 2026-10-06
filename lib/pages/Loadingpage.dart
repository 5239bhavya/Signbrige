import 'package:flutter/material.dart';

class Loadingpage extends StatefulWidget {
  const Loadingpage({super.key});

  @override
  State<Loadingpage> createState() => _LoadingpageState();
}

class _LoadingpageState extends State<Loadingpage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF0F172A),
              Colors.teal.shade900,
              const Color(0xFF1E293B),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 0.95 + (_controller.value * 0.1),
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0D9488), Color(0xFF14B8A6), Color(0xFF2DD4BF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.tealAccent.withValues(alpha: 0.35),
                              blurRadius: 28,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.sign_language,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 36),

                const Text(
                  "SignBridge",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Bridging Silence with AI Vision",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.teal.shade200,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 50),

                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _fadeIcon(Icons.hearing, 0, _controller.value * 4, Colors.tealAccent),
                        const SizedBox(width: 20),
                        _fadeIcon(Icons.sign_language, 1, _controller.value * 4, Colors.tealAccent),
                        const SizedBox(width: 20),
                        _fadeIcon(Icons.chat_bubble_outline, 2, _controller.value * 4, Colors.tealAccent),
                        const SizedBox(width: 20),
                        _fadeIcon(Icons.connect_without_contact, 3, _controller.value * 4, Colors.tealAccent),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 36),

                SizedBox(
                  width: 220,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return LinearProgressIndicator(
                          minHeight: 6,
                          backgroundColor: Colors.white12,
                          valueColor: const AlwaysStoppedAnimation(Colors.tealAccent),
                          value: _controller.value,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Initializing AI Engine...",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white54,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fadeIcon(IconData icon, int index, double progress, Color color) {
    double opacity = (progress - index).clamp(0.2, 1.0);
    return Opacity(
      opacity: opacity,
      child: Icon(icon, size: 28, color: color),
    );
  }
}
