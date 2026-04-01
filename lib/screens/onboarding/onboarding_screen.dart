import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../core/constants/text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../models/user_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (prefs.language == 'en')
                          const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white70,
                          ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'ar',
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("🇪🇬 ", style: TextStyle(fontSize: 18)),
                        const Flexible(
                          child: Text(
                            "العربية",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (prefs.language == 'ar')
                          const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white70,
                          ),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: glassSurfaceDecoration,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.language, size: 16, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        l10n.language,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
          );
        },
      ),
    );
  }
}
