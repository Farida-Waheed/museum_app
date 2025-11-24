import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_preferences.dart';
import '../../models/exhibit.dart';
import '../../core/services/mock_data.dart'; // Fallback data

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

  // Mock images for the demo (using network images to match React example)
  final Map<String, String> _imageMap = {
    '1': 'https://images.unsplash.com/photo-1728245029370-a47e535921da?q=80&w=1080', // Vase
    '2': 'https://images.unsplash.com/photo-1683918891762-ed43ae8d0da4?q=80&w=1080', // Bone/Statue
    '3': 'https://images.unsplash.com/photo-1611188513835-f4b58670d580?q=80&w=1080', // Space/Calendar
  };

  @override
  void initState() {
    super.initState();
    
    // In a real app, you would listen to a WebSocket/Firebase stream here.
    // For this demo, we start the simulation after the build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Exhibit) {
        setState(() => _currentExhibit = args);
        _startSimulation();
      } else {
        // Fallback: Load the first exhibit if none passed
        setState(() => _currentExhibit = MockDataService.getAllExhibits().first);
        _startSimulation();
      }
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
        setState(() {
          _transcript.add(sentences[index]);
        });
        
        // Auto-scroll to bottom
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent + 100,
            duration: const Duration(milliseconds: 500),
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
      appBar: AppBar(
        title: Text(isArabic ? "جولة حية" : "Live Tour"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Live Status Card ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.redAccent, Colors.red]),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.red.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  _PulsingDot(),
                  const SizedBox(width: 12),
                  const Text("LIVE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                  const SizedBox(width: 12),
                  Container(width: 1, height: 20, color: Colors.white.withValues(alpha: 0.5)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isArabic ? "الروبوت يتحدث الآن..." : "Robot is saying...",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- 2. Current Exhibit Card ---
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Image.network(
                        _imageMap[_currentExhibit!.id] ?? 'https://via.placeholder.com/400x250',
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          height: 250, 
                          color: Colors.grey[300],
                          child: const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                        ),
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Now Playing",
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentExhibit!.getName(prefs.language),
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            Chip(
                              label: const Text("History"),
                              backgroundColor: Colors.grey[100],
                              side: BorderSide.none,
                            ),
                            Chip(
                              label: const Text("Ancient Era"),
                              backgroundColor: Colors.blue[50],
                              labelStyle: const TextStyle(color: Colors.blue),
                              side: BorderSide.none,
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- 3. Live Transcript ---
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.chat_bubble_outline, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          isArabic ? "النص المباشر" : "Live Transcript",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 250,
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: _transcript.length + (_simTimer?.isActive == true ? 1 : 0),
                        itemBuilder: (context, index) {
                          // Loading indicator at bottom if active
                          if (index == _transcript.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: Text("...", style: TextStyle(fontSize: 24, color: Colors.grey))),
                            );
                          }

                          final isLast = index == _transcript.length - 1;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isLast ? Colors.blue[50] : Colors.white,
                              border: Border(
                                left: BorderSide(
                                  color: isLast ? Colors.blue : Colors.grey.shade300,
                                  width: 4
                                )
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.volume_up, 
                                  size: 18, 
                                  color: isLast ? Colors.blue : Colors.grey
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _transcript[index],
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: isLast ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
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

            // --- 4. Accessibility Info ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic ? "ميزات سهولة الوصول" : "Accessibility Features",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[900]),
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureRow(Icons.hearing, isArabic ? "وصف صوتي مباشر" : "Real-time audio description"),
                  const SizedBox(height: 8),
                  _buildFeatureRow(Icons.closed_caption, isArabic ? "نص مباشر للمساعدة السمعية" : "Live text for hearing assistance"),
                  const SizedBox(height: 8),
                  _buildFeatureRow(Icons.wifi, isArabic ? "متزامن عبر الواي فاي" : "Synchronized over Wi-Fi"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blue[700]),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(color: Colors.blue[900]))),
      ],
    );
  }
}

// Custom Pulsing Dot Widget
class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _animation = Tween(begin: 0.5, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      ),
    );
  }
}