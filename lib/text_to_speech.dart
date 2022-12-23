/*
import 'package:speech_to_text/speech_recognition_error.dart';

import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class TextToSpeech {
  SpeechToText speech;
  bool speechAvailable = false;

  TextToSpeech() {
    this.speech = SpeechToText();
    this.init();
  }

  init() async {
    print("ich werde aufgerufen!");
    speech.initialize(
      onStatus: (String status) {
        for (int i = 0; i < 10; i++) {
          print("STATUS ${i}");
        }
        print(status);
      },
      onError: (SpeechRecognitionError errorNotification) {
        for (int i = 0; i < 10; i++) {
          print("ERRROR${i}");
        }
        print(errorNotification);
      },
    ).then((value) {
      speechAvailable = value;
      print("Jetzt ist was zurückgekommen!!!");
      startListening();
    });
  }

  void startListening() async {
    print(speechAvailable);
    if (speechAvailable) {
      var locales = await speech.locales();
      locales.forEach((element) {
        print("${element}");
      });

      speech.listen(
        onResult: (SpeechRecognitionResult result) {
          print(result);
        },
      );
    } else {
      print("SOMETHING WENT WRONG");
    }
  }

  void stopListening() {
    if (speechAvailable) {
      this.speech.stop();
    }
  }
}

*/