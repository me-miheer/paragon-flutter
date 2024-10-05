import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:paragon/apis/auth.dart';
import 'package:paragon/extensions/loader.dart';
import 'package:paragon/extensions/snackbar.dart';
import 'package:paragon/screens/edit.dart';
import 'package:paragon/screens/profile.dart';
import 'package:paragon/screens/scanner.dart';
import 'package:paragon/screens/server.dart';
import 'package:paragon/screens/splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true;
  dynamic response;
  int _page = 1;
  int _limit = 100;
  final TextEditingController _serverName = TextEditingController();
  final TextEditingController _serverKey = TextEditingController();
  final TextEditingController _userType = TextEditingController();
  final TextEditingController _userMobile = TextEditingController();
  final _analysis = [
    {"sr": 1, "name": "Total Quantity", "value": 0},
    {"sr": 2, "name": "Total Sets", "value": 0},
    {"sr": 3, "name": "Total Pairs", "value": 0},
    {"sr": 4, "name": "Total Cartons", "value": 0},
  ];

  var _lister = [];

  void reloadApi(){
    print("loading");
    _firstLoad(true);
  }

  @override
  void initState() {
    super.initState();
    _initialFunction();
    _firstLoad(true);
  }

  Future<void> _firstLoad(bool firstLoad) async {
    setState(() {
      _isLoading = true;
    });

    final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
    _serverName.text = (await asyncPrefs.getString('server'))!;
    _serverKey.text = (await asyncPrefs.getString('serverkey'))!;
    final String? usersData = await asyncPrefs.getString('user');
    var userJson = jsonDecode(jsonDecode(usersData!));
    _userType.text = userJson['user_type'];
    _userMobile.text = userJson['mobile'];
    final String uri = "${dotenv.env['API_URL']}csv/fetchCsvApi.php";
    var _body = {
      "serverkey": _serverKey.text,
      "page": _page.toString(),
      "limit": _limit.toString(),
      "mobile": _userMobile.text
    };
    var _res = await getDataWithPost(uri, _body);
    response = _res?.body;
    print(_body);

    if(response != null){
      var _json = List<Map>.from(jsonDecode(response)['data']);
      _analysis[0]["value"] = jsonDecode(response)['total_quantity'];
      _analysis[1]["value"] = jsonDecode(response)['total_set_quantity'];
      _analysis[2]["value"] = jsonDecode(response)['total_pair_quantity'];
      _analysis[3]["value"] = jsonDecode(response)['total_carton_quantity'];
      if(jsonDecode(response)['message'] != "NoData"){
        if(_json.isNotEmpty){
          if(firstLoad){
            _lister = _json;
          }else{
            _lister.addAll(_json);
          }
        }else{
          showSnackBar(context, "No more data", "Ok");
        }
      }else{
        _lister = [];
      }
    }else{
      showSnackBar(context, "No data found", "Ok");
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _initialFunction() async {
    final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
    _serverName.text = (await asyncPrefs.getString('server'))!;
    _serverKey.text = (await asyncPrefs.getString('serverkey'))!;
    final String? usersData = await asyncPrefs.getString('user');
    var userJson = jsonDecode(jsonDecode(usersData!));
    _userType.text = userJson['user_type'];
    _userMobile.text = userJson['mobile'];
  }

  void _logout(){
    showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: const Text('Logout?'),
      content: const Text('This will logout you account on this device.'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: const Text('Cancel', style: TextStyle(fontFamily: "Roboto-Regular"),),
        ),
        TextButton(
          onPressed: () async {
            //   On sumit function
            final SharedPreferencesAsync asyncPrefs =
                SharedPreferencesAsync();
            await asyncPrefs.remove("loggedin");
            await asyncPrefs.remove('user');
            Navigator.pop(context, 'OK'); // Close the dialog
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SplashScreen()),
            ); // Navigate to HomePage
          },
          child: const Text("Logout", style: TextStyle(fontFamily: "Roboto-Regular"),),
        ),
      ],
    ),
    );
  }

  Future<void> _launchUrl(BuildContext context, String url)async{
    final Uri uri = Uri.parse(url);
    // Ensure the Uri is valid and can be launched
    if (await canLaunchUrl(uri)) {
      // Launch the URL using browser mode
      await launchUrl(
        uri,
        mode: LaunchMode.inAppBrowserView, // Ensures opening in the browser
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

  void handleClick(String item) {
    switch (item) {
      case "Profile":
        Navigator.push(context, MaterialPageRoute(builder: (context)=> ProfileScreen()));
        break;
      case "Admin":
        _launchUrl(context, "${dotenv.env['API_URL']}admin/index.php");
        break;
      case "Export":
        _launchUrl(context, "${dotenv.env['API_URL']}admin/foruser.php?id=${_serverKey.text}&mobile=${_userMobile.text}");
        break;
      case "Logout":
        _logout();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Home",
            style: TextStyle(fontFamily: "Roboto-Regular"),
          ),
          backgroundColor: const Color(0xFFdcdaf5),
          actions: <Widget>[
            OutlinedButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ServerScreen()));
                },
                child: Text(
                  _serverName.text,
                  style: const TextStyle(fontFamily: "Roboto-Regular"),
                )),
            PopupMenuButton<String>(
              onSelected: (item) => handleClick(item),
              itemBuilder: (context) => [
                const PopupMenuItem<String>(
                    value: "Profile",
                    child: Text(
                      'Profile',
                      style: TextStyle(fontFamily: "Roboto-Regular"),
                    )),
                PopupMenuItem<String>(
                    value: _userType.text == "admin" ? "Admin" : "Export",
                    child: Text(
                      _userType.text == "admin" ? "Admin" : "Export data",
                      style: const TextStyle(fontFamily: "Roboto-Regular"),
                    )),
                const PopupMenuItem<String>(
                    value: "Logout",
                    child: Text(
                      'Logout',
                      style: TextStyle(fontFamily: "Roboto-Regular"),
                    )),
              ],
            ),
          ],
          bottom: const TabBar(tabs: [
            Tab(
              child: Text(
                "Articles",
                style: TextStyle(fontFamily: "Roboto-Regular"),
              ),
            ),
            Tab(
              child: Text(
                "Overview",
                style: TextStyle(fontFamily: "Roboto-Regular"),
              ),
            )
          ]),
        ),
        body: Stack(
          children: [
            TabBarView(children: [
              RefreshIndicator(
                onRefresh: () async {
                  _firstLoad(true);
                },
                child: ListView(
                  children: _lister.isNotEmpty ? _lister.map((elements)=>SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        style: ElevatedButton.styleFrom(
                            textStyle: const TextStyle(fontFamily: "Roboto-Regular"),
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(3)))),
                        onPressed: () async {

                        },
                        onLongPress: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditScreen(
                                elements['qr'].toString(),
                                elements['consumer_size'].toString(),
                                elements['type'].toString(),
                                elements['quantity'].toString(),
                                elements['id'].toString(),
                                elements['consumer'].toString(),
                                  reloadApi// Added consumer element
                              ),
                            ),
                          );

                        },
                        child: ListTile(
                          title: Text("${elements['qr']}", style: const TextStyle(fontFamily: "Roboto-Regular", fontWeight: FontWeight.bold),),
                          subtitle: Text("${elements['consumer_size']} • ${elements['type']}", style: const TextStyle(fontFamily: "Roboto-Regular", color: Colors.grey),),
                          trailing: Text("${elements['quantity']}", style: const TextStyle(fontFamily: "Roboto-Regular"),),
                          leading: const CircleAvatar(
                            child: Icon(Icons.folder_copy_outlined),
                          ),
                        ),
                      ))).toList() : [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: const Text(
                          "No data found",
                          style: TextStyle(fontFamily: "Roboto-Regular"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              RefreshIndicator(
                onRefresh: () async {
                  _firstLoad(true);
                },
                child: ListView(
                    children: _analysis
                        .map((element) => ListTile(
                              leading: Text(
                                element['sr'].toString(),
                                style:
                                    const TextStyle(fontFamily: "Roboto-Regular"),
                              ),
                              title: Text(
                                element['name'].toString(),
                                style:
                                    const TextStyle(fontFamily: "Roboto-Regular"),
                              ),
                              trailing: Text(
                                element['value'].toString(),
                                style: const TextStyle(
                                    fontFamily: "Roboto-Regular",
                                    fontWeight: FontWeight.bold),
                              ),
                            ))
                        .toList()),
              )
            ]),
            CustomLoader(isLoading: _isLoading)
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ScannerPage()));
          },
          label: const Text(
            "Scan QR",
            style: TextStyle(fontFamily: "Roboto-Regular"),
          ),
          icon: const Icon(Icons.qr_code_scanner),
        ),
      ),
    );
  }
}
