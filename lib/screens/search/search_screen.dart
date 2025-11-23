import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_preferences.dart';
import '../../core/services/mock_data.dart';
import '../../models/exhibit.dart';
import '../../app/router.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Exhibit> _allExhibits = [];
  List<Exhibit> _filteredExhibits = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _allExhibits = MockDataService.getAllExhibits();
    _filteredExhibits = _allExhibits;
  }

  void _filterExhibits(String query) {
    final prefs = Provider.of<UserPreferencesModel>(context, listen: false);
    final isArabic = prefs.language == 'ar';

    setState(() {
      if (query.isEmpty) {
        _filteredExhibits = _allExhibits;
      } else {
        _filteredExhibits = _allExhibits.where((exhibit) {
          final name = exhibit.getName(prefs.language).toLowerCase();
          return name.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _requestRobot(BuildContext context, Exhibit exhibit) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Robot requested to go to: ${exhibit.nameEn}"),
        action: SnackBarAction(label: "VIEW ON MAP", onPressed: () {
           Navigator.pushNamed(context, AppRoutes.map);
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<UserPreferencesModel>(context);
    final isArabic = prefs.language == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? "البحث عن القطع الأثرية" : "Search Artifacts"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterExhibits,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: isArabic ? "ابحث بالاسم..." : "Search by name...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredExhibits.length,
              itemBuilder: (context, index) {
                final exhibit = _filteredExhibits[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Text(exhibit.nameEn.substring(0, 1)),
                  ),
                  title: Text(exhibit.getName(prefs.language)),
                  subtitle: Text(isArabic ? "انقر للتفاصيل أو اطلب الروبوت" : "Tap for details or Request Robot"),
                  trailing: IconButton(
                    icon: const Icon(Icons.smart_toy, color: Colors.orange),
                    tooltip: "Request Robot Here",
                    onPressed: () => _requestRobot(context, exhibit),
                  ),
                  onTap: () {
                    // Navigate to details
                     Navigator.pushNamed(context, AppRoutes.exhibitDetails, arguments: exhibit);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}