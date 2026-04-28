import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_menu_shell.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../models/app_session_provider.dart';
import '../../models/tour_memory.dart';

class MemoriesScreen extends StatelessWidget {
  const MemoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final sessionProvider = context.watch<AppSessionProvider>();
    final memories = sessionProvider.tourMemories;

    return AppMenuShell(
      title: (isArabic ? 'ذكرياتي' : 'My Memories').toUpperCase(),
      backgroundColor: AppColors.cinematicBackground,
      body: memories.isEmpty
          ? Center(
              child: Text(
                isArabic ? 'لا توجد ذكريات بعد' : 'No memories yet',
                style: AppTextStyles.bodyPrimary(context),
              ),
            )
          : GridView.builder(
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
                return _MemoryCard(memory: memory);
              },
            ),
    );
  }
}

class _MemoryCard extends StatelessWidget {
  final TourMemory memory;

  const _MemoryCard({required this.memory});

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
            if (memory.imagePath != null)
              Expanded(
                child: Image.asset(
                  memory.imagePath!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              Expanded(
                child: Container(
                  color: AppColors.primaryGold.withOpacity(0.1),
                  child: const Icon(Icons.photo, size: 48),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    memory.exhibitName,
                    style: AppTextStyles.displayArtifactTitle(
                      context,
                    ).copyWith(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${memory.timestamp.day}/${memory.timestamp.month}/${memory.timestamp.year}',
                    style: AppTextStyles.metadata(
                      context,
                    ).copyWith(fontSize: 11),
                  ),
                  if (memory.note != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      memory.note!,
                      style: AppTextStyles.metadata(
                        context,
                      ).copyWith(fontSize: 10),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
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
