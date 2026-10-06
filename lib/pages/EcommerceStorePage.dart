import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'MyBottomNav.dart';

class EcommerceStorePage extends StatefulWidget {
  const EcommerceStorePage({super.key});

  @override
  State<EcommerceStorePage> createState() => _EcommerceStorePageState();
}

class _EcommerceStorePageState extends State<EcommerceStorePage>
    with TickerProviderStateMixin {
  late final AnimationController _enterController;
  final Set<int> _pressed = {};

  final List<_Product> _products = const [
    _Product(
      name: "Folding White Cane",
      price: "₹799",
      imageUrl: "https://tse1.mm.bing.net/th/id/OIP.j9az2-oHzaPuv9tJM2N8mwAAAA?pid=Api&P=0&h=220",
      url: "https://www.amazon.in/s?k=folding+white+cane",
      rating: "4.8",
    ),
    _Product(
      name: "Digital Hearing Aid",
      price: "₹2,499",
      imageUrl: "https://tse2.mm.bing.net/th/id/OIP.dEc03rYZ8vRCOP3PjRMf4wHaHa?pid=Api&P=0&h=220",
      url: "https://www.amazon.in/s?k=hearing+aid",
      rating: "4.9",
    ),
    _Product(
      name: "Braille Slate & Stylus",
      price: "₹349",
      imageUrl: "https://m.media-amazon.com/images/I/51y5FbjexLL._AC_.jpg",
      url: "https://www.amazon.in/s?k=braille+slate",
      rating: "4.7",
    ),
    _Product(
      name: "Vibrating Alarm Watch",
      price: "₹1,999",
      imageUrl: "https://tse4.mm.bing.net/th/id/OIP.joIk9vcLpIJX7nY0FnqIFgHaF9?pid=Api&P=0&h=220",
      url: "https://www.amazon.in/s?k=vibrating+alarm+watch",
      rating: "4.6",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _enterController.dispose();
    super.dispose();
  }

  Future<void> _openProduct(String url) async {
    await HapticFeedback.selectionClick();
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot open external store link")),
      );
    }
  }

  void _onNavTap(int index) async {
    await HapticFeedback.selectionClick();
    if (!mounted) return;
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, "/home");
        break;
      case 1:
        Navigator.pushReplacementNamed(context, "/text_translation");
        break;
      case 2:
        Navigator.pushReplacementNamed(context, "/eng_to_sign");
        break;
      case 3:
        Navigator.pushReplacementNamed(context, "/sign_to_english");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
      },
      child: Scaffold(
        extendBody: true,
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shopping_bag, color: Colors.amberAccent, size: 24),
              SizedBox(width: 8),
              Text(
                "Accessible Store",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.stars, color: Colors.amberAccent, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Verified Assistive Devices",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Quality hearing, visual, and tactile tools",
                              style: TextStyle(color: Colors.white60, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    itemCount: _products.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isWide ? 3 : 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.72,
                    ),
                    itemBuilder: (context, index) {
                      final product = _products[index];

                      final anim = CurvedAnimation(
                        parent: _enterController,
                        curve: Interval(
                          (0.06 * index).clamp(0.0, 1.0),
                          (0.5 + 0.1 * index).clamp(0.0, 1.0),
                          curve: Curves.easeOut,
                        ),
                      );

                      final isPressed = _pressed.contains(index);

                      return FadeTransition(
                        opacity: anim,
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 120),
                          scale: isPressed ? 0.97 : 1.0,
                          curve: Curves.easeOut,
                          child: GestureDetector(
                            onTapDown: (_) => setState(() => _pressed.add(index)),
                            onTapCancel: () => setState(() => _pressed.remove(index)),
                            onTapUp: (_) => setState(() => _pressed.remove(index)),
                            onTap: () => _openProduct(product.url),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.teal.withValues(alpha: 0.25),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                    child: AspectRatio(
                                      aspectRatio: 16 / 11,
                                      child: Image.network(
                                        product.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => Container(
                                          color: Colors.white12,
                                          child: const Center(
                                            child: Icon(
                                              Icons.image_not_supported,
                                              color: Colors.white38,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.star, color: Colors.amber, size: 14),
                                              const SizedBox(width: 4),
                                              Text(
                                                product.rating,
                                                style: const TextStyle(
                                                  color: Colors.amber,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            product.name,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const Spacer(),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                product.price,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.tealAccent,
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.all(6),
                                                decoration: const BoxDecoration(
                                                  color: Colors.teal,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(Icons.open_in_new, size: 14, color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 70),
            ],
          ),
        ),
        bottomNavigationBar: MyBottomNav(
          currentIndex: 0,
          onTap: _onNavTap,
        ),
      ),
    );
  }
}

class _Product {
  final String name;
  final String price;
  final String imageUrl;
  final String url;
  final String rating;

  const _Product({
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.url,
    required this.rating,
  });
}
