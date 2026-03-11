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
      duration: const Duration(milliseconds: 280),
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

    // Theme-based colors alignment
    Color surfaceColor;
    Color textColor;
    Color secondaryTextColor;
    Color helperTextColor;
    Color goldAccent = AppColors.primaryGold;
    Color borderColor;
    Color overlayColor = Colors.black.withOpacity(0.72);

    if (widget.isHighContrast) {
      surfaceColor = Colors.black;
      textColor = Colors.white;
      secondaryTextColor = Colors.white;
      helperTextColor = Colors.white;
      goldAccent = const Color(0xFFFFD700); // High visibility gold
      borderColor = goldAccent;
    } else if (isDark) {
      surfaceColor = AppColors.darkSurface;
      textColor = const Color(0xFFF5F1E8);
      secondaryTextColor = Colors.white.withOpacity(0.82);
      helperTextColor = AppColors.helperText;
      borderColor = AppColors.primaryGold;
    } else {
      // Light Mode (Warm Ivory/Sandstone)
      surfaceColor = const Color(0xFFF7F2E8);
      textColor = const Color(0xFF2A2118);
      secondaryTextColor = const Color(0xFF5C5143);
      helperTextColor = const Color(0xFF7A6E60);
      goldAccent = const Color(0xFFC9A34A);
      borderColor = goldAccent.withOpacity(0.15);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background overlay
          Positioned.fill(
            child: GestureDetector(
              onTap: widget.onDeny,
              child: Container(color: overlayColor),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: const EdgeInsets.symmetric(horizontal: 40),
                  elevation: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: borderColor,
                        width: widget.isHighContrast ? 2.0 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        ),
                        if (isDark && !widget.isHighContrast)
                          BoxShadow(
                            color: goldAccent.withOpacity(0.05),
                            blurRadius: 40,
                            spreadRadius: 2,
                          ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Redesigned Icon (Gold pin with glow)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: goldAccent.withOpacity(0.1),
                          ),
                          child: Icon(
                            Icons.location_on,
                            size: 32,
                            color: goldAccent,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Title
                        Text(
                          l10n.allowLocationAccess,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Body
                        Text(
                          l10n.locationPermissionBody,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 14.5,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Helper/Privacy
                        Text(
                          l10n.dataReassurance,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: helperTextColor,
                            fontSize: 12.5,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Actions Row
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: widget.onDeny,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  side: BorderSide(color: goldAccent, width: 1.2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  l10n.notNow,
                                  style: TextStyle(
                                    color: goldAccent,
                                    fontSize: 14.5,
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
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  elevation: 4,
                                  shadowColor: goldAccent.withOpacity(0.3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  l10n.allow,
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w900,
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
            ),
          ),
        ],
      ),
    );
  }
}
