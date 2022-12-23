/*
import 'package:background_stt/background_stt.dart';

import 'package:flutter/foundation.dart';

typedef CommandHandler();
typedef StringHandler(String recognizedText);

class VoiceBackgroundSTT {


  static final VoiceBackgroundSTT _instance = VoiceBackgroundSTT._internal();
  bool isSpeechListenServiceRunning = false;
  bool isListeningPaused = false;

  factory VoiceBackgroundSTT() => _instance;

  VoiceBackgroundSTT._internal();


  Map<String, CommandHandler> commandHandlerMap = {};
  BackgroundStt _backStt = BackgroundStt();
  String lastDataResult = "";

  void startListening() {
    this._startListenService();
    _backStt.getSpeechResults().onData((data) {
      if (data.isPartial) {
        if (lastDataResult.length <= data.result.length) {
          debugPrint(data.result);
          String newData = data.result.substring(lastDataResult.length).trim();
          List<String> commandsList = newData.split(" ");
          for (String elem in commandsList)
            if (matchCommands(elem)) {
              break;
            }
        }
        lastDataResult = data.result;
      } else {
        debugPrint("data is not partial");
        lastDataResult = "";
      }
    });
  }

  void startAndDeliverNonPartial(StringHandler func) {
    this._startListenService();
    this.resumeListening();
    _backStt.getSpeechResults().onData((data) {
      if (!data.isPartial) {
        this.pauseListening();
        //this.stopListenService();
        if (data.result != null && data.result.length > 0) {
          func(data.result);
        }
      }
    });
  }

  void resumeListening(){
    if (this.isSpeechListenServiceRunning && this.isListeningPaused){
      _backStt.resumeListening();
      this.isListeningPaused = false;
    }
  }

  void pauseListening(){
    if (this.isSpeechListenServiceRunning && !this.isListeningPaused){
      _backStt.pauseListening();
      this.isListeningPaused = true;
    }
  }

  void _startListenService(){
    if (!this.isSpeechListenServiceRunning) S{
      _backStt.startSpeechListenService;
      this.isSpeechListenServiceRunning = true;
    }
  }

  void _stopListenService() {
    if (this.isSpeechListenServiceRunning) {
      _backStt.stopSpeechListenService;
      this.isSpeechListenServiceRunning = false;
    }
  }

  bool matchCommands(String recognizedText) {
    if (this.commandHandlerMap.containsKey(recognizedText)) {
      this.commandHandlerMap[recognizedText]?.call();
      return true;
    }
    return false;
  }

  void listenToCommands(Map<String, CommandHandler> commandsToListen) {
    this.commandHandlerMap = commandsToListen;
  }
}
*/