import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_preferences.dart';
import '../../models/exhibit.dart';
import '../../core/services/mock_data.dart';

// 🔥 USE THE REUSABLE GLOBAL NAV BAR
import '../../widgets/bottom_nav.dart';

class LiveTourScreen extends StatefulWidget {
  const LiveTourScreen({super.key});

  @override
  State<LiveTourScreen> createState() => _LiveTourScreenState();
}

class _LiveTourScreenState extends State<LiveTourScreen> {
  Exhibit? _currentExhibit;
  final List<String> _transcript = [];
  final ScrollController _scrollController = ScrollController();
  Timer? _simTimer;

  final Map<String, String> _imageMap = {
    '1': 'https://images.unsplash.com/photo-1728245029370-a47e535921da?q=80&w=1080',
    '2': 'https://images.unsplash.com/photo-1683918891762-ed43ae8d0da4?q=80&w=1080',
    '3': 'https://images.unsplash.com/photo-1611188513835-f4b58670d580?q=80&w=1080',
  };

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;

      if (args is Exhibit) {
        setState(() => _currentExhibit = args);
      } else {
        setState(() =>
            _currentExhibit = MockDataService.getAllExhibits().first);
      }

      _startSimulation();
    });
  }

  void _startSimulation() {
    if (_currentExhibit == null) return;

    final sentences = [
      "Welcome to the ${_currentExhibit!.nameEn}.",
      _currentExhibit!.descriptionEn,
      "This artifact is extremely significant to our history.",
      "Notice the intricate details on the surface.",
      "It was discovered during a major excavation in the late 20th century.",
      "Let's move closer to observe the craftsmanship.",
      "Any questions before we move to the next stop?"
    ];

    int index = 0;

    _simTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;

      if (index < sentences.length) {
        setState(() => _transcript.add(sentences[index]));

        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent + 100,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
          );
        }

        index++;
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _simTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == 'ar';

    if (_currentExhibit == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Live Tour")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],

      // 🔥 USE NAV BAR WITHOUT REPEATING CODE
      bottomNavigationBar: const BottomNav(currentIndex: 2),

      appBar: AppBar(
        title: Text(
          isArabic ? "جولة حية" : "Live Tour",
          style: const TextStyle(color: Colors.black),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LIVE STATUS BANNER
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Colors.redAccent, Colors.red]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _PulsingDot(),
                  const SizedBox(width: 12),
                  const Text(
                    "LIVE",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 1,
                    height: 20,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isArabic ? "الروبوت يتحدث الآن..." : "Robot is saying...",
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // CURRENT EXHIBIT CARD
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              clipBehavior: Clip.hardEdge,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    _imageMap[_currentExhibit!.id] ??
                        "https://via.placeholder.com/400x250",
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _currentExhibit!.getName(prefs.language),
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // TRANSCRIPT SECTION
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.chat_bubble_outline,
                            color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          isArabic ? "النص المباشر" : "Live Transcript",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      height: 250,
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: _transcript.length,
                        itemBuilder: (context, index) {
                          final isLast = index == _transcript.length - 1;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isLast
                                  ? Colors.blue[50]
                                  : Colors.white,
                              border: Border(
                                left: BorderSide(
                                  color: isLast
                                      ? Colors.blue
                                      : Colors.grey.shade300,
                                  width: 4,
                                ),
                              ),
                            ),
                            child: Text(
                              _transcript[index],
                              style: TextStyle(
                                fontWeight: isLast
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ACCESSIBILITY FEATURES
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic ? "ميزات سهولة الوصول" : "Accessibility Features",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue[900]),
                  ),
                  const SizedBox(height: 12),
                  _buildFeature(Icons.hearing,
                      isArabic ? "وصف صوتي مباشر" : "Real-time audio"),
                  _buildFeature(Icons.closed_caption,
                      isArabic ? "نص مباشر" : "Live captions"),
                  _buildFeature(Icons.wifi,
                      isArabic ? "متزامن عبر الواي فاي" : "Wi-Fi synced"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style:
                    TextStyle(fontSize: 14, color: Colors.blue.shade900)),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
// PULSING LIVE DOT
// ----------------------------------------------------------
class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);

    _fade = Tween(begin: 0.3, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
            color: Colors.white, shape: BoxShape.circle),
      ),
    );
  }
}
