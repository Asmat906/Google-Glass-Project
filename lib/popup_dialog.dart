import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:google_glass_app/consts.dart';
import 'package:google_glass_app/video_player.dart';
import 'package:volume/volume.dart';

class SliderOverlay {
  int maxVolume = 10;
  int currentVolume = 5;
  Offset positionStart = Offset(0, 0);
  int startVolume = 5;

  OverlayEntry _overlayEntry;
  BuildContext _context;
  Size _contextSize;

  SliderOverlay(BuildContext this._context);

  void initVolume() async {
    maxVolume = await Volume.getMaxVol;
    currentVolume = await Volume.getVol;
  }

  get overlay {
    if (this._overlayEntry == null) {
      this._overlayEntry = _getOverlay();
    }
    initVolume();
    _contextSize = MediaQuery.of(_context).size;
    return this._overlayEntry;
  }

  void removeOverlay() {
    this._overlayEntry.remove();
  }

  OverlayEntry _getOverlay() {
    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned(
            top: ((_contextSize.height - 150) / 2).roundToDouble(),
            left: ((_contextSize.width - 300) / 2).roundToDouble(),
            width: 300,
            height: 120,
            child: Scaffold(
              endDrawerEnableOpenDragGesture: false,
              drawerEnableOpenDragGesture: false,
              key: Key("scaffold"),
              body: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey[400],
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Lautstärke"),
                          Icon(Icons.volume_up),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Left Vol-"),
                          Padding(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: Icon(Icons.swipe),
                          ),
                          Text("Right Vol+"),
                        ],
                      ),
                      // RaisedButton(
                      //   child: Text("OK"),
                      //   color: COLOR_BLUE,
                      //   textColor: Colors.white,
                      //   onPressed: (){},
                      // ),
                      Slider(
                        key: Key("VolumeSlider"),
                        divisions: maxVolume,
                        min: 0,
                        max: maxVolume.toDouble(),
                        value: currentVolume.toDouble(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: _contextSize.width,
            height: _contextSize.height,
            // color: Color.fromARGB(150, 70, 70, 70),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: this.removeOverlay,
              // onDoubleTap: this.removeOverlay,
              onHorizontalDragStart: (DragStartDetails dsd) {
                positionStart = dsd.globalPosition;
                startVolume = currentVolume;
              },
              onHorizontalDragEnd: (_) {},
              onHorizontalDragUpdate: (DragUpdateDetails dud) {
                handleHorizontalDrag(dud);

                //debugPrint("HorizontalDragUpdate: " + (dud.globalPosition.dx - positionStart.dx).toString());
              },
            ),
          ),
        ],
      ),
    );
  }

  void handleHorizontalDrag(DragUpdateDetails dud) {
    int stepWidth = ((_contextSize.width / maxVolume) * 0.85).round();
    currentVolume = startVolume + (((positionStart.dx - dud.globalPosition.dx) / stepWidth).round());
    if (currentVolume < 0) {
      currentVolume = 0;
    } else if (currentVolume > maxVolume) {
      currentVolume = maxVolume;
    }
    Volume.setVol(currentVolume, showVolumeUI: ShowVolumeUI.SHOW);
  }
}
