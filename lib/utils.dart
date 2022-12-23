import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_glass_app/consts.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class Utils {
  static String userName = "";

  static void handleJSONType(String jsonData) {
    LinkedHashMap jsonObject = json.decode(jsonData);
  }

  static findMovieFile(String startingWith) {}

  /**
   * Downloads movies from youtube to the local storage const.MOVIE_FOLDER
   */
  static Future<String> downloadMovie(String url) async {
    RegExpMatch match = RegExp(r'v=([^&]+)').firstMatch(url);
    String videoID = match.group(1);

    final dir = Directory(MOVIE_FOLDER);
    final List<FileSystemEntity> files = dir.listSync().toList();
    for (var f in files) {
      if (f.path.split("/").last.startsWith(videoID)) {
        return f.path;
      }
    }
    return "";
  }

  static Future<String> downloadMovieFromOpenDataPool(
      String gtin, String name, String filename) async {

    if (await Permission.storage.request().isDenied){
      return "";
    }

    if (await Permission.manageExternalStorage.request().isDenied){
      return "";
    }

    final dir = Directory(MOVIE_FOLDER);
    name = name.replaceAll("ß", "ss").replaceAll(RegExp(r"\s"), "_").replaceAll(RegExp(r"\W"), "");
    Directory dirGtin = Directory(MOVIE_FOLDER + '/' + name.substring(0, 19) + "_" + gtin);

    if (!dirGtin.existsSync()) {
      dirGtin.create();
    }

    var file = File(dirGtin.path + '/' + filename);

    if (file.existsSync()) {
      return file.path;
    }
    return "";
  }

  static bool isDirectory(String path) {
    return Directory(path).existsSync();
  }

  static String myDTFormat(DateTime dt, int duration) {
    return DateFormat("HH:mm").format(dt) + " - " + DateFormat("HH:mm").format(dt.add(Duration(minutes: duration)));
  }
}

Widget getIconWithShadow(IconData iconData, Color color, double size) {
  return Stack(
    children: [
      Positioned(
        left: 4,
        top: 4,
        child: Icon(
          iconData,
          color: COLOR_SHADOW,
          size: size,
        ),
      ),
      Icon(
        iconData,
        size: size,
        color: color,
      ),
    ],
  );
}

OverlayEntry _currentThrobber = null;
bool isLoading;

OverlayEntry _getThrobber(context) {
  return OverlayEntry(
      builder: (context) => Container(
            color: Color.fromARGB(200, 0, 0, 0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    width: 20,
                    height: 20,
                  ),
                  Text(
                    "Downloading...",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      decoration: TextDecoration.none,
                    ),
                  )
                ]),
          ));
}

int throbberCount = 0;

OverlayEntry _showDialog(context) {
  showDialog(
      context: context,
      builder: (context) {
        Future.delayed(Duration(seconds: 5), () {
          Navigator.of(context).pop(true);
        });
        return Container(
            child: AlertDialog(
              title: Text("Abruf der Aufträge"),
              titleTextStyle: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
              backgroundColor: Colors.greenAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              content: Text(
                  "Abruf der Aufträge gestartet. \nBitte um etwas Geduld. Es kann einige Minuten dauern."),
            ));
      });
}

void showThrobber(
    context,
    isloading,
    ) {
  if (_currentThrobber == null) {
    if (isloading == true) {
      _currentThrobber = _showDialog(context);
      if (_currentThrobber != null)
        Overlay.of(context).insert(_currentThrobber);
    } else if (_currentThrobber != null)
      _currentThrobber = _getThrobber(context);
  } else if (_currentThrobber != null && isloading == false) {
    _currentThrobber = _getThrobber(context);
    Overlay.of(context).insert(_currentThrobber);
  } else if (_currentThrobber != null && isloading == true) {
    _currentThrobber = _showDialog(context);
    if (_currentThrobber != null) Overlay.of(context).insert(_currentThrobber);
  }
  throbberCount++;
}

void removeThrobber() {
  if (_currentThrobber != null &&
      throbberCount == 1 &&
      _currentThrobber.mounted) {
    _currentThrobber?.remove();
    _currentThrobber = null;
  }
  throbberCount--;
}
