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
import '../../widgets/bottom_nav.dart';

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
    final exhibitProvider = context.watch<ExhibitProvider>();
    final providerExhibits = exhibitProvider.exhibits;
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
      bottomNavigationBar: const BottomNav(currentIndex: 1),
      showChatButton: true,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppGradients.screenBackground,
        ),
        child: ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.screenHorizontalCompact,
            16,
            AppSpacing.screenHorizontalCompact,
            48,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
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
                  hintStyle: AppTextStyles.premiumMutedBody(
                    context,
                  ).copyWith(fontSize: 14),
                  filled: true,
                  fillColor: AppColors.cinematicCard.withValues(alpha: 0.82),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide(color: AppColors.goldBorder(0.10)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide(color: AppColors.goldBorder(0.42)),
                  ),
                ),
              ),
            ),
            if (_allExhibits.isEmpty && exhibitProvider.isLoading)
              const _SearchLoadingState()
            else if (_allExhibits.isEmpty)
              _buildEmptyState(l10n)
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
      padding: const EdgeInsets.only(top: 18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: AppDecorations.premiumGlassCard(radius: 24),
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.goldBorder(0.22)),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 28,
                color: AppColors.primaryGold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noResultsFound,
              textAlign: TextAlign.center,
              style: AppTextStyles.premiumCardTitle(context),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noResultsFoundDesc,
              textAlign: TextAlign.center,
              style: AppTextStyles.premiumMutedBody(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchLoadingState extends StatelessWidget {
  const _SearchLoadingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: AppDecorations.premiumGlassCard(radius: 24),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGold),
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppDecorations.secondaryGlassCard(radius: 22, opacity: 0.54),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPaddingCompact),
          child: Row(
            textDirection: Directionality.of(context),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _SearchThumb(imageAsset: exhibit.imageAsset),
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
                      style: AppTextStyles.premiumCardTitle(
                        context,
                      ).copyWith(fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.tapToViewDetailsAudioGuide,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.premiumMutedBody(
                        context,
                      ).copyWith(fontSize: 12),
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
                color: AppColors.primaryGold.withValues(alpha: 0.62),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchThumb extends StatelessWidget {
  const _SearchThumb({required this.imageAsset});

  final String imageAsset;

  @override
  Widget build(BuildContext context) {
    if (imageAsset.trim().isEmpty) return const _SearchThumbPlaceholder();
    return Image.asset(
      imageAsset,
      width: 58,
      height: 58,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const _SearchThumbPlaceholder(),
    );
  }
}

class _SearchThumbPlaceholder extends StatelessWidget {
  const _SearchThumbPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        gradient: AppGradients.premiumGold,
        border: Border.all(color: AppColors.goldBorder(0.22)),
      ),
      child: const Icon(
        Icons.museum_outlined,
        size: 27,
        color: AppColors.darkInk,
      ),
    );
  }
}
