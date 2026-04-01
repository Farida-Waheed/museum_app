import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../core/constants/app_styles.dart';
import '../../models/photo_memory.dart';

class MyPhotosScreen extends StatelessWidget {
  const MyPhotosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for demonstration
    final List<PhotoMemory> photos = [
      PhotoMemory(
        id: '1',
        tourId: 'tour_123',
        imageUrl: 'assets/images/pharaoh_head.jpg',
        location: 'Tutankhamun Gallery',
        date: DateTime.now(),
        robotId: 'horus_01',
      ),
      PhotoMemory(
        id: '2',
        tourId: 'tour_123',
        imageUrl: 'assets/images/hieroglyphs.jpg',
        location: 'Ancient Scripts Wing',
        date: DateTime.now(),
        robotId: 'horus_01',
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Horus Memories".toUpperCase(),
          style: AppTextStyles.displayScreenTitle(context).copyWith(fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryGold),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: photos.length,
        itemBuilder: (context, index) {
          final photo = photos[index];
          return _PhotoCard(photo: photo);
        },
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final PhotoMemory photo;
  const _PhotoCard({required this.photo});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppStyles.cardDecoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppStyles.innerRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(photo.imageUrl, fit: BoxFit.cover),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                        ),
                      ),
                      child: Text(
                        photo.location,
                        style: AppTextStyles.metadata(context).copyWith(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.share, color: AppColors.primaryGold, size: 18),
                  const Icon(Icons.download, color: AppColors.primaryGold, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
