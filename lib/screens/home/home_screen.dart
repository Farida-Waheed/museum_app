// Add this inside the Column children of home_screen.dart:

ElevatedButton.icon(
  icon: const Icon(Icons.map),
  label: const Text("Open Map"),
  onPressed: () {
    Navigator.pushNamed(context, '/map'); // Matches AppRoutes.map
  },
),

const SizedBox(height: 10),

ElevatedButton.icon(
  icon: const Icon(Icons.list),
  label: const Text("View Exhibits"),
  onPressed: () {
    Navigator.pushNamed(context, '/exhibits');
  },
),

const SizedBox(height: 10),

ElevatedButton.icon(
  icon: const Icon(Icons.settings),
  label: const Text("Settings"),
  onPressed: () {
    Navigator.pushNamed(context, '/settings');
  },
),