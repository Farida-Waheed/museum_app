import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../models/auth_provider.dart';
import '../../models/exhibit_provider.dart';
import '../../models/tour_photo.dart';
import '../../services/photo_repository.dart';
import '../../widgets/app_menu_shell.dart';
import '../../widgets/bottom_nav.dart';

class MemoriesScreen extends StatelessWidget {
  const MemoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final authProvider = context.watch<AuthProvider>();
    final userId = authProvider.currentUser?.id;

    return AppMenuShell(
      title: (isArabic ? 'ذكريات الجولة' : 'Tour Memories').toUpperCase(),
      backgroundColor: AppColors.cinematicBackground,
      bottomNavigationBar: const BottomNav(currentIndex: 3),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppGradients.screenBackground,
        ),
        child: SafeArea(
          child: userId == null || userId.isEmpty
              ? _StateMessage(
                  icon: Icons.lock_outline,
                  title: isArabic ? 'سجّل الدخول أولًا' : 'Sign in first',
                  body: isArabic
                      ? 'يحفظ حسابك الصور التي يلتقطها حورس أثناء الجولة.'
                      : 'Your account keeps the photos Horus captures during the tour.',
                )
              : StreamBuilder<List<TourPhoto>>(
                  stream: PhotoRepository().watchUserPhotos(userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryGold,
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return _StateMessage(
                        icon: Icons.wifi_off_rounded,
                        title: isArabic
                            ? 'تعذر تحميل الذكريات'
                            : 'Could not load memories',
                        body: isArabic
                            ? 'تحقق من الاتصال وحاول مرة أخرى.'
                            : 'Check your connection and try again.',
                      );
                    }

                    final photos = snapshot.data ?? const <TourPhoto>[];
                    if (photos.isEmpty) {
                      return _StateMessage(
                        icon: Icons.photo_camera_outlined,
                        title: isArabic
                            ? 'لا توجد ذكريات بعد'
                            : 'No memories yet',
                        body: isArabic
                            ? 'عندما يلتقط حورس صورة أثناء جولتك ستظهر هنا.'
                            : 'When Horus captures a photo during your tour, it will appear here.',
                      );
                    }

                    final today = DateTime.now();
                    final todaysPhotos = photos
                        .where((photo) => _isSameDay(photo.createdAt, today))
                        .toList();
                    final previousPhotos = photos
                        .where((photo) => !_isSameDay(photo.createdAt, today))
                        .toList();
                    final favoritePhotos = photos.take(4).toList();

                    return CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            20,
                            24,
                            20,
                            6,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: _HeroCount(
                              count: photos.length,
                              isArabic: isArabic,
                            ),
                          ),
                        ),
                        _PhotoSection(
                          title: isArabic ? 'جولة اليوم' : "Today's Tour",
                          photos: todaysPhotos,
                          emptyText: isArabic
                              ? 'لا توجد صور من جولة اليوم بعد.'
                              : 'No photos from today yet.',
                        ),
                        _PhotoSection(
                          title: isArabic
                              ? 'الزيارات السابقة'
                              : 'Previous Visits',
                          photos: previousPhotos,
                          emptyText: isArabic
                              ? 'لا توجد زيارات سابقة محفوظة.'
                              : 'No previous visits saved yet.',
                        ),
                        _PhotoSection(
                          title: isArabic
                              ? 'الصور الملتقطة'
                              : 'Captured Photos',
                          photos: photos,
                          emptyText: '',
                        ),
                        _PhotoSection(
                          title: isArabic
                              ? 'الذكريات المفضلة'
                              : 'Favorite Memories',
                          photos: favoritePhotos,
                          emptyText: isArabic
                              ? 'سيتم عرض أبرز ذكرياتك هنا.'
                              : 'Your highlighted memories will appear here.',
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 28)),
                      ],
                    );
                  },
                ),
        ),
      ),
    );
  }

  static bool _isSameDay(DateTime? left, DateTime right) {
    if (left == null) return false;
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }
}

class _HeroCount extends StatelessWidget {
  const _HeroCount({required this.count, required this.isArabic});

  final int count;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.premiumGlassCard(
        radius: 22,
        highlighted: true,
      ),
      child: Row(
        textDirection: Directionality.of(context),
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppGradients.premiumGold,
            ),
            child: const Icon(
              Icons.auto_awesome_motion,
              color: AppColors.darkInk,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  Directionality.of(context) == ui.TextDirection.rtl
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic
                      ? 'حورس حفظ لحظات من جولتك'
                      : 'Horus saved moments from your tour',
                  style: AppTextStyles.titleMedium(
                    context,
                  ).copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  isArabic ? '$count صورة محفوظة' : '$count captured photos',
                  style: AppTextStyles.metadata(
                    context,
                  ).copyWith(color: AppColors.neutralMedium),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoSection extends StatelessWidget {
  const _PhotoSection({
    required this.title,
    required this.photos,
    required this.emptyText,
  });

  final String title;
  final List<TourPhoto> photos;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 0),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: Directionality.of(context) == ui.TextDirection.rtl
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: AppTextStyles.displaySectionTitle(
                context,
              ).copyWith(color: AppColors.softGold, letterSpacing: 1.2),
            ),
            const SizedBox(height: 12),
            if (photos.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: AppDecorations.secondaryGlassCard(radius: 16),
                child: Text(
                  emptyText,
                  style: AppTextStyles.bodyPrimary(
                    context,
                  ).copyWith(color: AppColors.neutralMedium),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.72,
                ),
                itemCount: photos.length,
                itemBuilder: (context, index) {
                  return _MemoryCard(photo: photos[index]);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _MemoryCard extends StatelessWidget {
  const _MemoryCard({required this.photo});

  final TourPhoto photo;

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final exhibits = context.watch<ExhibitProvider>().exhibits;
    final matching = exhibits.where((item) => item.id == photo.exhibitId);
    final exhibit = matching.isEmpty ? null : matching.first;
    final exhibitName = exhibit == null
        ? (lang == 'ar' ? 'ذكرى من الجولة' : 'Tour memory')
        : exhibit.getName(lang);
    final timestamp = photo.createdAt == null
        ? (lang == 'ar' ? 'منذ قليل' : 'Just now')
        : DateFormat.yMMMd(lang).add_jm().format(photo.createdAt!);

    return Container(
      decoration: AppDecorations.premiumGlassCard(radius: 18),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Image.network(
              photo.thumbnailUrl ?? photo.photoUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.cinematicSection,
                child: const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.primaryGold,
                    size: 34,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exhibitName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleMedium(
                    context,
                  ).copyWith(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 5),
                Text(
                  timestamp,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.metadata(
                    context,
                  ).copyWith(color: AppColors.neutralMedium, fontSize: 11),
                ),
                const SizedBox(height: 6),
                Text(
                  photo.sessionId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.metadata(context).copyWith(
                    color: AppColors.primaryGold.withValues(alpha: 0.78),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primaryGold, size: 54),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleLarge(
                context,
              ).copyWith(color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              body,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyPrimary(
                context,
              ).copyWith(color: AppColors.neutralMedium, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}
