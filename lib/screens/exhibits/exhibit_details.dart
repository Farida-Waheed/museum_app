import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/exhibit.dart';
import '../../models/user_preferences.dart';
import '../../core/utils/audio_player.dart';

class ExhibitDetailScreen extends StatefulWidget {
  const ExhibitDetailScreen({super.key});

  @override
  State<ExhibitDetailScreen> createState() => _ExhibitDetailScreenState();
}

class _ExhibitDetailScreenState extends State<ExhibitDetailScreen> {
  final AudioGuideService _audioService = AudioGuideService();
  bool isPlaying = false;

  @override
  void dispose() {
    _audioService.stop(); // Stop audio if user leaves screen
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Get the Exhibit passed from the previous screen
    final exhibit = ModalRoute.of(context)!.settings.arguments as Exhibit;
    
    // 2. Get Settings for Language
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == 'ar';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Big Image AppBar
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                exhibit.getName(prefs.language),
                style: const TextStyle(
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                ),
              ),
              background: Container(
                color: Colors.grey, // Placeholder color until we have real images
                child: const Center(child: Icon(Icons.image, size: 100, color: Colors.white54)),
                // In real app: Image.asset(exhibit.imageAsset, fit: BoxFit.cover),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Audio Player Controls
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
                          iconSize: 48,
                          color: Theme.of(context).primaryColor,
                          onPressed: () {
                            setState(() => isPlaying = !isPlaying);
                            if (isPlaying) {
                              _audioService.playAudio('audio/${exhibit.id}.mp3');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(isArabic ? "جاري تشغيل الشرح الصوتي..." : "Playing audio guide...")),
                              );
                            } else {
                              _audioService.stop();
                            }
                          },
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isArabic ? "استمع إلى الشرح" : "Listen to Guide",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              isArabic ? "بصوت الروبوت" : "Robot Narration",
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Description
                  Text(
                    isArabic ? "الوصف" : "Description",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    exhibit.getDescription(prefs.language),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}