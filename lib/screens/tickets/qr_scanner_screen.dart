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
import '../../models/auth_provider.dart';
import '../../models/tour_provider.dart' as tour;
import '../../core/constants/colors.dart';
import '../../core/constants/text_styles.dart';
import '../../services/robot_pairing_service.dart';
import '../../services/ticket_repository.dart';

enum QRScanMode { museumTicket, robotConnection }

class QrScannerScreen extends StatefulWidget {
  final QRScanMode mode;
  final String? robotTourTicketId;

  const QrScannerScreen({
    super.key,
    this.mode = QRScanMode.museumTicket,
    this.robotTourTicketId,
  });

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with TickerProviderStateMixin {
  bool _isScanned = false;
  late final AnimationController _scanAnim;
  final RobotPairingService _robotPairingService = RobotPairingService();
  final TicketRepository _ticketRepository = TicketRepository();

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

  bool _isRobotTicketQr(String code) {
    return code.startsWith('ROBOT-') || code.startsWith('TKT-ROBOT-');
  }

  bool _isMuseumTicketQr(String code) {
    return code.startsWith('TKT-');
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  Future<void> _showResultDialog(String code) async {
    final l10n = AppLocalizations.of(context)!;
    final mode = widget.mode;
    final authProvider = context.read<AuthProvider>();
    final sessionProvider = context.read<AppSessionProvider>();
    final tourProvider = context.read<tour.TourProvider>();
    late final _ScanResult result;

    if (mode == QRScanMode.museumTicket) {
      if (_isRobotTicketQr(code)) {
        result = _ScanResult(
          isValid: false,
          title: l10n.invalidQr,
          message: l10n.robotQrInMuseumMode,
          primaryLabel: l10n.done,
        );
      } else {
        if (!authProvider.isLoggedIn || authProvider.currentUser == null) {
          result = _ScanResult(
            isValid: false,
            title: l10n.qrSignInRequiredTitle,
            message: l10n.qrMuseumSignInRequiredMessage,
            primaryLabel: l10n.done,
          );
        } else {
          try {
            await _ticketRepository.validateMuseumTicketQr(
              userId: authProvider.currentUser!.id,
              scannedCode: code,
            );
            result = _ScanResult(
              isValid: true,
              title: l10n.qrEntryVerifiedTitle,
              message: l10n.qrEntryVerifiedMessage,
              primaryLabel: l10n.done,
            );
          } on TicketRepositoryException catch (e) {
            result = _ScanResult(
              isValid: false,
              title: l10n.invalidQr,
              message: _ticketValidationMessage(l10n, e),
              primaryLabel: l10n.done,
            );
          }
        }
      }
    } else {
      final robotId = _robotPairingService.parseRobotId(code);
      if (robotId == null) {
        sessionProvider.failRobotConnection();
        tourProvider.setConnectionState(tour.RobotConnectionState.disconnected);
        result = _ScanResult(
          isValid: false,
          title: l10n.invalidQr,
          message: _isMuseumTicketQr(code)
              ? l10n.museumTicketInRobotMode
              : l10n.notHorusBotQr,
          primaryLabel: l10n.done,
        );
      } else if (!authProvider.isLoggedIn || authProvider.currentUser == null) {
        result = _ScanResult(
          isValid: false,
          title: l10n.qrSignInRequiredTitle,
          message: l10n.qrSignInRequiredMessage,
          primaryLabel: l10n.done,
          shouldMutateConnectionFailure: false,
        );
      } else {
        try {
          final pairing = await _robotPairingService.pairRobot(
            userId: authProvider.currentUser!.id,
            scannedCode: code,
            robotTourTicketId: widget.robotTourTicketId,
          );
          if (!mounted) return;
          sessionProvider.completeRobotConnection(
            robotId: pairing.robotId,
            sessionId: pairing.sessionId,
            nextExhibitId: pairing.nextExhibitId,
            selectedExhibitIds: pairing.selectedExhibitIds,
          );
          tourProvider.preparePairedRobotTour(
            robotId: pairing.robotId,
            sessionId: pairing.sessionId,
            selectedExhibitIds: pairing.selectedExhibitIds,
            nextExhibitId: pairing.nextExhibitId,
          );
          result = _ScanResult(
            isValid: true,
            title: l10n.qrRobotConnectedTitle,
            message: l10n.qrRobotConnectedMessage,
            primaryLabel: l10n.qrOpenLiveTour,
            opensLiveTour: true,
          );
        } on RobotPairingException catch (e) {
          if (!mounted) return;
          sessionProvider.failRobotConnection();
          tourProvider.setConnectionState(
            tour.RobotConnectionState.disconnected,
          );
          result = _ScanResult(
            isValid: false,
            title: _pairingErrorTitle(l10n, e.code),
            message: _pairingErrorMessage(l10n, e.code),
            primaryLabel: l10n.done,
          );
        } catch (_) {
          if (!mounted) return;
          sessionProvider.failRobotConnection();
          tourProvider.setConnectionState(
            tour.RobotConnectionState.disconnected,
          );
          result = _ScanResult(
            isValid: false,
            title: l10n.invalidQr,
            message: l10n.qrPairingUnknownMessage,
            primaryLabel: l10n.done,
          );
        }
      }
    }

    if (!mounted) return;
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: l10n.scanResult,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim, secondaryAnim) {
        return Center(
          child: _ResultPopup(
            result: result,
            code: code,
            l10n: l10n,
            onClose: () {
              if (!result.isValid &&
                  mode == QRScanMode.robotConnection &&
                  result.shouldMutateConnectionFailure) {
                sessionProvider.cancelRobotConnection();
              }
              Navigator.pop(context);
              if (mode == QRScanMode.robotConnection && result.opensLiveTour) {
                Navigator.pushReplacementNamed(context, AppRoutes.liveTour);
              } else if (mode == QRScanMode.museumTicket && result.isValid) {
                Navigator.pop(context);
              } else if (!result.isValid) {
                setState(() => _isScanned = false);
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

  String _pairingErrorTitle(
    AppLocalizations l10n,
    RobotPairingFailureCode code,
  ) {
    switch (code) {
      case RobotPairingFailureCode.signInRequired:
        return l10n.qrSignInRequiredTitle;
      case RobotPairingFailureCode.robotTourTicketRequired:
        return l10n.qrRobotTicketRequiredTitle;
      case RobotPairingFailureCode.ambiguousRobotTourTicket:
        return l10n.qrRobotTicketRequiredTitle;
      case RobotPairingFailureCode.robotNotFound:
        return l10n.qrRobotNotFoundTitle;
      case RobotPairingFailureCode.robotUnavailable:
        return l10n.qrRobotUnavailableTitle;
      case RobotPairingFailureCode.robotBusy:
        return l10n.qrRobotBusyTitle;
      case RobotPairingFailureCode.permissionDenied:
        return l10n.qrPairingPermissionDeniedTitle;
      case RobotPairingFailureCode.invalidQr:
      case RobotPairingFailureCode.network:
      case RobotPairingFailureCode.unknown:
        return l10n.invalidQr;
    }
  }

  String _pairingErrorMessage(
    AppLocalizations l10n,
    RobotPairingFailureCode code,
  ) {
    switch (code) {
      case RobotPairingFailureCode.signInRequired:
        return l10n.qrSignInRequiredMessage;
      case RobotPairingFailureCode.robotTourTicketRequired:
        return l10n.qrRobotTicketRequiredMessage;
      case RobotPairingFailureCode.ambiguousRobotTourTicket:
        return 'Please select a robot tour ticket from My Tickets before pairing.';
      case RobotPairingFailureCode.robotNotFound:
        return l10n.qrRobotNotFoundMessage;
      case RobotPairingFailureCode.robotUnavailable:
        return l10n.qrRobotUnavailableMessage;
      case RobotPairingFailureCode.robotBusy:
        return l10n.qrRobotBusyMessage;
      case RobotPairingFailureCode.permissionDenied:
        return l10n.qrPairingPermissionDeniedMessage;
      case RobotPairingFailureCode.network:
        return l10n.qrPairingNetworkMessage;
      case RobotPairingFailureCode.invalidQr:
        return l10n.notHorusBotQr;
      case RobotPairingFailureCode.unknown:
        return l10n.qrPairingUnknownMessage;
    }
  }

  String _ticketValidationMessage(
    AppLocalizations l10n,
    TicketRepositoryException error,
  ) {
    switch (error.code) {
      case 'museum-ticket-not-found':
        return l10n.qrMuseumTicketNotFoundMessage;
      case 'ticket-user-mismatch':
        return l10n.qrMuseumTicketWrongUserMessage;
      case 'ticket-not-active':
        return l10n.qrMuseumTicketInactiveMessage;
      case 'ticket-date-passed':
        return l10n.qrMuseumTicketExpiredMessage;
      default:
        return l10n.qrMuseumValidationFailedMessage;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mode = widget.mode;
    final isArabic = l10n.localeName == 'ar';
    final title = mode == QRScanMode.robotConnection
        ? l10n.qrRobotPairingTitle
        : l10n.qrMuseumEntryTitle;
    final subtitle = mode == QRScanMode.robotConnection
        ? l10n.qrRobotPairingSubtitle
        : l10n.qrMuseumEntrySubtitle;
    if (kIsWeb && mode == QRScanMode.robotConnection) {
      return Scaffold(
        backgroundColor: AppColors.cinematicBackground,
        body: Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Robot pairing is available only in the mobile app.',
                textAlign: TextAlign.center,
                style: AppTextStyles.displaySectionTitle(
                  context,
                ).copyWith(color: AppColors.primaryGold, fontSize: 22),
              ),
            ),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Stack(
          children: [
            MobileScanner(onDetect: _handleScan),
            const IgnorePointer(
              child: QrScannerOverlayWidget(
                borderColor: AppColors.primaryGold,
                borderRadius: 24,
                borderLength: 40,
                borderWidth: 4,
                cutOutSize: 280,
              ),
            ),
            PositionedDirectional(
              top: MediaQuery.of(context).padding.top + 10,
              start: 16,
              end: 16,
              child: Row(
                textDirection: Directionality.of(context),
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: _handleCancel,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.displaySectionTitle(
                        context,
                      ).copyWith(color: Colors.white, fontSize: 19),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
            ),
            PositionedDirectional(
              top: MediaQuery.of(context).padding.top + 60,
              start: 24,
              end: 24,
              child: Text(
                subtitle,
                style: AppTextStyles.bodyPrimary(
                  context,
                ).copyWith(color: Colors.white70, height: 1.35),
                textAlign: TextAlign.center,
              ),
            ),
            PositionedDirectional(
              bottom: 42,
              start: 20,
              end: 20,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.goldBorder(0.18)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        textDirection: Directionality.of(context),
                        children: [
                          const Icon(
                            Icons.qr_code_2_rounded,
                            color: AppColors.primaryGold,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              l10n.qrAlignCode,
                              style: AppTextStyles.metadata(
                                context,
                              ).copyWith(color: Colors.white),
                              textAlign: TextAlign.start,
                            ),
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
      ),
    );
  }
}

class _ScanResult {
  const _ScanResult({
    required this.isValid,
    required this.title,
    required this.message,
    required this.primaryLabel,
    this.opensLiveTour = false,
    this.shouldMutateConnectionFailure = true,
  });

  final bool isValid;
  final String title;
  final String message;
  final String primaryLabel;
  final bool opensLiveTour;
  final bool shouldMutateConnectionFailure;
}

class _ResultPopup extends StatelessWidget {
  final _ScanResult result;
  final String code;
  final AppLocalizations l10n;
  final VoidCallback onClose;
  final VoidCallback onRetry;

  const _ResultPopup({
    required this.result,
    required this.code,
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
          color: AppColors.cinematicCard,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.goldBorder(0.18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
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
                color: (result.isValid ? Colors.green : Colors.red).withValues(
                  alpha: 0.12,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                result.isValid
                    ? Icons.check_circle_rounded
                    : Icons.error_rounded,
                color: result.isValid ? Colors.green : Colors.red,
                size: 72,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              result.title,
              style: AppTextStyles.displaySectionTitle(
                context,
              ).copyWith(color: AppColors.primaryGold, fontSize: 22),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              result.message,
              style: AppTextStyles.bodyPrimary(
                context,
              ).copyWith(color: AppColors.bodyText, height: 1.35),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '${l10n.qrReference}: $code',
              style: AppTextStyles.metadata(
                context,
              ).copyWith(color: AppColors.neutralMedium),
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
                      style: AppTextStyles.buttonLabel(
                        context,
                      ).copyWith(color: AppColors.primaryGold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onClose,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                      foregroundColor: AppColors.darkInk,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      result.primaryLabel,
                      style: AppTextStyles.buttonLabel(context),
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
