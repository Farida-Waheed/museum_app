import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For formatting the date/time (if needed)

// Assuming these imports are necessary for your app structure
import '../../models/exhibit.dart';
import '../../models/user_preferences.dart';
import '../../core/utils/audio_player.dart';

// Imports for the Navigation Bar
import '../../widgets/bottom_nav.dart';
import '../chat/chat_screen.dart'; // for RoboGuideEntry

// --- COLOR UTILIZATION (Matching FeedbackScreen Colors) ---
const Color _primaryBlue = Colors.blue; // main blue
const Color _lightBlue = Color(0xFF64B5F6); // lighter blue for accents/secondary

class ExhibitDetailScreen extends StatefulWidget {
  const ExhibitDetailScreen({super.key});

  @override
  State<ExhibitDetailScreen> createState() => _ExhibitDetailScreenState();
}

class _ExhibitDetailScreenState extends State<ExhibitDetailScreen>
    with SingleTickerProviderStateMixin {
  final AudioGuideService _audioService = AudioGuideService();
  bool isPlaying = false;

  // For the AnimatedIcon transition
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _audioService.stop();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleAudio(Exhibit exhibit, bool isArabic) {
    setState(() {
      isPlaying = !isPlaying;
      if (isPlaying) {
        _animationController.forward();
        // In a real app, you might use exhibit.getAudioUrl(isArabic)
        _audioService.playAudio('audio/${exhibit.id}.mp3');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  isArabic ? "جاري تشغيل الشرح الصوتي..." : "Playing audio guide..."),
              duration: const Duration(seconds: 1)),
        );
      } else {
        _animationController.reverse();
        _audioService.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Access the ColorScheme defined in the main Theme
    // NOTE: Overriding the colorScheme with the blue from the FeedbackScreen
    final colorScheme = Theme.of(context).colorScheme.copyWith(
      primary: _primaryBlue,
      secondary: _lightBlue,
    );

    final exhibit = ModalRoute.of(context)!.settings.arguments as Exhibit;
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == 'ar';

    return Scaffold(
      backgroundColor: Colors.white,

      // --- ADDED NAVIGATION BAR ---
      bottomNavigationBar: const BottomNav(currentIndex: 0), // Assuming index 0 for home/exhibit
      
      // --- ADDED ROBOGUIDE FAB (as per FeedbackScreen) ---
      floatingActionButton: const RoboGuideEntry(),

      body: CustomScrollView(
        slivers: [
          // --- 1. DYNAMIC HEADER ---
          _buildSliverAppBar(exhibit, prefs.language, colorScheme),

          // --- 2. CONTENT ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  // --- 3. SLEEK AUDIO PLAYER ---
                  _buildAudioPlayerCard(exhibit, isArabic, colorScheme),

                  const SizedBox(height: 30),

                  // --- 4. QUICK INFO CHIPS (Metadata) ---
                  _buildFactChips(exhibit, isArabic, colorScheme),

                  const SizedBox(height: 30),

                  // --- 5. DETAILED DESCRIPTION ---
                  Text(
                    isArabic ? "الوصف التفصيلي" : "Detailed Description",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    exhibit.getDescription(prefs.language),
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.7,
                          color: Colors.black87,
                        ),
                  ),

                  // --- 6. QUICK ACTION BUTTONS (Moved from FAB property and adjusted positioning) ---
                  const SizedBox(height: 30),
                  _buildQuickActionButtons(isArabic, exhibit, colorScheme),
                  
                  // Empty space for BottomNav clearance
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET BUILDERS -------------------------------------------

  // 1. DYNAMIC HEADER
  Widget _buildSliverAppBar(Exhibit exhibit, String language, ColorScheme colorScheme) {
    return SliverAppBar(
      expandedHeight: 350.0, // Taller image area
      pinned: true,
      backgroundColor: colorScheme.primary, // Use Theme primary color (now blue)
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
        title: Text(
          exhibit.getName(language),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // In a real app, use Image.network or Image.asset
            Container(
              color: Colors.grey.shade300,
              child: const Center(
                  child: Icon(Icons.palette_outlined, size: 120, color: Colors.black12)),
            ),

            // Subtitle that disappears when pinned
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 60),
                child: Text(
                  language == 'ar' ? 'القاعة الرئيسية' : 'Main Gallery Display',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                    shadows: const [Shadow(color: Colors.black, blurRadius: 8)],
                  ),
                ),
              ),
            ),

            // Subtle Gradient Overlay for Title Readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. SLEEK AUDIO PLAYER
  Widget _buildAudioPlayerCard(Exhibit exhibit, bool isArabic, ColorScheme colorScheme) {
    // Using primary container color for the card's background
    final cardColor = colorScheme.primary;
    // Using the accent color (secondary/tertiary) for visual pop
    final accentColor = colorScheme.secondary;

    return Card(
      elevation: 6, // More prominent card
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: cardColor,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Animated Play/Pause Button
                InkWell(
                  onTap: () => _toggleAudio(exhibit, isArabic),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: AnimatedIcon(
                      icon: AnimatedIcons.play_pause,
                      progress: _animationController,
                      size: 50,
                      color: accentColor, // Use the accent color
                    ),
                  ),
                ),

                const SizedBox(width: 15),

                // Text labels
                Expanded(
                  child: Column(
                    crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? "الشرح الصوتي" : "Audio Guide Available",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                      ),
                      Text(
                        isArabic ? "اضغط للتشغيل" : "Tap to start narration",
                        style: TextStyle(
                            fontSize: 13, color: Colors.white.withOpacity(0.7)),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Progress Bar (Simplified for this mock-up)
            if (isPlaying)
              LinearProgressIndicator(
                value: 0.7, // Simulated progress
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
          ],
        ),
      ),
    );
  }

  // 3. FACT CHIPS
  Widget _buildFactChips(Exhibit exhibit, bool isArabic, ColorScheme colorScheme) {
    // Mock data for key facts
    final List<Map<String, dynamic>> facts = [
      {'icon': Icons.public_rounded, 'label': isArabic ? 'الأصل' : 'Origin', 'value': 'Ancient Egypt'},
      {'icon': Icons.calendar_today_rounded, 'label': isArabic ? 'العمر' : 'Age', 'value': '4,500 Years'},
      {'icon': Icons.location_on_rounded, 'label': isArabic ? 'الموقع' : 'Location', 'value': 'Zone A, Shelf 3'},
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: isArabic ? WrapAlignment.end : WrapAlignment.start,
      children: facts.map((fact) => Chip(
        avatar: Icon(fact['icon'], size: 18, color: colorScheme.primary),
        label: Text('${fact['label']}: ${fact['value']}', style: const TextStyle(fontSize: 13)),
        backgroundColor: colorScheme.primary.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      )).toList(),
    );
  }

  // 4. QUICK ACTION BUTTONS (Adjusted positioning)
  Widget _buildQuickActionButtons(bool isArabic, Exhibit exhibit, ColorScheme colorScheme) {
    // Add logic here to check if the item is already bookmarked
    bool isBookmarked = false;

    return Row(
      // Aligns the buttons to the start (left) to prevent overlap with the main FAB
      mainAxisAlignment: MainAxisAlignment.start, 
      children: [
        // AR/Guide Button - Placed first (on the left)
        FloatingActionButton.extended(
          heroTag: "ar_guide_fab",
          onPressed: () {
            // Navigate to AR/Robot Guide Screen
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(isArabic ? 'تشغيل وضع الدليل الآلي...' : 'Starting AR Guide Mode...'),
            ));
          },
          backgroundColor: colorScheme.secondary, // Use accent/secondary
          foregroundColor: colorScheme.primary, // Use primary for text/icon contrast
          label: Text(isArabic ? "دليل آلي/واقع معزز" : "AR/Robot Guide",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          icon: const Icon(Icons.qr_code_scanner_rounded),
        ),

        const SizedBox(width: 15),

        // Bookmark/Save Button - Placed second
        FloatingActionButton.small(
          heroTag: "bookmark_fab",
          onPressed: () {
            setState(() => isBookmarked = !isBookmarked);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(isBookmarked
                  ? (isArabic ? 'تم حفظ المعرض!' : 'Exhibit Saved!')
                  : (isArabic ? 'تمت إزالة الحفظ.' : 'Bookmark Removed.')),
              duration: const Duration(milliseconds: 700),
            ));
          },
          backgroundColor: isBookmarked ? colorScheme.secondary : Colors.white, // Use accent/secondary for active
          foregroundColor: isBookmarked ? colorScheme.primary : Colors.grey,
          child: Icon(isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded),
        ),
      ],
    );
  }
}