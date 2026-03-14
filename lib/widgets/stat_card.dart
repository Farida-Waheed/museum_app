import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../core/constants/text_styles.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isVertical;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.isVertical = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cinematicCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: isVertical ? _buildVertical(context) : _buildHorizontal(context),
    );
  }

  Widget _buildVertical(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.primaryGold, size: 20),
        const SizedBox(height: 12),
        Text(
          value,
          style: AppTextStyles.statNumber(context),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.helper(context),
        ),
      ],
    );
  }

  Widget _buildHorizontal(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryGold, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: AppTextStyles.statNumber(context).copyWith(fontSize: 18),
              ),
              Text(
                label,
                style: AppTextStyles.helper(context).copyWith(fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
