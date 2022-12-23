import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_glass_app/consts.dart';
import 'package:google_glass_app/utils.dart';
import 'package:google_glass_app/view/pdf_view.dart';
import 'package:google_glass_app/video_player.dart';

import 'image_view.dart';

class VideoListing extends StatefulWidget {
  List<String> listGtinFilter;

  VideoListing({this.listGtinFilter = const []});

  @override
  State<StatefulWidget> createState() {
    return _VideoListingState();
  }
}

class _VideoListingState extends State<VideoListing> {
  List<String> fileNames = [];
  int selectedIndex = 0;
  int newSelectedIndex = -1;

  double dragHorizontalStartPosition = 0;

  double dragVerticalStartPosition = 0;
  double dragVerticalEndPosition = 0;

  ScrollController scrollCtrl;

  List<String> directories = [MOVIE_FOLDER];

  @override
  void initState() {
    super.initState();
    fetchDirectoryEntries();
    scrollCtrl = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:
        Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             // checkBauDocsExists(fileNames.length),
              Container(height: 295 ,child:
              Stack(
                children: [
                  ListView.builder(
                    controller: this.scrollCtrl,
                    padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                    itemCount: fileNames.length,
                    itemBuilder: (_, int index) {
                      return 
                      Container(
                        child: Text(
                          fileNames[index]
                              .split("/")
                              .last,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: newSelectedIndex == index
                                ? Colors.white
                                : selectedIndex == index
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                        padding: EdgeInsets.only(top: 20, bottom: 20),
                        color: newSelectedIndex == index
                            ? COLOR_RED
                            : selectedIndex == index
                            ? COLOR_YELLOW
                            : COLOR_BLUE,
                      );
                    },
                  ),
                  SizedBox(
                    height: MediaQuery
                        .of(context)
                        .size
                        .height,
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onHorizontalDragStart: (details) {
                        dragHorizontalStartPosition = details.globalPosition.dx;
                      },
                      onHorizontalDragUpdate: (details) {
                        var distance = details.globalPosition.dx -
                            this.dragHorizontalStartPosition;

                        int newCalculatedIndex = selectedIndex -
                            (distance / 50).floor();
                        if (newCalculatedIndex < 0) {
                          newCalculatedIndex = 0;
                        } else if (newCalculatedIndex > fileNames.length - 1) {
                          newCalculatedIndex = fileNames.length - 1;
                        }

                        if (newCalculatedIndex != newSelectedIndex) {
                          newSelectedIndex = newCalculatedIndex;
                          this.scrollCtrl.animateTo(
                            this.newSelectedIndex * 38.0,
                            duration: Duration(milliseconds: 350),
                            curve: Curves.linear,
                          );
                          // this.scrollCtrl.jumpTo(newSelectedIndex * 38.0);
                          setState(() {});
                        }
                      },
                      onHorizontalDragEnd: (details) {
                        selectedIndex = newSelectedIndex;
                        newSelectedIndex = -1;
                        setState(() {});
                      },
                      onVerticalDragStart: (details) {
                        this.dragVerticalStartPosition = details.globalPosition.dy;
                        // debugPrint("$dragVerticalStartPosition");
                      },
                      onVerticalDragUpdate: (details) {
                        this.dragVerticalEndPosition = details.globalPosition.dy;
                        // debugPrint("$dragVerticalEndPosition");
                      },
                      onVerticalDragEnd: (_) {
                        if ((this.dragVerticalStartPosition -
                            this.dragVerticalEndPosition) < -80) {
                          Navigator.pop(context);
                        }
                      },
                      onTap: () {
                        if (fileNames[selectedIndex].endsWith("..")) {
                          directories.removeLast();
                          fetchDirectoryEntries();
                          setState((){
                            title = "vorhandene BauDocs:";
                          });
                        } else if (Utils.isDirectory(fileNames[selectedIndex])) {
                          directories.add(fileNames[selectedIndex]);
                          String directoryName = fileNames[selectedIndex];
                          fetchDirectoryEntries();
                          setState((){
                            List<String> splitted = directoryName.split('/');
                            title = "Verzeichnis: " + splitted[5];
                          });
                        } else {
                          if (fileNames[selectedIndex].toLowerCase().endsWith(".pdf")) {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => PDFViewer(fileNames[selectedIndex])));
                          }
                          else if (fileNames[selectedIndex].toLowerCase().endsWith(".jpg") || fileNames[selectedIndex].toLowerCase().endsWith(".bmp")||fileNames[selectedIndex].toLowerCase().endsWith(".png")) {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => ImageView(fileNames[selectedIndex])));
                          }
                          else {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => VideoPlayer(fileNames[selectedIndex], 0, isLocalFile: false)));
                          }
                          //Navigator.pop(context, fileNames[selectedIndex]);
                        }
                      },
                    ),
                  ),
                ],
              ),
              )]));
  }
  String title = "vorhandene BauDocs:";

  Widget checkBauDocsExists(int length){
    if(length == 0)
      return Padding(child: Text("keine BauDocs vorhanden", textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize:20)),padding: EdgeInsets.all(20.0));
    else
      return Padding(child: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize:18)),padding: EdgeInsets.all(4.0));
  }

  List<String> fetchDirectoryEntries() {
    selectedIndex = 0;
    if (this.scrollCtrl != null) {
      this.scrollCtrl.animateTo(0, duration: Duration(milliseconds: 1), curve: Curves.linear);
    }
    var dir = Directory(directories.last);
    List<String> entries = [];
    if (directories.length > 1) {
      entries.add("..");
    }
    dir.list(followLinks: true, recursive: false).listen((FileSystemEntity entity) {
      if (directories.length == 1 && this.widget.listGtinFilter.length > 0) {
        bool found = false;
        for (int i = 0; i < this.widget.listGtinFilter.length && !found; i++) {
          found = entity.path.indexOf(this.widget.listGtinFilter[i]) >= 0;
          if (found) {
            entries.add(entity.path);
          }
        }
      } else {
        entries.add(entity.path);
      }
      entries.sort();
      setState(() {
        fileNames = [];
        fileNames.addAll(entries);
      });
    });
  }
}
