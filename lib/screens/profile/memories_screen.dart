import 'package:flutter/material.dart';
import '../../widgets/app_menu_shell.dart';
import '../../l10n/app_localizations.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';

class MemoriesScreen extends StatelessWidget {
  const MemoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // Mock data for memories
    final List<Map<String, String>> memories = [
      {
        'exhibit': isArabic ? 'تمثال رمسيس الثاني' : 'Statue of Ramesses II',
        'date': '2023-10-25',
        'image': 'assets/images/museum_interior.jpg',
      },
      {
        'exhibit': isArabic ? 'قناع توت عنخ آمون' : 'Tutankhamun Mask',
        'date': '2023-10-25',
        'image': 'assets/images/pharaoh_head.jpg',
      },
      {
        'exhibit': isArabic ? 'الأواني الكانوبية' : 'Canopic Jars',
        'date': '2023-10-25',
        'image': 'assets/images/canopic_jars.jpg',
      },
      {
        'exhibit': isArabic ? 'الجدار الهيروغليفي' : 'Hieroglyphic Wall',
        'date': '2023-10-25',
        'image': 'assets/images/hieroglyphs.jpg',
      },
    ];

    return AppMenuShell(
      title: (isArabic ? 'ذكرياتي' : 'My Memories').toUpperCase(),
      backgroundColor: AppColors.cinematicBackground,
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.72,
        ),
        itemCount: memories.length,
        itemBuilder: (context, index) {
          final memory = memories[index];
          return _MemoryCard(
            exhibit: memory['exhibit']!,
            date: memory['date']!,
            image: memory['image']!,
          );
        },
      ),
    );
  }
}

class _MemoryCard extends StatelessWidget {
  final String exhibit;
  final String date;
  final String image;

  const _MemoryCard({
    required this.exhibit,
    required this.date,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cinematicCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.asset(
                image,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exhibit,
                    style: AppTextStyles.displayArtifactTitle(context).copyWith(
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: AppTextStyles.metadata(context).copyWith(
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _ActionButton(icon: Icons.share_rounded, onTap: () {}),
                      _ActionButton(icon: Icons.download_rounded, onTap: () {}),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.cinematicBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primaryGold.withOpacity(0.3)),
        ),
        child: Icon(icon, color: AppColors.primaryGold, size: 18),
      ),
    );
  }
}
