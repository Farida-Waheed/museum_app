import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_preferences.dart';
import '../../core/services/mock_data.dart';
import '../../models/exhibit.dart';
import '../../app/router.dart';
import '../../widgets/bottom_nav.dart'; // Import BottomNav
import '../chat/chat_screen.dart'; // Import RoboGuideEntry (assuming this is used for the FAB)

// Assuming you have defined a color palette in your theme or constants
const Color primaryColor = Color(0xFF00796B); // Teal for a museum/tech vibe
const Color accentColor = Colors.orange;
const Color backgroundColor = Colors.white; // Changed to white for a cleaner look, similar to FeedbackScreen body

class SearchScreen extends StatefulWidget {
  // Set the current index for the bottom navigation bar
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Exhibit> _allExhibits = [];
  List<Exhibit> _filteredExhibits = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Simulate a small delay for a real-world feel and potential loading state
    Future.delayed(Duration.zero, () {
      _allExhibits = MockDataService.getAllExhibits();
      _filteredExhibits = _allExhibits;
      setState(() {});
    });
    // Set up listener for the clear button
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterExhibits(String query) {
    // Note: The Provider.of call needs listen: false inside a function like this
    final prefs = Provider.of<UserPreferencesModel>(context, listen: false);

    setState(() {
      if (query.isEmpty) {
        _filteredExhibits = _allExhibits;
      } else {
        _filteredExhibits = _allExhibits.where((exhibit) {
          final name = exhibit.getName(prefs.language).toLowerCase();
          return name.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _requestRobot(BuildContext context, Exhibit exhibit) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Robot requested to go to: ${exhibit.nameEn}"),
        action: SnackBarAction(
            label: "VIEW ON MAP",
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.map);
            }),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == 'ar';

    // The current index for the Search screen needs to be determined based on
    // where it sits in the BottomNav. Assuming it's the second item (index 1).
    const int currentIndex = 1; 

    return Scaffold(
      backgroundColor: Colors.grey[100], // Match FeedbackScreen body background (light grey)
      
      // 1. Add the Bottom Navigation Bar from FeedbackScreen
      bottomNavigationBar: const BottomNav(currentIndex: currentIndex),

      // 2. Add the Floating Action Button (RoboGuideEntry) from FeedbackScreen
      floatingActionButton: const RoboGuideEntry(),

      // 3. Add an AppBar styled like FeedbackScreen (but using search icon and local colors)
      appBar: AppBar(
        title: Text(
          isArabic ? "البحث عن القطع الأثرية" : "Search Artifacts",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white, // Match FeedbackScreen AppBar background
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      // Use ListView instead of Column with Expanded for better compatibility with Scaffold padding
      body: ListView(
        padding: EdgeInsets.zero, // Remove ListView default padding
        children: [
          // Custom Header and Search Bar Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Removed the large header text as it's now in the AppBar
                
                // const SizedBox(height: 16), // No need for this extra space after removing the large title
                // Modern Pill-Shaped Search Field
                TextField(
                  controller: _searchController,
                  onChanged: _filterExhibits,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: primaryColor),
                    // Clear button functionality
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              _filterExhibits('');
                              FocusScope.of(context).unfocus(); // Dismiss keyboard
                            },
                          )
                        : null,
                    hintText: isArabic ? "ابحث بالاسم..." : "Search by name...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0), // High radius for pill shape
                      borderSide: BorderSide.none, // Remove border line
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 20.0),
                    // Use a subtle elevation via the parent widget or a Container if needed
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Results Section
          // We wrap the list view content in a SizedBox to manage the space it takes up
          _filteredExhibits.isEmpty && _searchController.text.isNotEmpty
              ? _buildEmptyState(isArabic) // Show empty state if filtered and search query is not empty
              : _allExhibits.isEmpty
                  ? const Center(child: Padding(
                      padding: EdgeInsets.only(top: 50.0),
                      child: CircularProgressIndicator(color: primaryColor),
                    )) // Show loading if exhibits haven't loaded
                  : _buildExhibitList(prefs, isArabic),
        ],
      ),
    );
  }

  // Helper function to build the exhibit list (was an Expanded before)
  Widget _buildExhibitList(UserPreferencesModel prefs, bool isArabic) {
    return ListView.builder(
      shrinkWrap: true, // Important for ListView inside another Scrollable (ListView)
      physics: const NeverScrollableScrollPhysics(), // Important to prevent inner list scrolling
      itemCount: _filteredExhibits.length,
      itemBuilder: (context, index) {
        final exhibit = _filteredExhibits[index];
        return _buildExhibitCard(context, exhibit, prefs, isArabic);
      },
    );
  }

  Widget _buildExhibitCard(BuildContext context, Exhibit exhibit, UserPreferencesModel prefs, bool isArabic) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.exhibitDetails, arguments: exhibit);
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Placeholder Image/Icon
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Container(
                  width: 60,
                  height: 60,
                  color: primaryColor.withOpacity(0.1),
                  child: const Center(
                    child: Icon(Icons.museum_outlined, size: 30, color: primaryColor),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Title & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      exhibit.getName(prefs.language),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black87),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isArabic ? "الموقع: قاعة العرض الرئيسية" : "Location: Main Exhibition Hall",
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Prominent Robot Action Button
              ElevatedButton.icon(
                onPressed: () => _requestRobot(context, exhibit),
                icon: const Icon(Icons.smart_toy, size: 20),
                label: Text(isArabic ? "اطلب" : "Request"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  elevation: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isArabic) {
    // Wrap with SizedBox to make it take up space below the search bar
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 60, color: primaryColor),
            const SizedBox(height: 16),
            Text(
              isArabic ? "لا توجد نتائج" : "No results found",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              isArabic
                  ? "حاول البحث بكلمة مختلفة أو تحقق من الهجاء."
                  : "Try searching with a different term or check your spelling.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}