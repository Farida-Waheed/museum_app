import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioButton extends StatefulWidget {
  final String assetPath;
  final String? label;
  final bool compact;

  const AudioButton({
    super.key,
    required this.assetPath,
    this.label,
    this.compact = false,
  });

  @override
  State<AudioButton> createState() => _AudioButtonState();
}

class _AudioButtonState extends State<AudioButton> {
  late final AudioPlayer _player;
  bool _isPlaying = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();

    _player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() => _isPlaying = false);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    try {
      if (_isPlaying) {
        await _player.stop();
        if (!mounted) return;
        setState(() => _isPlaying = false);
      } else {
        await _player.play(AssetSource(widget.assetPath));
        if (!mounted) return;
        setState(() => _isPlaying = true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.label ?? (_isPlaying ? 'Stop Audio' : 'Play Audio');

    if (widget.compact) {
      return IconButton(
        onPressed: _toggle,
        icon: _isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(_isPlaying ? Icons.stop : Icons.volume_up),
        tooltip: text,
      );
    }

    return ElevatedButton.icon(
      onPressed: _toggle,
      icon: _isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(_isPlaying ? Icons.stop : Icons.volume_up),
      label: Text(text),
    );
  }
}
