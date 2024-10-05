import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:paragon/extensions/loader.dart';
import 'package:paragon/screens/splash.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../apis/auth.dart';

class ServerScreen extends StatefulWidget{
  @override
  State<ServerScreen> createState() => _ServerScreenState();
}

class _ServerScreenState extends State<ServerScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  dynamic response;
  final TextEditingController _serverController = TextEditingController();

  void _invalidKey(){
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
                    Text("Invalid Server Key", style: TextStyle(fontFamily: "Roboto-Regular", fontSize: 25),),
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
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SplashScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFdcdaf5),
        title: const Text("Server room", style: TextStyle(fontFamily: "Roboto-Regular"),),
        actions: [
          OutlinedButton(onPressed: (){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SplashScreen()));
          }, child: const Text("Cancel", style: TextStyle(fontFamily: "Roboto-Regular"),)),
          const SizedBox(width: 15,)
        ],
      ),
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              children: [
                Expanded(child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black87,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.dataset_linked_outlined, color: Color(0xFFdcdaf5), size: 50,),
                      Container(height: 15,),
                      const Text("Server room", style: TextStyle(fontFamily: "Roboto-Regular", fontSize: 25, color: Color(0xFFdcdaf5)),),
                    ],
                  ),
                )),
                Container(
                  width: double.infinity,
                  color: Color(0xfbf8ff),
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          Container(height: 15,),
                          TextFormField(
                            controller: _serverController,
                            obscureText: false,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'This field cannot be empty'; // Error message
                              }
                              return null; // No error
                            },
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Server Key",
                                labelStyle: TextStyle(fontFamily: "Roboto-Regular"),
                                errorStyle: TextStyle(color: Colors.red)),
                          ),
                          const SizedBox(height: 15,),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(onPressed: () async {
                              if(_formKey.currentState!.validate()){
                                setState(() {
                                  _isLoading = true;
                                });

                                final String qrCheckerUrl = "${dotenv.env['API_URL']}server/checkServer.php";
                                var res = await getDataWithPost(qrCheckerUrl, {
                                  "serverkey": _serverController.text
                                });

                                response = res?.body;  // Store the response body for display or further processing

                                if (response != null) {
                                  if (jsonDecode(response)['task_status'] == "true") {

                                    final SharedPreferencesAsync asyncPrefs = await SharedPreferencesAsync();
                                    await asyncPrefs.setString('server', jsonDecode(response)['location']);
                                    await asyncPrefs.setString("serverkey", jsonDecode(response)['accesskey']);

                                    setState(() {
                                      _isLoading = false;
                                    });

                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SplashScreen()));
                                  } else {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    _invalidKey();
                                  }
                                } else {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  _invalidKey();
                                }

                              }
                            }, child: const Text("Validate", style: TextStyle(fontFamily: "Roboto-Regular"),),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Color(0xFF0056cd),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(3))
                                )
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    ),
                  ),
              ],
            ),
          ),
          CustomLoader(isLoading: _isLoading)
        ],
      ),
    );
  }
}