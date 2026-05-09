import 'package:flutter/material.dart';

import '../../../models/exhibit.dart';
import 'home_snapshot.dart';

class HomeDemoService {
  const HomeDemoService();

  HomeFeaturedArtifact getFeaturedArtifact({
    required List<Exhibit> exhibits,
    required String lang,
    String? preferredExhibitId,
  }) {
    if (exhibits.isEmpty) {
      return HomeFeaturedArtifact(
        id: 'featured-mask',
        title: lang == 'ar' ? 'قناع توت عنخ آمون' : 'Tutankhamun Mask',
        subtitle: lang == 'ar'
            ? 'القاعة الذهبية - موصى به الآن'
            : 'Golden Hall - Recommended now',
        imageAsset: 'assets/images/pharaoh_head.jpg',
        contextHint: lang == 'ar'
            ? 'اضغط لعرض التفاصيل'
            : 'Tap for the full story',
      );
    }

    final exhibit = exhibits.firstWhere(
      (item) => item.id == preferredExhibitId,
      orElse: () => exhibits.first,
    );

    return HomeFeaturedArtifact(
      id: exhibit.id,
      title: lang == 'ar' ? exhibit.nameAr : exhibit.nameEn,
      subtitle: lang == 'ar'
          ? 'القاعة الذهبية - موصى به الآن'
          : 'Golden Hall - Recommended now',
      imageAsset: exhibit.imageAsset.isNotEmpty
          ? exhibit.imageAsset
          : 'assets/images/pharaoh_head.jpg',
      contextHint: lang == 'ar'
          ? 'اضغط لعرض التفاصيل'
          : 'Tap for the full story',
    );
  }

  String getDidYouKnow(String lang) {
    return lang == 'ar'
        ? 'يحتوي قناع توت عنخ آمون على نحو 10 كجم من الذهب.'
        : 'Tutankhamun\'s mask contains around 10kg of gold.';
  }

  String getMuseumUpdate(String lang) {
    return lang == 'ar'
        ? 'تحديث المتحف: استكشف القاعات الهادئة قبل أوقات الذروة.'
        : 'Museum update: explore the quieter galleries before peak hours.';
  }

  HomeMapPreviewData getMapPreview({
    required bool isRobotConnected,
    required bool hasActiveTour,
    required String lang,
  }) {
    if (!isRobotConnected) {
      return HomeMapPreviewData(
        isLive: false,
        horusPosition: const Offset(0.34, 0.42),
        userPosition: const Offset(0.58, 0.66),
        hint: lang == 'ar'
            ? 'ابدأ جولة لرؤية موقع Horus المباشر.'
            : 'Start a tour to see Horus live.',
      );
    }

    if (!hasActiveTour) {
      return HomeMapPreviewData(
        isLive: true,
        horusPosition: const Offset(0.40, 0.36),
        userPosition: const Offset(0.62, 0.70),
        hint: lang == 'ar'
            ? 'واجهة الموقع المباشر جاهزة.'
            : 'Live position prepared.',
      );
    }

    return HomeMapPreviewData(
      isLive: true,
      horusPosition: const Offset(0.34, 0.38),
      userPosition: const Offset(0.54, 0.64),
      hint: lang == 'ar' ? 'الموقع المباشر نشط.' : 'Live position active.',
    );
  }
}
