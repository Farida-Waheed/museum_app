import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../models/app_session_provider.dart';
import '../../models/exhibit_provider.dart';
import '../../models/tour_preferences.dart';

class TourCustomizationScreen extends StatefulWidget {
  const TourCustomizationScreen({super.key});

  @override
  State<TourCustomizationScreen> createState() =>
      _TourCustomizationScreenState();
}

class _TourCustomizationScreenState extends State<TourCustomizationScreen> {
  final Set<String> _selectedExhibitIds = {};
  int _durationMinutes = 60; // Default 1 hour

  @override
  void initState() {
    super.initState();
    // Load existing preferences if any
    final sessionProvider = context.read<AppSessionProvider>();
    if (sessionProvider.tourPreferences != null) {
      _selectedExhibitIds.addAll(
        sessionProvider.tourPreferences!.selectedExhibitIds,
      );
      _durationMinutes = sessionProvider.tourPreferences!.durationMinutes;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final exhibitProvider = context.watch<ExhibitProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'تخصيص الجولة' : 'Customize Tour'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isArabic ? 'اختر المعروضات' : 'Select Exhibits',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: exhibitProvider.exhibits.length,
                  itemBuilder: (context, index) {
                    final exhibit = exhibitProvider.exhibits[index];
                    final isSelected = _selectedExhibitIds.contains(exhibit.id);

                    return Card(
                      child: CheckboxListTile(
                        title: Text(exhibit.getName(isArabic ? 'ar' : 'en')),
                        subtitle: Text(
                          exhibit.getDescription(isArabic ? 'ar' : 'en'),
                        ),
                        value: isSelected,
                        onChanged: (selected) {
                          setState(() {
                            if (selected == true) {
                              _selectedExhibitIds.add(exhibit.id);
                            } else {
                              _selectedExhibitIds.remove(exhibit.id);
                            }
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isArabic ? 'مدة الجولة (دقائق)' : 'Tour Duration (minutes)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Slider(
                value: _durationMinutes.toDouble(),
                min: 30,
                max: 180,
                divisions: 5,
                label: '$_durationMinutes min',
                onChanged: (value) {
                  setState(() {
                    _durationMinutes = value.toInt();
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _selectedExhibitIds.isNotEmpty
                    ? _continueToQrScan
                    : null,
                child: Text(
                  isArabic ? 'متابعة لمسح QR' : 'Continue to QR Scan',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _continueToQrScan() {
    final preferences = TourPreferences(
      selectedExhibitIds: _selectedExhibitIds.toList(),
      durationMinutes: _durationMinutes,
    );

    context.read<AppSessionProvider>().setTourPreferences(preferences);

    // Navigate to QR scanner for robot connection
    Navigator.of(context).pushNamed(AppRoutes.qrScan);
  }
}
