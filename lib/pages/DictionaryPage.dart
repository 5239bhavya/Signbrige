import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'MyBottomNav.dart';

class DictionaryPage extends StatefulWidget {
  const DictionaryPage({super.key});

  @override
  State<DictionaryPage> createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedCategory = "All";

  final List<String> _categories = ["All", "Greetings", "Emergency", "Actions", "Basics"];

  final List<Map<String, dynamic>> _dictionaryData = [
    {'english': 'Hello', 'category': 'Greetings', 'gujarati': 'નમસ્તે', 'hindi': 'नमस्ते', 'gif': 'gif/1.gif'},
    {'english': 'Thank You', 'category': 'Greetings', 'gujarati': 'આભાર', 'hindi': 'धन्यवाद', 'gif': 'gif/2.gif'},
    {'english': 'Welcome', 'category': 'Greetings', 'gujarati': 'સ્વાગત', 'hindi': 'स्वागत', 'gif': 'gif/3.gif'},
    {'english': 'Yes', 'category': 'Basics', 'gujarati': 'હા', 'hindi': 'हां', 'gif': 'gif/4.gif'},
    {'english': 'No', 'category': 'Basics', 'gujarati': 'ના', 'hindi': 'नहीं', 'gif': 'gif/5.gif'},
    {'english': 'Please', 'category': 'Greetings', 'gujarati': 'મહેરબાની', 'hindi': 'कृपया', 'gif': 'gif/6.gif'},
    {'english': 'Sorry', 'category': 'Greetings', 'gujarati': 'માફ કરજો', 'hindi': 'माफ़ करें', 'gif': 'gif/7.gif'},
    {'english': 'Help', 'category': 'Emergency', 'gujarati': 'મદદ', 'hindi': 'मदद', 'gif': 'gif/8.gif'},
    {'english': 'Good', 'category': 'Basics', 'gujarati': 'સારું', 'hindi': 'अच्छा', 'gif': 'gif/9.gif'},
    {'english': 'Water', 'category': 'Emergency', 'gujarati': 'પાણી', 'hindi': 'पानी', 'gif': 'gif/10.gif'},
    {'english': 'Food / Eat', 'category': 'Emergency', 'gujarati': 'ખોરાક', 'hindi': 'खाना', 'gif': 'gif/1.gif'},
    {'english': 'Call Me', 'category': 'Actions', 'gujarati': 'કોલ કરો', 'hindi': 'कॉल करें', 'gif': 'gif/2.gif'},
  ];

  DateTime? lastBackPressTime;
  int _currentIndex = 2;

  Future<void> _navigate(String route) async {
    await HapticFeedback.selectionClick();
    if (!mounted) return;
    if (ModalRoute.of(context)?.settings.name != route) {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  void _showGifDialog(String englishWord, String gifPath) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.teal.withValues(alpha: 0.4), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 16,
                  spreadRadius: 4,
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      englishWord,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () async {
                        await HapticFeedback.selectionClick();
                        if (!dialogContext.mounted) return;
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 240,
                    width: double.infinity,
                    color: Colors.white,
                    child: Image.asset(
                      gifPath,
                      height: 240,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFF0F172A),
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.sign_language, size: 50, color: Colors.tealAccent),
                                SizedBox(height: 8),
                                Text(
                                  "Sign GIF Preview",
                                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onBottomNavTap(int index) async {
    if (index == _currentIndex) return;
    await HapticFeedback.selectionClick();
    if (!mounted) return;

    setState(() => _currentIndex = index);

    switch (index) {
      case 0:
        _navigate("/home");
        break;
      case 1:
        _navigate("/youtube");
        break;
      case 2:
        _navigate("/dictionary");
        break;
      case 3:
        _navigate("/user");
        break;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 600;

    final filteredItems = _dictionaryData.where((item) {
      final matchesQuery = item['english'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item['hindi'].toString().contains(_searchQuery) ||
          item['gujarati'].toString().contains(_searchQuery);
      final matchesCategory = _selectedCategory == "All" || item['category'] == _selectedCategory;
      return matchesQuery && matchesCategory;
    }).toList();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        DateTime now = DateTime.now();
        if (lastBackPressTime == null ||
            now.difference(lastBackPressTime!) > const Duration(seconds: 2)) {
          lastBackPressTime = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Press back again to exit")),
          );
          await HapticFeedback.lightImpact();
        } else {
          SystemNavigator.pop();
        }
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
              Icon(Icons.menu_book, color: Colors.tealAccent, size: 24),
              SizedBox(width: 8),
              Text(
                "ISL Dictionary",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: "Search word in English, Hindi or Gujarati...",
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                      prefixIcon: const Icon(Icons.search, color: Colors.tealAccent),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.white54),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = "");
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ),

              // Category Filters
              SizedBox(
                height: 42,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = cat == _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        selected: isSelected,
                        showCheckmark: false,
                        backgroundColor: const Color(0xFF1E293B),
                        selectedColor: Colors.teal,
                        side: BorderSide(
                          color: isSelected ? Colors.tealAccent : Colors.white12,
                        ),
                        label: Text(
                          cat,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                        onSelected: (selected) {
                          setState(() => _selectedCategory = cat);
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Cards Grid
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Center(
                    child: Container(
                      constraints: BoxConstraints(maxWidth: isWide ? 700 : double.infinity),
                      child: filteredItems.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Text(
                                  "No matching sign language words found",
                                  style: TextStyle(color: Colors.white54, fontSize: 14),
                                ),
                              ),
                            )
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isWide ? 2 : 1,
                                childAspectRatio: 2.3,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                              ),
                              itemCount: filteredItems.length,
                              itemBuilder: (context, index) {
                                final item = filteredItems[index];
                                return Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E293B),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: Colors.teal.withValues(alpha: 0.2)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              item['english'],
                                              style: const TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "Hindi: ${item['hindi']}  •  Gujarati: ${item['gujarati']}",
                                              style: const TextStyle(fontSize: 12, color: Colors.tealAccent),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.teal,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.teal.withValues(alpha: 0.4),
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                        child: IconButton(
                                          icon: const Icon(Icons.play_arrow, color: Colors.white, size: 26),
                                          onPressed: () async {
                                            await HapticFeedback.selectionClick();
                                            _showGifDialog(item['english'], item['gif']);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 70),
            ],
          ),
        ),
        bottomNavigationBar: MyBottomNav(
          currentIndex: _currentIndex,
          onTap: _onBottomNavTap,
        ),
      ),
    );
  }
}
