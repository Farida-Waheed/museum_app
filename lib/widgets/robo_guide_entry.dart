import 'package:flutter/material.dart';
import 'dialogs/chat_popup.dart';

class RoboGuideEntry extends StatelessWidget {
  const RoboGuideEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showDialog(context: context, builder: (context) => const ChatPopup());
      },
      tooltip: 'Ask the Guide',
      child: const Icon(Icons.chat),
    );
  }
}
