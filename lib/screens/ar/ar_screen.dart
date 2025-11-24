import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
// Removed 'package:camera/camera.dart' because we are using a mock feed

class ArScreen extends StatefulWidget {
  const ArScreen({super.key});

  @override
  State<ArScreen> createState() => _ArScreenState();
}

class _ArScreenState extends State<ArScreen> {
  bool _hasPermission = false;
  
  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    // Request camera permission (even for mock, it adds realism)
    final status = await Permission.camera.request();
    setState(() {
      _hasPermission = status.isGranted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Camera Feed / Placeholder
          _hasPermission 
            ? _buildMockCameraFeed() 
            : _buildPermissionError(),

          // 2. AR Overlays (Floating Data Points)
          if (_hasPermission) ...[
            _buildArPoint(100, 150, "Ancient Vase", "300 BC"),
            _buildArPoint(300, 400, "Golden Mask", "Tutankhamun"),
            _buildArPoint(200, 300, "Robot Guide", "Moving to Hall B"),
          ],

          // 3. UI Overlay (Back button & Header)
          Positioned(
            top: 50,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          const Positioned(
            top: 60,
            right: 20,
            child: Chip(
              label: Text("AR Mode Active"),
              backgroundColor: Colors.redAccent,
              labelStyle: TextStyle(color: Colors.white),
              avatar: Icon(Icons.view_in_ar, color: Colors.white, size: 16),
            ),
          ),
          
          // 4. Bottom Hint
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Point your camera at exhibits to reveal info",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMockCameraFeed() {
    // Using an image to simulate the camera view for the emulator
    return Image.asset(
      "assets/images/museum_interior.jpg", 
      fit: BoxFit.cover,
      color: Colors.black.withValues(alpha: 0.1), // Slight dim for text visibility
      colorBlendMode: BlendMode.darken,
      errorBuilder: (c, e, s) => Container(color: Colors.grey[800]),
    );
  }

  Widget _buildPermissionError() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videocam_off, color: Colors.grey, size: 64),
            const SizedBox(height: 16),
            const Text("Camera Permission Required", style: TextStyle(color: Colors.white)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _checkPermission,
              child: const Text("Grant Permission"),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildArPoint(double top, double left, String title, String subtitle) {
    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Scanned: $title")));
        },
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4)],
              ),
              child: Column(
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
            Container(
              width: 2,
              height: 20,
              color: Colors.white,
            ),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}