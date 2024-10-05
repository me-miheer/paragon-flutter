import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:paragon/extensions/loader.dart';
import 'package:paragon/screens/submit_qr.dart';
import 'package:qr_scanner_overlay/qr_scanner_overlay.dart';

import '../apis/auth.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  bool _isFlashOn = false;
  bool _isCamera = false;
  bool _isLoading = false;
  dynamic response;
  final MobileScannerController _scannerController = MobileScannerController();

  void _invalidQr(){
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) {
        return SizedBox(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Expanded(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Invalid Article", style: TextStyle(fontFamily: "Roboto-Regular", fontSize: 25),),
                    Text("Please contact to the administrator.", style: TextStyle(fontFamily: "Roboto-Regular", fontSize: 12, color: Colors.grey),)
                  ],
                )),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                        textStyle:
                        const TextStyle(fontFamily: "Roboto-Regular"),
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(3)))),
                    child: const Text("I Understand"),
                  ),
                )
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFdcdaf5),
        title: const Text(
          "Scanner",
          style: TextStyle(fontFamily: "Roboto-Regular"),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    MobileScanner(
                      controller: _scannerController,
                      onDetect: (capture) async {
                        setState(() {
                          _isLoading = true;
                        });
                        _scannerController.stop();
                        var captureData = capture.barcodes.first.rawValue?.toString();
                        final String qrCheckerUrl = "${dotenv.env['API_URL']}settings/appArticles.php?article=${captureData!}";
                        var res = await getDataWithPost(qrCheckerUrl, {

                        });
                        setState(() {
                          response = res?.body;  // Store the response body for display or further processing
                          _isLoading = false; // Hide the loader
                        });

                        if (response != null) {
                          if (jsonDecode(response)['task_status'] == "true") {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SubmitScreen(jsonDecode(response)['article'], jsonDecode(response)['gender'])));
                          } else {
                            _invalidQr();
                          }
                        } else {
                          _invalidQr();
                        }

                      },
                    ),
                    QRScannerOverlay(),
                    SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: Column(
                        children: [
                          Expanded(child: Container()),
                          SizedBox(
                            width: double.infinity,
                            height: 150,
                            child: Column(
                              children: [
                                Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        child: Icon(
                                          _isCamera
                                              ? Icons.camera_rear
                                              : Icons.camera_front,
                                          color: Colors.white,
                                        ),
                                        onTap: () {
                                          setState(() {
                                            _isCamera = !_isCamera;
                                            _scannerController.switchCamera();
                                          });
                                        },
                                      ),
                                      Container(
                                        width: 30,
                                      ),
                                      InkWell(
                                        child: Icon(
                                          _isFlashOn
                                              ? Icons.flashlight_off_outlined
                                              : Icons.flashlight_on_outlined,
                                          color: Colors.white,
                                        ),
                                        onTap: () {
                                          setState(() {
                                            _isFlashOn = !_isFlashOn;
                                            _scannerController.toggleTorch();
                                          });
                                        },
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 30),
                                SizedBox(
                                  width: 70,
                                  height: 70,
                                  child: Image.asset("assets/images/paragon_logo.png"),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          CustomLoader(isLoading: _isLoading)
        ],
      ),
    );
  }
}
