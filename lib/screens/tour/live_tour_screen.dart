import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_preferences.dart';
import '../../models/exhibit.dart';
import '../../core/services/mock_data.dart';
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
    '1': 'assets/images/Grand Hall.jpg',
    '2': 'assets/images/Colossal Seated Statues.jpg',
    '3': 'assets/images/Gold-Covered Sandals.jpg',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Exhibit) {
        _currentExhibit = args;
      } else {
        _currentExhibit = MockDataService.getAllExhibits().first;
      }
      setState(() {});
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
      "It was discovered during a major excavation.",
      "Let's move closer to observe the craftsmanship.",
    ];

    int index = 0;

    _simTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      if (index >= sentences.length) {
        timer.cancel();
        return;
      }
      setState(() => _transcript.add(sentences[index]));
      index++;

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
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
    final cs = Theme.of(context).colorScheme;

    if (_currentExhibit == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      bottomNavigationBar: const BottomNav(currentIndex: 2),
      appBar: AppBar(
        title: Text(
          isArabic ? "جولة حية" : "Live tour",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0.5,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // live banner – softer red
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  _PulsingDot(color: Colors.redAccent),
                  const SizedBox(width: 10),
                  Text(
                    "LIVE",
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const VerticalDivider(width: 1.0),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isArabic
                          ? "الروبوت يشرح هذه القطعة الآن."
                          : "The robot is currently describing this exhibit.",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // current exhibit
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // if you don't have asset images for all, you can
                  // fall back to a placeholder.
                  SizedBox(
                    height: 220,
                    width: double.infinity,
                    child: Image.asset(
                      _imageMap[_currentExhibit!.id] ??
                          'assets/images/museum_interior.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _currentExhibit!.getName(prefs.language),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // transcript
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: isArabic
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.chat_bubble_outline, color: cs.primary),
                        const SizedBox(width: 8),
                        Text(
                          isArabic ? "النص المباشر" : "Live transcript",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 220,
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: _transcript.length,
                        itemBuilder: (context, index) {
                          final isLast = index == _transcript.length - 1;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isLast
                                  ? cs.primary.withOpacity(0.05)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isLast
                                    ? cs.primary
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              _transcript[index],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isLast
                                    ? FontWeight.w600
                                    : FontWeight.w400,
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

            const SizedBox(height: 16),

            // accessibility note
            Container
            (
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.hearing, color: cs.primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isArabic
                          ? "يمكنك إيقاف الصوت والاعتماد على النص في أي وقت."
                          : "You can mute the robot and follow only the text at any time.",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

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
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
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
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
