import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';

import '../../models/user_preferences.dart';
import '../../core/services/mock_data.dart';
import '../../models/exhibit.dart';
import '../../app/router.dart';
import '../../widgets/app_menu_shell.dart';
import '../../core/constants/text_styles.dart';

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

    return AppMenuShell(
      title: isArabic ? "البحث في المعروضات" : "Search Exhibits",
      backgroundColor: AppColors.darkBackground,
      floatingActionButton: null,
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // search field
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _filter,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.primaryGold,
                ),
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
                hintText: isArabic
                    ? "ابحث باسم القطعة..."
                    : "Search by exhibit name...",
                hintStyle: AppTextStyles.bodyPrimary(
                  context,
                ).copyWith(color: AppColors.helperText),
                filled: true,
                fillColor: AppColors.darkSurface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
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
          const Icon(Icons.search_off, size: 56, color: AppColors.primaryGold),
          const SizedBox(height: 16),
          Text(
            isArabic ? "لا توجد نتائج" : "No results found",
            style: AppTextStyles.titleLarge(context),
          ),
          const SizedBox(height: 8),
          Text(
            isArabic
                ? "جرّب كلمة مختلفة أو تحقق من الهجاء."
                : "Try a different word or check the spelling.",
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyPrimary(
              context,
            ).copyWith(color: AppColors.helperText),
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 56,
                  height: 56,
                  color: AppColors.primaryGold.withOpacity(0.1),
                  child: const Icon(
                    Icons.museum_outlined,
                    size: 28,
                    color: AppColors.primaryGold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: isArabic
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      exhibit.getName(prefs.language),
                      style: AppTextStyles.titleMedium(
                        context,
                      ).copyWith(fontSize: 15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isArabic
                          ? "اضغط لعرض تفاصيل المعروض"
                          : "Tap to view details and audio guide",
                      style: AppTextStyles.metadata(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Colors.white24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
