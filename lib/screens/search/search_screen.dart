import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../models/exhibit.dart';
import '../../models/exhibit_provider.dart';
import '../../models/user_preferences.dart';
import '../../widgets/app_menu_shell.dart';

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
    _searchController.addListener(() => setState(() {}));
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
    final l10n = AppLocalizations.of(context)!;
    final providerExhibits = context.watch<ExhibitProvider>().exhibits;
    if (!identical(_allExhibits, providerExhibits)) {
      _allExhibits = providerExhibits;
      _filteredExhibits = _searchController.text.isEmpty
          ? _allExhibits
          : _allExhibits.where((exhibit) {
              final name = exhibit.getName(prefs.language).toLowerCase();
              return name.contains(_searchController.text.toLowerCase());
            }).toList();
    }

    return AppMenuShell(
      title: l10n.searchExhibits,
      backgroundColor: AppColors.cinematicBackground,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppGradients.screenBackground,
        ),
        child: ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 32),
          children: [
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
                  hintText: l10n.searchByExhibitName,
                  hintStyle: AppTextStyles.bodyPrimary(
                    context,
                  ).copyWith(color: AppColors.helperText),
                  filled: true,
                  fillColor: AppColors.cinematicCard,
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
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryGold,
                  ),
                ),
              )
            else if (_filteredExhibits.isEmpty &&
                _searchController.text.isNotEmpty)
              _buildEmptyState(l10n)
            else
              _buildResultList(prefs, isArabic),
          ],
        ),
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

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(Icons.search_off, size: 56, color: AppColors.primaryGold),
          const SizedBox(height: 16),
          Text(l10n.noResultsFound, style: AppTextStyles.titleLarge(context)),
          const SizedBox(height: 8),
          Text(
            l10n.noResultsFoundDesc,
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
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cinematicCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.goldBorder(0.10)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            textDirection: Directionality.of(context),
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
                      l10n.tapToViewDetailsAudioGuide,
                      style: AppTextStyles.metadata(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                isArabic
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
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
