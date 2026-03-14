import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/dialogs/branded_permission_dialog.dart';
import '../../l10n/app_localizations.dart';

class ArScreen extends StatefulWidget {
  const ArScreen({super.key});

  @override
  State<ArScreen> createState() => _ArScreenState();
}

class _ArScreenState extends State<ArScreen> with SingleTickerProviderStateMixin {
  bool _hasPermission = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    _checkPermission();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    if (kIsWeb) {
      setState(() {
        _hasPermission = true; // Assume true for mock on web
      });
      return;
    }
    final status = await Permission.camera.status;
    if (!status.isGranted && mounted) {
      final l10n = AppLocalizations.of(context)!;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => BrandedPermissionDialog(
          icon: Icons.camera_alt_outlined,
          title: l10n.cameraPermissionTitle,
          description: l10n.cameraPermissionDesc,
          onAllow: () async {
            Navigator.pop(context);
            final result = await Permission.camera.request();
            if (mounted) setState(() => _hasPermission = result.isGranted);
          },
          onDeny: () => Navigator.pop(context),
        ),
      );
    } else {
      setState(() {
        _hasPermission = status.isGranted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.black,
      bottomNavigationBar: const BottomNav(currentIndex: 2),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Camera Feed (Mock)
          _hasPermission 
            ? _buildMockCameraFeed() 
            : _buildPermissionError(l10n),

          // 2. Scan Reticle Overlay (Premium Feel)
          if (_hasPermission)
            const IgnorePointer(
              child: Center(
                child: _ArScanReticle(),
              ),
            ),

          // 3. AR Points
          if (_hasPermission) ...[
            _buildArPoint(180, 80, "Ancient Vase", "300 BC", Icons.history_edu),
            _buildArPoint(380, 240, "Golden Mask", "Tutankhamun", Icons.face),
            _buildArPoint(280, 150, "Robot Guide", "Moving to Hall B", Icons.smart_toy),
          ],

          // 4. Header Actions
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: CircleAvatar(
                      backgroundColor: Colors.black26,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.view_in_ar, color: Colors.redAccent, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            l10n.live.toUpperCase(),
                            style: const TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 5. Bottom Instructions
          Positioned(
            bottom: 120,
            left: 20,
            right: 20,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.scanExhibitsAR,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.followAndDiscover,
                          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMockCameraFeed() {
    return Image.asset(
      "assets/images/museum_interior.jpg", 
      fit: BoxFit.cover,
      color: Colors.black.withOpacity(0.2),
      colorBlendMode: BlendMode.darken,
      errorBuilder: (c, e, s) => Container(color: Colors.grey[900]),
    );
  }

  Widget _buildPermissionError(AppLocalizations l10n) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.videocam_off_outlined, color: Colors.grey.shade700, size: 80),
            const SizedBox(height: 24),
            Text(
              l10n.privacyPermissions,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.privacyText,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _checkPermission,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(l10n.allow),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildArPoint(double top, double left, String title, String subtitle, IconData icon) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(icon, color: Colors.white, size: 18),
                  const SizedBox(width: 10),
                  Text(title),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(20),
            ),
          );
        },
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.black),
                          ),
                          Text(
                            subtitle,
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 2,
                  height: 16,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white, Colors.white.withOpacity(0)],
                    ),
                  ),
                ),
                Container(
                  width: 14 * _pulseAnimation.value,
                  height: 14 * _pulseAnimation.value,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.8),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(color: Colors.blue.withOpacity(0.5), blurRadius: 10, spreadRadius: 2),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ArScanReticle extends StatelessWidget {
  const _ArScanReticle();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        children: [
          // Corner accents
          _ReticleCorner(quarter: 0),
          _ReticleCorner(quarter: 1),
          _ReticleCorner(quarter: 2),
          _ReticleCorner(quarter: 3),

          // Scanning line animation would go here
          const Center(
            child: Icon(Icons.add, color: Colors.white24, size: 32),
          ),
        ],
      ),
    );
  }
}

class _ReticleCorner extends StatelessWidget {
  final int quarter; // 0, 1, 2, 3
  const _ReticleCorner({required this.quarter});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: (quarter == 0 || quarter == 1) ? 0 : null,
      bottom: (quarter == 2 || quarter == 3) ? 0 : null,
      left: (quarter == 0 || quarter == 3) ? 0 : null,
      right: (quarter == 1 || quarter == 2) ? 0 : null,
      child: RotatedBox(
        quarterTurns: quarter,
        child: Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.white, width: 2),
              left: BorderSide(color: Colors.white, width: 2),
            ),
          ),
        ),
      ),
    );
  }
}
