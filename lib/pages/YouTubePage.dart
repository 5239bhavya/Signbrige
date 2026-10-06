import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'MyBottomNav.dart';

class YoutubePage extends StatefulWidget {
  const YoutubePage({super.key});

  @override
  State<YoutubePage> createState() => _YoutubePageState();
}

class _YoutubePageState extends State<YoutubePage> with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> videoData = [
    {
      'videoId': 'kVOnsVSpu_g',
      'title': 'Sign Language Basics',
      'description': 'Learn the fundamentals of American Sign Language with this beginner-friendly tutorial.'
    },
    {
      'videoId': 'v1desDduz5M',
      'title': 'Sign Language Common Phrases',
      'description': 'Master everyday phrases and expressions in sign language for better communication.'
    },
    {
      'videoId': 'pDxEK0_b1fs',
      'title': 'Sign Language Stories',
      'description': 'Watch beautiful stories narrated in sign language with English subtitles.'
    },
  ];

  late List<YoutubePlayerController> _controllers;
  late AnimationController _animationController;
  late List<Animation<double>> _cardAnimations;

  int _currentIndex = 1;
  DateTime? lastBackPressed;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _controllers = videoData.map((video) {
      return YoutubePlayerController(
        initialVideoId: video['videoId'],
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          enableCaption: true,
        ),
      );
    }).toList();

    _cardAnimations = List.generate(videoData.length, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.2,
            (index * 0.2 + 0.6).clamp(0.0, 1.0),
            curve: Curves.easeOutBack,
          ),
        ),
      );
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _navigate(int index) async {
    await HapticFeedback.selectionClick();
    if (_currentIndex == index) return;
    if (!mounted) return;

    setState(() => _currentIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, "/home");
        break;
      case 1:
        break;
      case 2:
        Navigator.pushReplacementNamed(context, "/dictionary");
        break;
      case 3:
        Navigator.pushReplacementNamed(context, "/user");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWideScreen = width > 600;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        DateTime now = DateTime.now();
        if (lastBackPressed == null || now.difference(lastBackPressed!) > const Duration(seconds: 2)) {
          lastBackPressed = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Press back again to exit"),
              duration: Duration(seconds: 2),
            ),
          );
          await HapticFeedback.lightImpact();
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        extendBody: true,
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFD6EAFF), Color(0xFFFDEBDC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        "SignBridge Video Lessons",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: const Text(
                      "Learn Sign Language from Video Tutorials",
                      style: TextStyle(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF2C3E50),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Center(
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: isWideScreen ? 700 : double.infinity,
                          ),
                          child: Column(
                            children: List.generate(videoData.length, (index) {
                              return AnimatedBuilder(
                                animation: _cardAnimations[index],
                                builder: (context, child) {
                                  double animValue = _cardAnimations[index].value.clamp(0.0, 1.0);
                                  return Transform.translate(
                                    offset: Offset(0.0, 50 * (1 - animValue)),
                                    child: Opacity(opacity: animValue, child: child),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: _buildVideoCard(
                                    _controllers[index],
                                    videoData[index]['title'],
                                    videoData[index]['description'],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: MyBottomNav(
          currentIndex: _currentIndex,
          onTap: _navigate,
        ),
      ),
    );
  }

  Widget _buildVideoCard(YoutubePlayerController controller, String title, String description) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white.withValues(alpha: 0.9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: YoutubePlayer(
              controller: controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: const Color(0xFF8B5CF6),
              progressColors: const ProgressBarColors(
                playedColor: Color(0xFF8B5CF6),
                handleColor: Color(0xFF3B82F6),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF2C3E50).withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildActionButton(Icons.bookmark_border, "Save", const Color(0xFF3B82F6)),
                    const SizedBox(width: 12),
                    _buildActionButton(Icons.share, "Share", const Color(0xFF8B5CF6)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () async {
        await HapticFeedback.selectionClick();
      },
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}
