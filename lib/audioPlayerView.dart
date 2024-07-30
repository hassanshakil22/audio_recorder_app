import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class AudioplayerView extends StatefulWidget {
  const AudioplayerView({super.key});

  @override
  State<AudioplayerView> createState() => _AudioplayerViewState();
}

class _AudioplayerViewState extends State<AudioplayerView> {
  final AudioPlayer player = AudioPlayer();
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  List<File> audioFiles = [];

  void handlePlayPause() {
    if (player.playing) {
      player.pause();
    } else {
      player.play();
    }
  }

  void handleSeek(double value) {
    player.seek(Duration(seconds: value.toInt()));
  }

  @override
  void initState() {
    super.initState();
    fetchAudioFiles();

    player.setUrl(
        'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3');

    player.positionStream.listen((p) {
      setState(() {
        _position = p;
      });
    });

    player.durationStream.listen((d) {
      setState(() {
        _duration = d ?? Duration.zero;
      });
    });

    player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          _position = Duration.zero;
        });
        player.pause();
        player.seek(_position);
      }
    });
  }

  Future fetchAudioFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final recordingsDir = Directory(path.join(directory.path, 'recordings'));
    if (await recordingsDir.exists()) {
      final files = recordingsDir.listSync();
      setState(() {
        audioFiles = files.whereType<File>().toList();
      });
    }
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
      backgroundColor: Colors.brown.shade300,
      appBar: AppBar(
          title: const Text('Audio Player'),
          backgroundColor: Colors.brown.shade500),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: audioFiles.length,
                itemBuilder: (context, index) {
                  final audioFile = audioFiles[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: ListTile(
                      title: Text(
                        path.basename(audioFile.path),
                        style: TextStyle(color: Colors.black),
                      ),
                      trailing: IconButton(
                          onPressed: () async {
                            print("Deleting file: ${audioFile.path}");
                            try {
                              await audioFile.delete();
                              await fetchAudioFiles();
                            } catch (e) {
                              print("error deleting file : $e");
                            }
                          },
                          icon: Icon(
                            Icons.delete,
                            color: Colors.brown.shade800,
                          )),
                      tileColor: Colors.brown.shade200,
                      onTap: () async {
                        print(
                            "Attempting to play audio file: ${audioFile.path}");

                        try {
                          await player.stop();

                          await player.setFilePath(audioFile.path);
                          player.play();

                          print("Playback started.");
                        } catch (e, stackTrace) {
                          print("Error playing audio file: $e");
                          print("Stack trace: $stackTrace");
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            Slider(
                activeColor: Colors.brown.shade500,
                value: _position.inSeconds.toDouble(),
                min: 0,
                max: _duration.inSeconds.toDouble(),
                onChanged: handleSeek),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatDuration(_position),
                  style: const TextStyle(color: Colors.black),
                ),
                Text(
                  formatDuration(_duration),
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.brown.shade600,
              foregroundColor: Colors.brown.shade200,
              child: IconButton(
                  icon: Icon(player.playing ? Icons.pause : Icons.play_arrow),
                  iconSize: 30,
                  onPressed: handlePlayPause),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
