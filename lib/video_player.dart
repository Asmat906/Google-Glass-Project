import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:google_glass_app/popup_dialog.dart';
import 'package:volume/volume.dart';

// import 'text_to_speech.dart';
// import 'voice_background.dart';

final int SEEK_SECONDS = 5;

class VideoPlayer extends StatelessWidget {
  int timeToStartInSeconds = 0;
  String videoUrl = "";
  bool isLocalFile = false;

  VideoPlayer(this.videoUrl, this.timeToStartInSeconds, {this.isLocalFile});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: VideoApp(
        title: 'HWG Video Player',
        videoUrl: this.videoUrl,
        timeToStartInSeconds: this.timeToStartInSeconds,
        isLocalFile: this.isLocalFile,
      ),
    );
  }
}

class VideoApp extends StatefulWidget {
  VideoApp({Key key, this.title, this.videoUrl, this.timeToStartInSeconds, this.isLocalFile}) : super(key: key);

  final String title;

  // String videoUrl = "https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4";
  String videoUrl = "";
  int timeToStartInSeconds = 0;
  bool isLocalFile = false;

  @override
  _VideoAppState createState() => _VideoAppState(this.videoUrl, this.timeToStartInSeconds, this.isLocalFile);
}

class _VideoAppState extends State<VideoApp> {
  // VoiceBackgroundSTT vbs;
  int videoLengthSeconds = 0;

  // String initUrl = "https://samples.mplayerhq.hu/MPEG-4/embedded_subs/1Video_2Audio_2SUBs_timed_text_streams_.mp4";

  // final VlcPlayerController controller = new VlcPlayerController(onInit: () {});
  VlcPlayerController controller;

  final int playerWidth = 640;
  final int playerHeight = 360;

  //bool isPlaying = true;

  Offset _positionStart;
  int _currentPositionMovie;
  int _currentMovieDuration;
  int stepWidth = 50;
  int newTimePosition;

  double verticalDragStartPosition;
  double verticalDragEndPosition;
  String videoUrl = "";
  int timeToStartInSeconds = 0;
  bool isLocalFile = false;
  bool firstStart = true;

  _VideoAppState(this.videoUrl, this.timeToStartInSeconds, this.isLocalFile);

  @override
  void initState() {
    super.initState();
    // vbs = VoiceBackgroundSTT();
    // vbs.startListening();
    // vbs.listenToCommands({
    //   "play": play,
    //   "start": play,
    //   "weiter": play,
    //   "pause": pause,
    //   "stop": pause,
    //   "vor": forward,
    //   "zurück": backward
    // });
//    Volume.getMaxVol.then((value) => debugPrint("MAX VOL: $value"));
    Volume.controlVolume(AudioManager.STREAM_MUSIC);
    // Timer.periodic(Duration(seconds: 1), (Timer timer) {
    //   if (controller?.hasListeners) {
    //     this.play();
    //     timer.cancel();
    //   }
    // });
    controller = VlcPlayerController.file(
      File(this.videoUrl),
      autoInitialize: true,
      autoPlay: true,
    );

    controller.addListener(() {
      if (controller.value.isEnded) {
        controller.stop();
        controller.setTime(0);
        controller.play();
      }
      if (this.firstStart && controller.value.isInitialized && controller.value.isPlaying) {
        this.firstStart = false;
        controller.setTime(this.timeToStartInSeconds * 1000);
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onVerticalDragStart: (DragStartDetails dsd) {
            verticalDragStartPosition = dsd.localPosition.dy;
          },
          onVerticalDragUpdate: (DragUpdateDetails dud) {
            verticalDragEndPosition = dud.localPosition.dy;
          },
          onVerticalDragEnd: (_) {
            double value = verticalDragStartPosition - verticalDragEndPosition;
            if (value > 0) {
              // dispose();
              // exit(0);
            } else {
              Navigator.of(context, rootNavigator: true)..pop(context);
            }
          },
          onDoubleTap: () {
            controller?.value.isPlaying ? pause() : play();
          },
          onHorizontalDragStart: (DragStartDetails dsd) {
            stepWidth = (MediaQuery.of(context).size.width / 25).round();
            _positionStart = dsd.globalPosition;
            controller.getTime().then((value) => _currentPositionMovie = (value / 1000).round());
            controller.getDuration().then((value) => _currentMovieDuration = value.inMilliseconds);
          },
          onHorizontalDragUpdate: (DragUpdateDetails dud) {
            //debugPrint("H Drag Update:\t" + dud.delta.toString());
            handleHorizontalDrag(dud);
          },
          onHorizontalDragEnd: (_) {
            controller.setTime(newTimePosition);
          },
          onLongPress: () {
            showPopupVolume(context);
          },
          child: Center(
            child: Column(
              children: [
                new VlcPlayer(
                  // autoplay: this.isLocalFile,
                  aspectRatio: 16 / 9,
                  // url: this.videoUrl,
                  // isLocalMedia: this.isLocalFile,
                  controller: this.controller,
                  placeholder: Center(child: CircularProgressIndicator()),
                ),
                // Slider(
                //   min: 0,
                //   max: controller.initialized ? controller.duration.inSeconds.toDouble() : 0,
                //   value: controller.initialized ? controller.position.inSeconds.toDouble() : 0,
                // ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: Icon(
            controller?.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
        ),
      ),
    );
  }

  void play() {
    controller.play().then((value) {
      // if (firstStart) {
      //   controller.setTime(this.timeToStartInSeconds * 1000);
      //   firstStart = false;
      // }
      setState(() {});
    });
  }

  void pause() {
    controller.pause().then((value) {
      setState(() {});
    });
  }

  void forward() async {
    Duration currentTime = await controller.getPosition();
    debugPrint("currentTime = $currentTime");
    int time = (currentTime.inSeconds + SEEK_SECONDS);
    debugPrint("time = $time");
    Duration totalLength = await controller.getDuration();
    debugPrint("totalLength = $totalLength");
    if (time <= totalLength.inSeconds) {
      controller.setTime(time * 1000);
    }
  }

  void backward() async {
    Duration currentTime = await controller.getPosition();
    int time = (currentTime.inSeconds - SEEK_SECONDS) * 1000;
    controller.setTime(time <= 0 ? 0 : time);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void showPopupVolume(BuildContext context) async {
    Overlay.of(context).insert(SliderOverlay(context).overlay);
  }

  void handleHorizontalDrag(DragUpdateDetails dud) {
    // debugPrint("stepWidth: " + stepWidth.toString());
    // debugPrint("currentPos: " + _currentPositionMovie.toString());
    // debugPrint("positionStartx: " + _positionStart.dx.toString());
    // debugPrint("currentPosX: " + dud.globalPosition.dx.toString());
    // debugPrint("calculation: " + (_positionStart.dx - dud.globalPosition.dx).toString());
    // debugPrint("calculation 2: " + ((_positionStart.dx - dud.globalPosition.dx) / stepWidth).round().toString());
    // debugPrint("_currentMovieDuration: " + _currentMovieDuration.toString());
    newTimePosition =
        ((_currentPositionMovie + (((_positionStart.dx - dud.globalPosition.dx) / stepWidth).round())) * 1000);
    // debugPrint("newTimePosition before Check: " + newTimePosition.toString());

    if (newTimePosition < 0) {
      newTimePosition = 0;
    } else if (newTimePosition > _currentMovieDuration) {
      newTimePosition = _currentMovieDuration;
    }
    // debugPrint("time to set: " + newTimePosition.toString());
  }
}
