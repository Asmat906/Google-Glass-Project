import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:io';
import 'package:photo_view/photo_view.dart';

class ImageView extends StatefulWidget {
  String filePath;

  ImageView(this.filePath);

  @override
  State<StatefulWidget> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  final GlobalKey imageKey = GlobalKey(debugLabel: 'Image');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("IMAGE VIEWER"),
        centerTitle: true,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onLongPress: (){
          debugPrint("longPress executed");
          //Navigator.of(context).pop();
          Navigator.pop(context);
        },
        child: PhotoView(imageProvider: FileImage(File(this.widget.filePath)))
      ),
    );
  }
}