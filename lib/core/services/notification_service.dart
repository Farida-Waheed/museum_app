import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../../models/app_notification.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<AppNotification> _queue = [];
  bool _isShowing = false;
  OverlayEntry? _currentEntry;
  Timer? _dismissTimer;

  static void show(BuildContext context, AppNotification notification) {
    _instance._add(context, notification);
  }

  AppNotification? _currentShowing;

  void _add(BuildContext context, AppNotification notification) {
    // Duplicate prevention
    if (_queue.any((n) => n == notification)) return;
    if (_isShowing && _currentShowing == notification) return;

    // Smart Tip logic: only most recent
    if (notification.type == AppNotificationType.smartTip) {
      _queue.removeWhere((n) => n.type == AppNotificationType.smartTip);
    }

    // High priority can interrupt Low/Medium
    if (notification.priority == AppNotificationPriority.high) {
      if (_isShowing && _currentShowing != null && _currentShowing!.priority != AppNotificationPriority.high) {
        // Interrupt current
        if (_currentEntry != null) {
          _dismissCurrent(context, immediate: true);
        } else {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }
      }
      _queue.insert(0, notification);
    } else {
      _queue.add(notification);
    }

    _processQueue(context);
  }

  void _processQueue(BuildContext context) {
    if (_isShowing || _queue.isEmpty) return;

    final next = _queue.removeAt(0);
    _currentShowing = next;

    if (next.type == AppNotificationType.quizAvailable) {
      _showQuizModal(context, next);
    } else if (next.priority == AppNotificationPriority.high) {
      _showBanner(context, next);
    } else {
      _showSnackBar(context, next);
    }
  }

  void _showBanner(BuildContext context, AppNotification notification) {
    _isShowing = true;
    final overlay = Overlay.of(context);

    _currentEntry = OverlayEntry(
      builder: (context) => _TopBannerWidget(
        notification: notification,
        onDismiss: () => _dismissCurrent(context),
      ),
    );

    overlay.insert(_currentEntry!);

    _dismissTimer = Timer(const Duration(seconds: 6), () {
      _dismissCurrent(context);
    });
  }

  void _showSnackBar(BuildContext context, AppNotification notification) {
    _isShowing = true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.cinematicCard,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.primaryGold.withOpacity(0.3)),
        ),
        content: _NotificationContent(notification: notification, isDark: true),
      ),
    ).closed.then((_) {
      if (_currentShowing == notification) {
        _isShowing = false;
        _currentShowing = null;
        _processQueue(context);
      }
    });
  }

  void _showQuizModal(BuildContext context, AppNotification notification) {
    _isShowing = true;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Quiz",
      pageBuilder: (context, anim1, anim2) => _QuizModal(
        notification: notification,
        onAction: (taken) {
          Navigator.pop(context);
          if (taken && notification.onTap != null) {
            notification.onTap!();
          }
        },
      ),
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
    ).then((_) {
      _isShowing = false;
      _currentShowing = null;
      _processQueue(context);
    });
  }

  void _dismissCurrent(BuildContext context, {bool immediate = false}) {
    _dismissTimer?.cancel();
    if (_currentEntry != null) {
      _currentEntry!.remove();
      _currentEntry = null;
      _isShowing = false;
      _currentShowing = null;
      if (!immediate) _processQueue(context);
    }
  }
}

class _TopBannerWidget extends StatefulWidget {
  final AppNotification notification;
  final VoidCallback onDismiss;

  const _TopBannerWidget({required this.notification, required this.onDismiss});

  @override
  State<_TopBannerWidget> createState() => _TopBannerWidgetState();
}

class _TopBannerWidgetState extends State<_TopBannerWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _offsetAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: widget.onDismiss,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cinematicElevated,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryGold.withOpacity(0.5), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: _NotificationContent(notification: widget.notification, isDark: true),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationContent extends StatelessWidget {
  final AppNotification notification;
  final bool isDark;

  const _NotificationContent({required this.notification, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final gold = AppColors.primaryGold;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: gold.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(notification.icon ?? Icons.notifications_active_rounded, color: gold, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                notification.title,
                style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 15, letterSpacing: 0.5),
              ),
              const SizedBox(height: 2),
              Text(
                notification.message,
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuizModal extends StatelessWidget {
  final AppNotification notification;
  final Function(bool) onAction;

  const _QuizModal({required this.notification, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.cinematicCard,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.primaryGold.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 40),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.quiz_rounded, color: AppColors.primaryGold, size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              notification.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              notification.message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.7), height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => onAction(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: AppColors.darkInk,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("TAKE QUIZ NOW", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => onAction(false),
              child: Text("LATER", style: TextStyle(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ),
          ],
        ),
      ),
    );
  }
}
