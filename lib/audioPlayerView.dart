import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioplayerView extends StatefulWidget {
  const AudioplayerView({super.key});

  @override
  State<AudioplayerView> createState() => _AudioplayerViewState();
}

class _AudioplayerViewState extends State<AudioplayerView> {
  // Audio player vars
  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });

    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        _duration = newDuration;
      });
    });

    audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        _position = newPosition;
      });
    });

    audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _position = Duration.zero;
        isPlaying = false;
      });
    });
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audio Player')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Slider(
              value: _position.inSeconds.toDouble(),
              min: 0,
              max: _duration.inSeconds.toDouble(),
              onChanged: (value) async {
                final newPosition = Duration(seconds: value.toInt());
                await audioPlayer.seek(newPosition);
                await audioPlayer.resume();
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formatDuration(_position)),
                Text(formatDuration(_duration)),
              ],
            ),
            CircleAvatar(
              radius: 30,
              child: IconButton(
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                iconSize: 30,
                onPressed: () async {
                  if (isPlaying) {
                    try {
                      await audioPlayer.pause();
                      print('Audio paused');
                    } catch (e) {
                      print('Error pausing audio: $e');
                    }
                  } else {
                    try {
                      await audioPlayer.resume();
                    } catch (e) {
                      print('Error playing audio: $e');
                    }
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
