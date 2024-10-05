import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:paragon/apis/auth.dart';
import 'package:paragon/screens/home.dart';
import 'package:paragon/screens/login.dart';
import 'package:paragon/screens/server.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkUpdates();
  }

  void noService() {
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
                const Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Server unreachable",
                        style: TextStyle(
                          fontFamily: "Roboto-Regular",
                          fontSize: 25,
                        ),
                      ),
                      Text(
                        "Please try again later",
                        style: TextStyle(
                          fontFamily: "Roboto-Regular",
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(fontFamily: "Roboto-Regular"),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                      ),
                    ),
                    child: const Text("I Understand"),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> checkUpdates() async {
    try {
      var res = await getDataWithPost(
          "${dotenv.env['API_URL']}settings/appAccess.php", {"Nodata": "Nodata"});
      var response = res?.body;

      if (response != null) {
        if (jsonDecode(response)['task_status'] == "true") {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          final bool? loggedin = prefs.getBool('loggedin');
          final String? serverkey = prefs.getString('serverkey');

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => serverkey != null
                  ? (loggedin != null && loggedin ? const HomePage() : const LoginScreen())
                  : ServerScreen(),
            ),
          );
        } else {
          noService();
        }
      } else {
        noService();
      }
    } catch (e) {
      // Handle network errors
      noService();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: SizedBox(
            width: 150,
            height: 150,
            child: Image.asset("assets/images/paragon_logo.png"),
          ),
        ),
      ),
    );
  }
}
