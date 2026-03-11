import 'package:flutter/material.dart';
import '../../widgets/app_menu_shell.dart';
import '../../l10n/app_localizations.dart';
import '../../core/constants/colors.dart';

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
      title: isArabic ? 'ذكرياتي' : 'My Memories',
      backgroundColor: const Color(0xFF121212),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
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
        color: const Color(0xFF1E1912),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE6C068).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
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
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exhibit,
                    style: const TextStyle(
                      color: Color(0xFFF5F1E8),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: TextStyle(
                      color: const Color(0xFFF5F1E8).withOpacity(0.6),
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
          color: const Color(0xFF121212),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE6C068).withOpacity(0.3)),
        ),
        child: Icon(icon, color: const Color(0xFFE6C068), size: 18),
      ),
    );
  }
}
