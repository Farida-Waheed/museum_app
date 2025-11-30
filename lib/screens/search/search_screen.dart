import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_preferences.dart';
import '../../core/services/mock_data.dart';
import '../../models/exhibit.dart';
import '../../app/router.dart';
import '../../widgets/bottom_nav.dart';
import '../chat/chat_screen.dart';

class SearchScreen extends StatefulWidget {
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
    Future.delayed(Duration.zero, () {
      _allExhibits = MockDataService.getAllExhibits();
      _filteredExhibits = _allExhibits;
      setState(() {});
    });

    _searchController.addListener(() {
      setState(() {}); // just to show/hide clear icon
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filter(String query) {
    final prefs = Provider.of<UserPreferencesModel>(context, listen: false);
    if (query.isEmpty) {
      setState(() => _filteredExhibits = _allExhibits);
      return;
    }

    setState(() {
      _filteredExhibits = _allExhibits.where((exhibit) {
        final name = exhibit.getName(prefs.language).toLowerCase();
        return name.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == 'ar';

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    const int currentIndex = 2; // assuming Search tab index

    return Scaffold(
      backgroundColor: Colors.grey[50],
      bottomNavigationBar: const BottomNav(currentIndex: currentIndex),
      floatingActionButton: const RoboGuideEntry(),
      appBar: AppBar(
        title: Text(
          isArabic ? "البحث في المعروضات" : "Search exhibits",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0.5,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // search field
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _filter,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filter('');
                          FocusScope.of(context).unfocus();
                        },
                      )
                    : null,
                hintText:
                    isArabic ? "ابحث باسم القطعة..." : "Search by exhibit name...",
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(26),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          if (_allExhibits.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_filteredExhibits.isEmpty &&
              _searchController.text.isNotEmpty)
            _buildEmptyState(isArabic, cs)
          else
            _buildResultList(prefs, isArabic),
        ],
      ),
    );
  }

  Widget _buildResultList(UserPreferencesModel prefs, bool isArabic) {
    return ListView.builder(
      itemCount: _filteredExhibits.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final exhibit = _filteredExhibits[index];
        return _SearchResultTile(
          exhibit: exhibit,
          prefs: prefs,
          isArabic: isArabic,
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.exhibitDetails,
              arguments: exhibit,
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(bool isArabic, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 56, color: cs.primary),
          const SizedBox(height: 16),
          Text(
            isArabic ? "لا توجد نتائج" : "No results found",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isArabic
                ? "جرّب كلمة مختلفة أو تحقق من الهجاء."
                : "Try a different word or check the spelling.",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final Exhibit exhibit;
  final UserPreferencesModel prefs;
  final bool isArabic;
  final VoidCallback onTap;

  const _SearchResultTile({
    required this.exhibit,
    required this.prefs,
    required this.isArabic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 56,
                  height: 56,
                  color: cs.primary.withOpacity(0.08),
                  child: const Icon(
                    Icons.museum_outlined,
                    size: 28,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      exhibit.getName(prefs.language),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isArabic
                          ? "اضغط لعرض تفاصيل المعروض"
                          : "Tap to view details and audio guide",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
