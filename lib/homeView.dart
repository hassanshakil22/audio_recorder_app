import 'package:audiorecorder_app/audioPlayerView.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

class Homeview extends StatefulWidget {
  const Homeview({super.key});

  @override
  State<Homeview> createState() => _HomeviewState();
}

String formatDuration(Duration duration) {
  String minutes = duration.inMinutes.remainder(60).toString().padLeft(2, "0");
  String seconds = duration.inSeconds.remainder(60).toString().padLeft(2, "0");
  String milliseconds =
      duration.inMilliseconds.remainder(100).toString().padLeft(2, "0");
  return "$minutes:$seconds:$milliseconds";
}

class _HomeviewState extends State<Homeview> {
  String? pathToAudio;
  FlutterSoundRecorder recorder = FlutterSoundRecorder();
  String timerText = "00:00:00";
  bool isRecorderReady = false;

  Future start() async {
    if (!isRecorderReady) return;

    final directory = await getApplicationDocumentsDirectory();
    final recordingsDir = Directory(
        path.join(directory.path, 'recordings')); //creating a directory
    if (!await recordingsDir.exists()) {
      await recordingsDir.create(recursive: true);
    }
    final audioFilePath = path.join(recordingsDir.path,
        'audio_${DateTime.now().millisecondsSinceEpoch}.wav');

    try {
      await recorder.startRecorder(
        toFile: audioFilePath,
      );
      setState(() {
        pathToAudio = audioFilePath;
      });
      print("Recording started: $audioFilePath");
    } catch (e) {
      print("Error starting recorder: $e");
    }
  }

  Future stop() async {
    if (!isRecorderReady) return;

    try {
      await recorder.stopRecorder();
      if (pathToAudio != null) {
        final audiofile = File(pathToAudio!);
        print("Recorded Audio: $audiofile");
      } else {
        print("Recorder stopped but path is null");
      }
    } catch (e) {
      print("Error stopping recorder: $e");
    }
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    super.dispose();
  }

  initializer() async {
    final status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      throw "Microphone permissions denied";
    }

    await recorder.openRecorder();
    setState(() {
      isRecorderReady = true;
    });

    recorder.setSubscriptionDuration(const Duration(milliseconds: 1));
  }

  @override
  void initState() {
    super.initState();
    initializer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown.shade300,
      appBar: AppBar(
        title: const Text("Audio Recorder App"),
        backgroundColor: Colors.brown.shade500,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: StreamBuilder<RecordingDisposition>(
                stream: recorder.onProgress,
                builder: (context, snapshot) {
                  final duration = snapshot.hasData
                      ? snapshot.data!.duration
                      : Duration.zero;
                  return Text(
                    formatDuration(duration),
                    style: const TextStyle(fontSize: 60),
                  );
                }),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () async {
                  if (recorder.isRecording) {
                    await stop();
                  } else {
                    await start();
                  }
                  setState(() {});
                },
                icon: Icon(recorder.isRecording ? Icons.stop : Icons.mic),
                iconSize: 80,
              ),
            ],
          ),
          ElevatedButton(
              onPressed: () async {
                await Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AudioplayerView()));
              },
              child: const Text("Go to Audios"))
        ],
      ),
    );
  }
}
