/*
import 'package:flutter/material.dart';

import 'package:video_player/video_player.dart';

// import 'text_to_speech.dart';
import 'voice_background.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HWG Video Player',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: VideoApp(title: 'HWG Video Player'),
    );
  }
}

class VideoApp extends StatefulWidget {
  VideoApp({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  VideoPlayerController _controller;
  VoiceBackgroundSTT vbs;

  @override
  void initState() {
    super.initState();
    vbs = VoiceBackgroundSTT();
    vbs.startListening();
    vbs.listenToCommands({"play": play, "pause": pause, "vor": forward, "zurück": backward});
    _controller =
        VideoPlayerController.network('https://www.sample-videos.com/video123/mp4/720/big_buck_bunny_720p_20mb.mp4')
          ..initialize().then((_) {
            // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
            setState(() {});
          });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HWG Video Player',
      home: Scaffold(
        body: Center(
          child: _controller.value.initialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : Container(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _controller.value.isPlaying ? _controller.pause() : _controller.play();
            });
          },
          child: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
        ),
      ),
    );
  }

  void play() {
    _controller.play();
    debugPrint("Abspielen....");
    setState(() {});
  }

  void pause() {
    debugPrint("Pause....");
    _controller.pause();
    setState(() {});
  }

  void forward() async {
    Duration current = await _controller.position;
    _controller.seekTo(Duration(seconds: current.inSeconds + 15));
    setState(() {});
  }

  void backward() async {
    Duration current = await _controller.position;
    _controller.seekTo(Duration(seconds: current.inSeconds - 15));
    setState(() {});
   }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
 */
