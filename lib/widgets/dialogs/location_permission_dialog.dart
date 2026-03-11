import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../core/constants/colors.dart';

class LocationPermissionDialog extends StatefulWidget {
  final VoidCallback onAllow;
  final VoidCallback onDeny;
  final bool isHighContrast;

  const LocationPermissionDialog({
    super.key,
    required this.onAllow,
    required this.onDeny,
    this.isHighContrast = false,
  });

  @override
  State<LocationPermissionDialog> createState() => _LocationPermissionDialogState();
}

class _LocationPermissionDialogState extends State<LocationPermissionDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme-based colors
    Color surfaceColor;
    Color textColor;
    Color mutedTextColor;
    Color goldAccent = const Color(0xFFD4AF37); // Gold accent
    Color borderColor;

    if (widget.isHighContrast) {
      surfaceColor = Colors.black;
      textColor = Colors.white;
      mutedTextColor = Colors.white;
      goldAccent = const Color(0xFFFFD700); // High visibility gold
      borderColor = goldAccent;
    } else if (isDark) {
      surfaceColor = const Color(0xFF1E1E1E);
      textColor = Colors.white;
      mutedTextColor = const Color(0xFFBDBDBD);
      borderColor = AppColors.primaryGold.withOpacity(0.3);
    } else {
      surfaceColor = Colors.white;
      textColor = const Color(0xFF1E1912);
      mutedTextColor = const Color(0xFF6B6358);
      borderColor = AppColors.primaryGold.withOpacity(0.2);
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderColor, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 40,
                  color: goldAccent,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.allowLocationAccess,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.locationPermissionBody,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor.withOpacity(0.9),
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.dataReassurance,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: mutedTextColor,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.onDeny,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: goldAccent),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          l10n.notNow,
                          style: TextStyle(
                            color: goldAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: widget.onAllow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: goldAccent,
                          foregroundColor: isDark || widget.isHighContrast ? AppColors.darkInk : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          l10n.allow,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
