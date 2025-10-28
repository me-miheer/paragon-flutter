import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:paragon/apis/auth.dart';
import 'package:paragon/extensions/loader.dart';
import 'package:paragon/extensions/snackbar.dart';
import 'package:paragon/screens/profile.dart';
import 'package:paragon/screens/scanner.dart';
import 'package:paragon/screens/server.dart';
import 'package:paragon/screens/splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:paragon/screens/data_table.dart';

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
  final TextEditingController total_set_quantity_solea = TextEditingController();
  final TextEditingController total_pair_quantity_solea = TextEditingController();
  final TextEditingController total_carton_quantity_solea = TextEditingController();
  final TextEditingController total_set_quantity_slikers = TextEditingController();
  final TextEditingController total_pair_quantity_slikers = TextEditingController();
  final TextEditingController total_carton_quantity_slikers = TextEditingController();
  final TextEditingController total_set_quantity_ptoes = TextEditingController();
  final TextEditingController total_pair_quantity_ptoes = TextEditingController();
  final TextEditingController total_carton_quantity_ptoes = TextEditingController();
  final TextEditingController total_set_quantity_vertex = TextEditingController();
  final TextEditingController total_pair_quantity_vertex = TextEditingController();
  final TextEditingController total_carton_quantity_vertex = TextEditingController();
  final _analysis = [
    {"sr": 1, "name": "Total Quantity", "value": 0},
    {"sr": 2, "name": "Total Sets", "value": 0},
    {"sr": 3, "name": "Total Pairs", "value": 0},
    {"sr": 4, "name": "Total Cartons", "value": 0},
  ];

  var _lister = [];

  void reloadApi() {
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
    final String uri = "${dotenv.env['API_URL']}csv/fetchCsvApiV2.php";
    var _body = {
      "serverkey": _serverKey.text,
      "page": _page.toString(),
      "limit": _limit.toString(),
      "mobile": _userMobile.text
    };
    var _res = await getDataWithPost(uri, _body);
    response = _res?.body;

    if (response != null) {
      var _json = List<Map>.from(jsonDecode(response)['data']);
      _analysis[0]["value"] = jsonDecode(response)['total_quantity'];
      total_set_quantity_solea.text = jsonDecode(response)['total_set_quantity_solea'];
      total_pair_quantity_solea.text = jsonDecode(response)['total_pair_quantity_solea'];
      total_carton_quantity_solea.text = jsonDecode(response)['total_carton_quantity_solea'];
      total_set_quantity_slikers.text = jsonDecode(response)['total_set_quantity_slikers'];
      total_pair_quantity_slikers.text = jsonDecode(response)['total_pair_quantity_slikers'];
      total_carton_quantity_slikers.text = jsonDecode(response)['total_carton_quantity_slikers'];
      total_set_quantity_ptoes.text = jsonDecode(response)['total_set_quantity_ptoes'];
      total_pair_quantity_ptoes.text = jsonDecode(response)['total_pair_quantity_ptoes'];
      total_carton_quantity_ptoes.text = jsonDecode(response)['total_carton_quantity_ptoes'];
      total_set_quantity_vertex.text = jsonDecode(response)['total_set_quantity_vertex'];
      total_pair_quantity_vertex.text = jsonDecode(response)['total_pair_quantity_vertex'];
      total_carton_quantity_vertex.text = jsonDecode(response)['total_carton_quantity_vertex'];
      if (jsonDecode(response)['message'] != "NoData") {
        if (_json.isNotEmpty) {
          _lister = _json;
        } else {
          showSnackBar(context, "No more data", "Ok");
        }
      } else {
        _lister = [];
      }
    } else {
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

  void _logout() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('This will logout you account on this device.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: "Roboto-Regular"),
            ),
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
            child: const Text(
              "Logout",
              style: TextStyle(fontFamily: "Roboto-Regular"),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
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
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ProfileScreen()));
        break;
      case "Admin":
        _launchUrl(context, "${dotenv.env['API_URL']}admin/index.php");
        break;
      case "Export":
        _launchUrl(context,
            "${dotenv.env['API_URL']}admin/foruser.php?id=${_serverKey.text}&mobile=${_userMobile.text}");
        break;
      case "Logout":
        _logout();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          width: 100,
          height: 50,
          child: Image.asset("assets/images/download.png"),
        ),
        backgroundColor: const Color(0xFFdcdaf5),
        actions: <Widget>[
          OutlinedButton(
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => ServerScreen()));
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
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              await _firstLoad(true);
            },
            child: Container(
              color: const Color(0xFFdcdaf5),
              child: ListView(
                padding: const EdgeInsets.all(0),
                children: [
                  _buildSchemeTable([
                    ["Set", total_set_quantity_solea.text, total_set_quantity_vertex.text, total_set_quantity_ptoes.text, total_set_quantity_slikers.text],
                    ["Pair", total_pair_quantity_solea.text, total_pair_quantity_vertex.text, total_pair_quantity_ptoes.text, total_pair_quantity_slikers.text],
                    ["Carton", total_carton_quantity_solea.text, total_carton_quantity_vertex.text, total_carton_quantity_ptoes.text, total_carton_quantity_slikers.text],
                  ]),
                  _lister.isNotEmpty
                  ? DetailTable(List<Map<String, dynamic>>.from(_lister),  refreshHome: reloadApi)
                      : const Center(child: Text("No data available")),
                  const SizedBox(
                    height: 30,
                  )
                ],
              ),
            ),
          ),
          CustomLoader(isLoading: _isLoading),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ScannerPage(_userMobile.text, refreshHome: reloadApi)));
        },
        label: const Text(
          "Scan QR",
          style: TextStyle(fontFamily: "Roboto-Regular"),
        ),
        icon: const Icon(Icons.qr_code_scanner),
      ),
    );
  }
}

// Scheme Table
Widget _buildSchemeTable(final List<List<String>> _rows) {
  final headers = ["Total Qty", "Scheme 1", "Scheme 2", "Scheme 3", "Scheme 4"];
  final rows = _rows;

  return Card(
    margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: const BoxDecoration(
            color: Colors.teal,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: const Text(
            "Summary",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),

        // Table (stretch full width)
        SizedBox(
          width: double.infinity, // 👈 forces full width
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
            headingTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 10
            ),
            dataTextStyle: const TextStyle(fontSize: 10),
            columnSpacing: 12,
            horizontalMargin: 12,
            border: TableBorder(
              horizontalInside:
              BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            columns: headers
                .map(
                  (h) => DataColumn(
                label: Expanded(
                  child: Text(
                    h,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
                .toList(),
            rows: rows
                .map(
                  (row) => DataRow(
                cells: row
                    .map(
                      (cell) => DataCell(
                    Center(
                      child: Text(
                        cell,
                        style: row.first == cell
                            ? const TextStyle(
                          fontWeight: FontWeight.bold,
                        )
                            : null,
                      ),
                    ),
                  ),
                )
                    .toList(),
              ),
            )
                .toList(),
          ),
        ),
      ],
    ),
  );
}




