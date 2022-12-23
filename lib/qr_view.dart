import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_glass_app/consts.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScanView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _QRScanViewState();
  }
}

class _QRScanViewState extends State<QRScanView> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var qrText = "";
  QRViewController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop(qrText);
            },
            onDoubleTap: () {
              setState(() {
                qrText = "";
              });
            },
          ),
          Visibility(
            visible: qrText?.length > 0,
            child: Positioned(
              bottom: 10,
              left: 0,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: COLOR_RED,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromARGB(100, 60, 60, 60),
                          offset: Offset(5, 5),
                          blurRadius: 2,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          qrText,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        )),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrText = scanData.code;
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
