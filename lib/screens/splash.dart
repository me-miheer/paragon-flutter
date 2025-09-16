import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:paragon/apis/auth.dart';
import 'package:paragon/screens/home.dart';
import 'package:paragon/screens/login.dart';
import 'package:paragon/screens/server.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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

  final String appVersion = "2.4";

  Future<void> _launchUrl(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    // Ensure the Uri is valid and can be launched
    if (await canLaunchUrl(uri)) {
      // Launch the URL using browser mode
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // Ensures opening in the browser
      );
    } else {
      // Show SnackBar if unable to open URL
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Unable to open the URL'),
          action: SnackBarAction(label: 'Ok', onPressed: () {}),
        ),
      );
    }
  }

  void showUpdateSheet(
      String required, String url, bool? loggedin, String? serverkey) {
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (BuildContext context) {
        return SizedBox(
          height: 220,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Update Available",
                  style: TextStyle(
                    fontFamily: "Roboto-Regular",
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "A new version of the app is available.\nPlease update to continue using all features.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "Roboto-Regular",
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    if (required == "no")
                      Expanded(
                        child: OutlinedButton(
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Color(0xFF000000)),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => serverkey != null
                                    ? (loggedin != null && loggedin
                                        ? const HomePage()
                                        : const LoginScreen())
                                    : ServerScreen(),
                              ),
                            );
                          },
                          child: const Text("Cancel"),
                        ),
                      ),
                    if (required == "no") const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Color(0xFF0056cd)),
                        onPressed: () {
                          _launchUrl(context, url);
                        },
                        child: const Text("Update"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      if(required == "yes"){
        SystemNavigator.pop();
      }else{
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => serverkey != null
                ? (loggedin != null && loggedin
                ? const HomePage()
                : const LoginScreen())
                : ServerScreen(),
          ),
        );
      }
    });
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
          "${dotenv.env['API_URL']}settings/appAccess.php",
          {"Nodata": "Nodata"});
      var response = res?.body;

      if (response != null) {
        final decoded = jsonDecode(response);
        if (decoded['task_status'] == "true" &&
            decoded['app_update'] != "false") {
          final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
          final bool? loggedin = await asyncPrefs.getBool('loggedin');
          final String? serverkey = await asyncPrefs.getString('serverkey');
          if (decoded['app_update'] == "yes" && decoded['app_version'] != appVersion) {
            showUpdateSheet(decoded['app_update_need'],
                decoded['app_update_url'], loggedin, serverkey);
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => serverkey != null
                    ? (loggedin != null && loggedin
                        ? const HomePage()
                        : const LoginScreen())
                    : ServerScreen(),
              ),
            );
          }
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
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
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
      ),
    );
  }
}
