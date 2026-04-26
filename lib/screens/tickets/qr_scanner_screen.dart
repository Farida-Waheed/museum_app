import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import '../../widgets/dialogs/branded_permission_dialog.dart';
import '../../l10n/app_localizations.dart';
import '../../app/router.dart';
import '../../models/app_session_provider.dart';
import '../../models/tour_provider.dart' as tour;
import '../../core/services/mock_data.dart';

enum QRScanMode { museumTicket, robotConnection }

class QrScannerScreen extends StatefulWidget {
  final QRScanMode mode;

  const QrScannerScreen({super.key, this.mode = QRScanMode.museumTicket});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with TickerProviderStateMixin {
  bool _isScanned = false;
  late final AnimationController _scanAnim;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _checkCameraPermission);
    _scanAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanAnim.dispose();
    super.dispose();
  }

  Future<void> _checkCameraPermission() async {
    if (kIsWeb) return;
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
            await Permission.camera.request();
          },
          onDeny: () => Navigator.pop(context),
        ),
      );
    }
  }

  void _handleScan(BarcodeCapture capture) {
    if (_isScanned) return;
    final barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        HapticFeedback.heavyImpact();
        setState(() => _isScanned = true);
        _showResultDialog(barcode.rawValue!);
        break;
      }
    }
  }

  bool _isValidMuseumQr(String code) {
    return code.startsWith('TKT-MUSEUM-') || code.startsWith('TKT-ENTRY-');
  }

  bool _isValidRobotQr(String code) {
    return code.startsWith('ROBOT-HORUS-') || code == 'HORUS-ROBOT-DEMO';
  }

  bool _isRobotTicketQr(String code) {
    return code.startsWith('ROBOT-');
  }

  bool _isMuseumTicketQr(String code) {
    return code.startsWith('TKT-');
  }

  void _handleCancel() {
    if (widget.mode == QRScanMode.robotConnection) {
      final sessionProvider = Provider.of<AppSessionProvider>(
        context,
        listen: false,
      );
      sessionProvider.cancelRobotConnection();
    }
    Navigator.pop(context);
  }

  void _simulateRobotScan() {
    if (_isScanned) return;
    setState(() => _isScanned = true);
    _showResultDialog('ROBOT-HORUS-001');
  }

  void _showResultDialog(String code) {
    final l10n = AppLocalizations.of(context)!;
    final mode = widget.mode;
    final bool isValid;
    final String messageText;
    if (mode == QRScanMode.museumTicket) {
      if (_isValidMuseumQr(code)) {
        isValid = true;
        messageText = l10n.ticketVerified;
      } else if (_isRobotTicketQr(code)) {
        isValid = false;
        messageText = l10n.robotQrInMuseumMode;
      } else {
        isValid = false;
        messageText = l10n.invalidQr;
      }
    } else {
      if (_isValidRobotQr(code)) {
        isValid = true;
        messageText = l10n.connectedReady;
      } else if (_isMuseumTicketQr(code)) {
        isValid = false;
        messageText = l10n.museumTicketInRobotMode;
      } else {
        isValid = false;
        messageText = l10n.notHorusBotQr;
      }
    }
    final sessionProvider = Provider.of<AppSessionProvider>(
      context,
      listen: false,
    );
    if (!isValid && mode == QRScanMode.robotConnection) {
      sessionProvider.failRobotConnection();
    }
    if (isValid && mode == QRScanMode.robotConnection) {
      sessionProvider.completeRobotConnection();
      final tourProvider = Provider.of<tour.TourProvider>(
        context,
        listen: false,
      );
      if (tourProvider.currentExhibitId == null) {
        tourProvider.setCurrentExhibit(
          MockDataService.getAllExhibits().first.id,
        );
      }
      tourProvider.startTour(context: context);
      tourProvider.setFollowMode(tour.FollowModeState.on);
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: l10n.scanResult,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim, secondaryAnim) {
        return Center(
          child: _ResultPopup(
            isValid: isValid,
            message: messageText,
            code: code,
            l10n: l10n,
            onClose: () {
              if (!isValid && mode == QRScanMode.robotConnection) {
                sessionProvider.cancelRobotConnection();
              }
              Navigator.pop(context);
              if (mode == QRScanMode.robotConnection && isValid) {
                Navigator.pushReplacementNamed(context, AppRoutes.liveTour);
              }
            },
            onRetry: () {
              Navigator.pop(context);
              setState(() => _isScanned = false);
            },
          ),
        );
      },
      transitionBuilder: (ctx, animation, secondary, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curved),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mode = widget.mode;
    final isArabic = l10n.localeName == 'ar';
    final title = mode == QRScanMode.robotConnection
        ? l10n.connectToHorusBot
        : l10n.scanMuseumEntryTicket;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(onDetect: _handleScan),
          const IgnorePointer(
            child: QrScannerOverlayWidget(
              borderColor: Colors.white,
              borderRadius: 24,
              borderLength: 40,
              borderWidth: 4,
              cutOutSize: 280,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.black45,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: _handleCancel,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 56,
            left: 24,
            right: 24,
            child: Text(
              mode == QRScanMode.robotConnection
                  ? l10n.scanRobotQrSubtitle
                  : l10n.scanMuseumQrSubtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.qr_code_2_rounded,
                          color: Colors.white70,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.alignQr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (widget.mode == QRScanMode.robotConnection)
            Positioned(
              bottom: 20,
              left: 24,
              right: 24,
              child: ElevatedButton(
                onPressed: _simulateRobotScan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white24,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      l10n.simulateRobotScan,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.prototypeOnly,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ResultPopup extends StatelessWidget {
  final bool isValid;
  final String code;
  final String message;
  final AppLocalizations l10n;
  final VoidCallback onClose;
  final VoidCallback onRetry;

  const _ResultPopup({
    required this.isValid,
    required this.code,
    required this.message,
    required this.l10n,
    required this.onClose,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 40,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: (isValid ? Colors.green : Colors.red).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isValid ? Icons.check_circle_rounded : Icons.error_rounded,
                color: isValid ? Colors.green : Colors.red,
                size: 72,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Ref: $code',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: onRetry,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      l10n.scanAnother,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onClose,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      l10n.done,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class QrScannerOverlayWidget extends StatelessWidget {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QrScannerOverlayWidget({
    super.key,
    this.borderColor = Colors.blue,
    this.borderWidth = 10.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 0.6),
    this.borderRadius = 10,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ColorFiltered(
          colorFilter: ColorFilter.mode(overlayColor, BlendMode.srcOut),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: cutOutSize,
                  height: cutOutSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: CustomPaint(
            size: Size(cutOutSize, cutOutSize),
            painter: _ScannerBorderPainter(
              borderColor: borderColor,
              borderWidth: borderWidth,
              borderRadius: borderRadius,
              borderLength: borderLength,
            ),
          ),
        ),
      ],
    );
  }
}

class _ScannerBorderPainter extends CustomPainter {
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final double borderLength;

  _ScannerBorderPainter({
    required this.borderColor,
    required this.borderWidth,
    required this.borderRadius,
    required this.borderLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final path = Path();
    final w = size.width;
    final h = size.height;
    final r = borderRadius;
    final l = borderLength;

    path.moveTo(0, l);
    path.lineTo(0, r);
    path.quadraticBezierTo(0, 0, r, 0);
    path.lineTo(l, 0);
    path.moveTo(w - l, 0);
    path.lineTo(w - r, 0);
    path.quadraticBezierTo(w, 0, w, r);
    path.lineTo(w, l);
    path.moveTo(w, h - l);
    path.lineTo(w, h - r);
    path.quadraticBezierTo(w, h, w - r, h);
    path.lineTo(w - l, h);
    path.moveTo(l, h);
    path.lineTo(r, h);
    path.quadraticBezierTo(0, h, 0, h - r);
    path.lineTo(0, h - l);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class QrScannerOverlayWidget extends StatelessWidget {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QrScannerOverlayWidget({
    super.key,
    this.borderColor = Colors.blue,
    this.borderWidth = 10.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 0.6),
    this.borderRadius = 10,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ColorFiltered(
          colorFilter: ColorFilter.mode(overlayColor, BlendMode.srcOut),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: cutOutSize,
                  height: cutOutSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: CustomPaint(
            size: Size(cutOutSize, cutOutSize),
            painter: _ScannerBorderPainter(
              borderColor: borderColor,
              borderWidth: borderWidth,
              borderRadius: borderRadius,
              borderLength: borderLength,
            ),
          ),
        ),
      ],
    );
  }
}

class _ScannerBorderPainter extends CustomPainter {
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final double borderLength;

  _ScannerBorderPainter({
    required this.borderColor,
    required this.borderWidth,
    required this.borderRadius,
    required this.borderLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final path = Path();
    final w = size.width;
    final h = size.height;
    final r = borderRadius;
    final l = borderLength;

    // Top Left
    path.moveTo(0, l);
    path.lineTo(0, r);
    path.quadraticBezierTo(0, 0, r, 0);
    path.lineTo(l, 0);

    // Top Right
    path.moveTo(w - l, 0);
    path.lineTo(w - r, 0);
    path.quadraticBezierTo(w, 0, w, r);
    path.lineTo(w, l);

    // Bottom Right
    path.moveTo(w, h - l);
    path.lineTo(w, h - r);
    path.quadraticBezierTo(w, h, w - r, h);
    path.lineTo(w - l, h);

    // Bottom Left
    path.moveTo(l, h);
    path.lineTo(r, h);
    path.quadraticBezierTo(0, h, 0, h - r);
    path.lineTo(0, h - l);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
