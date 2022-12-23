import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_glass_app/consts.dart';
import 'package:google_glass_app/data/task.dart';
import 'package:google_glass_app/utils.dart';
import 'package:google_glass_app/video_listing.dart';
import 'package:google_glass_app/video_player.dart';
import 'package:google_glass_app/view/task_view.dart';
import 'package:localstorage/localstorage.dart';

import 'qr_view.dart';

bool isloading=false;

String qrScanResult = "";
final bool VOICE_RECOGNITION_ENABLED = false;

void main() {
  runApp(HWGGlass());
}

class HWGGlass extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HWGGlassState();
  }
}

void nothing(_) {
  //TODO REMOVE THIS AS SOON EVERYTHING IS IMPLEMENTED
}

void _showVideos(BuildContext context) async {
  /*final result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => VideoListing()));
  if ((result ?? "").length > 0) {
    if ((result as String).toLowerCase().endsWith(".pdf")) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => PDFViewer(result)));
    } else {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => VideoPlayer(result, 0, isLocalFile: true)));
    }
  }*/
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => VideoListing()));
}

void _exitApp(BuildContext context) {
  exit(0);
}

class _HWGGlassState extends State<HWGGlass> {
  int currentIndex = 0;

  CarouselSlider carouselSlider;
  List<CarouselElement> carouselElements = [];

  List<Task> listOfTasks = [];

  FlutterSecureStorage storage;
  LocalStorage localStorage = LocalStorage("tasks.json");

  //VoiceBackgroundSTT vbs;

  void getRegisteredUserFromStorage() {
    storage.read(key: "name").then((value) {
      if (value == null) {
        return;
      }
      setState(() {
        Utils.userName = value;
        fetchLocalStorageTasks();
        _fetchTasks(context, withThrobber: true);
      });
    });
  }


  void fetchLocalStorageTasks() async {
    this.localStorage.ready.whenComplete(() {
      this.listOfTasks = [];
      String str = localStorage.getItem("tasks");
      debugPrint(str);
      if (str == null) {
        return;
      }
      dynamic json = jsonDecode(str);
      for (dynamic entry in json['tasks']) {
        this.listOfTasks.add(Task.fromJson(Task(), entry));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    storage = FlutterSecureStorage();

    getRegisteredUserFromStorage();
    this.carouselElements = [
      CarouselElement("QR Code", Icons.qr_code, COLOR_YELLOW, scan),
      CarouselElement("BauDocs", Icons.ondemand_video, COLOR_BLUE, _showVideos),
      // CarouselElement("Spracheingabe", Icons.mic, COLOR_GREEN, nothing),
      CarouselElement("Remote Assist", Icons.help_outline, COLOR_GREEN, nothing),
      // CarouselElement("Remote Assist", ImageIcon(AssetImage
      //   ("assets/remote_assist_icon_white.png"), color: Colors.white),
      //   COLOR_GREEN,nothing),
      // CarouselElement("Tasks", Icons.pending_actions, COLOR_ORANGE, _showTasks),
      CarouselElement("Aufträge", Icons.assignment, COLOR_ORANGE, _showTasks),
      CarouselElement("Aufträge abrufen", Icons.assignment_returned, COLOR_PURPLE, _fetchTasks),
      CarouselElement("Beenden", Icons.power_settings_new, COLOR_RED, _exitApp),
    ];
    // if (VOICE_RECOGNITION_ENABLED) {
    //   vbs = VoiceBackgroundSTT();
    //   vbs.startListening();
    //   vbs.listenToCommands({"play": play, "pause": pause, "vor": forward, "zurück": backward});
    // }

    //first time download of all tasks for today
    _fetchTasks(context);
  }

  Widget returnText() {
    return Container(
      child: SizedBox(
        width: 640,
        height: 360,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Bitte QR Code einscannen um sich zu registrieren",
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontSize: 20,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "(Tap um Scanner zu aktivieren!!!)",
                style: TextStyle(
                  color: Colors.red,
                  decoration: TextDecoration.none,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void scan(BuildContext context) async {
    String result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => QRScanView()));

    if (result == null || result.isEmpty) {
      CircularProgressIndicator();
      return;
    }
    else{
    }

    LinkedHashMap jsonObject = json.decode(result);
    if (jsonObject.containsKey("type")) {
      String type = jsonObject["type"];
      if (type == "video") {
        String url = jsonObject["url"];
        int time = jsonObject["time"] ?? 0;

        if (url.contains("www.youtube")) {
          //download movie with 360p from youtube
          String filePath = await Utils.downloadMovie(url);

          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => VideoPlayer(filePath, time, isLocalFile: true)));
          removeThrobber();
        } else {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => VideoPlayer(url, time)));
          removeThrobber();
        }
      } else if (type == "setup") {
        String name = jsonObject['name'];
        String email = jsonObject['email'];
        String password = jsonObject['password'];
        String imap = jsonObject['imap'];
        String imapPort = jsonObject['imapPort'];
        String smtp = jsonObject['smtp'];
        String smtpPort = jsonObject['smtpPort'];

        storage.write(key: "name", value: name);
        storage.write(key: "email", value: email);
        storage.write(key: "password", value: password);
        storage.write(key: "imap", value: imap);
        storage.write(key: "imapPort", value: imapPort);
        storage.write(key: "smtp", value: smtp);
        storage.write(key: "smtpPort", value: smtpPort);
        setState(() {
          Utils.userName = name;
        });
        _fetchTasks(context);
      }
    }
    removeThrobber();
  }

  @override
  Widget build(BuildContext context) {
    carouselSlider = CarouselSlider(
      key: Key("Carousel"),
      options: CarouselOptions(
        onPageChanged: pageChanged,
        height: 320.0,
        enlargeCenterPage: true,
      ),
      items: carouselElements.map((i) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: i.color,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      getIconWithShadow(
                        i.icon,
                        Colors.white,
                        150,
                      ),
                      Text(
                        '${i.title}',
                        style: TextStyle(
                          fontSize: 32.0,
                          color: Colors.white,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ));
          },
        );
      }).toList(),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) {
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              if (Utils.userName == null || Utils.userName.isEmpty) {
                //todo start qr code reader for installation
                this.scan(context);
              } else {
                onClick(context);
              }
            },
            //child: (Utils.userName == null || Utils.userName.isEmpty) ? returnText() : carouselSlider,
            child: (Utils.userName == null || Utils.userName.isEmpty) ? returnText() : Stack(children:[carouselSlider,Positioned(bottom: 10, right: 10, child: Text("1.1.1", style: TextStyle(fontSize: 14, color: Colors.white,decoration: TextDecoration.none),))]),
          );
        },
      ),
    );
  }

  void onClick(BuildContext context) {
    carouselElements[currentIndex].action(context);
  }

  void pageChanged(int index, _) {
    currentIndex = index;
  }

  void _fetchTasks(BuildContext context, {bool withThrobber = true}) async {
    /*if (withThrobber) {
      showThrobber(context);
    }*/

    if (withThrobber ) {
      if(currentIndex==4){
        isloading=true;
        showThrobber(context, isloading=true);
      }
      else{
        showThrobber(context, isloading=false);
      }
    }

    this.listOfTasks = await Task.fetchTasksFromInbox(DateTime.now());


    String jsonString = '{"tasks": [';
    for (int i = 0; i < listOfTasks.length; i++) {
      jsonString += listOfTasks[i].jsonString;
      if (i < listOfTasks.length - 1) {
        jsonString += ',';
      }
    }
    jsonString += "]}";

    //todo save the tasks
    localStorage.setItem("tasks", jsonString, (val) {
      return val;
    });
    if (withThrobber) {
      removeThrobber();
    }
  }

  void _showTasks(BuildContext context) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (context) => TaskView(listOfTasks)));
  }
}

class CarouselElement {
  String title;
  IconData icon;
  Color color;
  Function action;

  CarouselElement(this.title, this.icon, this.color, this.action);
}
