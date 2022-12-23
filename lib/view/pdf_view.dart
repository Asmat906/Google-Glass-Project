import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:native_pdf_view/native_pdf_view.dart';


class PDFViewer extends StatefulWidget {
  String filePath;

  PDFViewer(this.filePath);

  @override
  State<StatefulWidget> createState() => _PDFViewerState();
}

class _PDFViewerState extends State<PDFViewer> {
  PdfController _pdfController;

  _PDFViewerState();

  void finalCallback(bool error) {
    if (!error) {
      _pdfController = PdfController(document: PdfDocument.openFile(this.widget.filePath));
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    File f = File(this.widget.filePath);
    if (f.existsSync()) {
      this._pdfController = PdfController(document: PdfDocument.openFile(f.path));
      this.setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PDF VIEWER"),
        centerTitle: true,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onLongPress: (){
          debugPrint("longPress executed");
          //Navigator.of(context).pop();
          Navigator.pop(context);
        },
        child: PdfView(
          controller: this._pdfController,
          scrollDirection: Axis.vertical,
        ),
      ),
    );
  }
}
