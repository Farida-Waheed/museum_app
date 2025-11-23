// inside lib/app/app.dart

return MaterialApp(
  title: 'Museum Guide',
  debugShowCheckedModeBanner: false,
  theme: prefs.isHighContrast ? highContrastTheme : lightTheme,
  locale: Locale(prefs.language),
  
  // --- ADD THIS SECTION ---
  initialRoute: AppRoutes.home,
  routes: AppRoutes.getRoutes(),
  // ------------------------

  builder: (context, child) {
     // ... keep existing builder logic ...
  },
  // Remove 'home: const HomeScreen(),' because 'initialRoute' handles it now
);