import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:paragon/extensions/loader.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../apis/auth.dart';

class SizeQuantity {
  String? size;
  String? quantity;
  // Add this line
  TextEditingController quantityController;

  SizeQuantity({this.size, this.quantity})
      : quantityController = TextEditingController(text: quantity);
}

class SubmitScreen extends StatefulWidget {
  final String article;
  final String slicker;

  const SubmitScreen(this.article, this.slicker, {super.key});

  @override
  State<SubmitScreen> createState() => _SubmitScreenState();
}

class _SubmitScreenState extends State<SubmitScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  var _userName;
  var _userType;
  dynamic response;
  bool _showButton = true;
  List<String?> selectedSizes = [null];
  List<SizeQuantity> sizeQuantities = [SizeQuantity()];
  bool _isTypeSelected = false; // ✅ Track if type already selected


  final TextEditingController _articleInput = TextEditingController();

  final TextEditingController _typeInput = TextEditingController();

  // Instead of fixed list, keep a dynamic one
  List<String> _typeSelection = [];

  List<String> _allTypes = ["Set", "Pair", "Carton"]; // ✅ Keep master list
  List<String> _sizeSelection = [];

  @override
  void initState() {
    super.initState();
    _articleInput.text = widget.article;
    _setUser();
    _getSize();
  }

  Future<void> _setUser() async {
    final SharedPreferencesAsync _asyncPrefs = await SharedPreferencesAsync();
    final String? usersData = await _asyncPrefs.getString('user');
    var _userJson = jsonDecode(jsonDecode(usersData!));
    setState(() {
      _userName = _userJson['name'];
      _userType = _userJson['user_type'] == "admin" ? _userJson['user_type'] : _userJson['retailType'] ;
      // ✅ Restrict dropdown for Dealer
      if (_userJson['retailType'] == "Dealer") {
        _typeSelection = ["Carton"];
      } else {
        _typeSelection = _allTypes;
      }
    });
  }

  Future<void> _getSize() async {
    setState(() {
      _isLoading = true;
    });

    final String _qrCheckerUrl =
        "${dotenv.env['API_URL']}settings/appSizes.php?key=${widget.article!}";
    var res = await getDataWithPost(_qrCheckerUrl, {});

    response =
        res?.body; // Store the response body for display or further processing

    if (response != null) {
      var _decodedResponse = jsonDecode(response);
      if (_decodedResponse['task_status'] == "true") {
        _sizeSelection = List<String>.from(_decodedResponse['sizes']);
      } else {
        _showButton = false;
      }
    } else {
      _showButton = false;
    }

    setState(() {
      _isLoading = false; // Hide the loader
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Submit article",
            style: TextStyle(fontFamily: "Roboto-Regular")),
        backgroundColor: const Color(0xFFdcdaf5),
        actions: <Widget>[
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0056cd),
                  foregroundColor: Colors.white),
              onPressed: _showButton
                  ? () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _isLoading = true;
                        });
                        //   On sumit function
                        final SharedPreferencesAsync _asyncPrefs =
                            await SharedPreferencesAsync();
                        final String? usersData =
                            await _asyncPrefs.getString('user');
                        final String? _server =
                            await _asyncPrefs.getString('server')!;
                        final String? _serverkey =
                            await _asyncPrefs.getString('serverkey')!;
                        var _userJson = jsonDecode(jsonDecode(usersData!));
                        final String _sumbmitUrl =
                            "${dotenv.env['API_URL']}csv/csvCreateDynamic.php?key=${widget.slicker}";

                        var consumerData = sizeQuantities
                            .map((sq) =>
                                {"size": sq.size, "quantity": sq.quantity})
                            .toList();
                        String consumerDataString = jsonEncode(consumerData);

                        var res = await getDataWithPost(_sumbmitUrl, {
                          "qr": _articleInput.text,
                          "name": _userJson['name'],
                          "dealer": _userJson['dealer'] ?? "none",
                          "shop": _userJson['shop'],
                          "mobile": _userJson['mobile'],
                          "retailType": _userJson['retailType'],
                          "type": _typeInput.text,
                          "town": _userJson['town'],
                          "consumer": widget.slicker,
                          "consumerSizes": consumerDataString,
                          "serverkey": _serverkey,
                          "server": _server
                        });

                        setState(() {
                          response = res
                              ?.body; // Store the response body for display or further processing
                          _isLoading = false; // Hide the loader
                        });

                        if (response != null) {
                          if (jsonDecode(response)['task_status'] == "true") {
                            showModalBottomSheet<void>(
                              context: context,
                              isDismissible: false,
                              enableDrag: false,
                              builder: (BuildContext context) {
                                return SizedBox(
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Expanded(
                                            child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 100,
                                              height: 100,
                                              child: Image.asset(
                                                  "assets/images/5290058.png"),
                                            ),
                                            const Text(
                                              "Success",
                                              style: TextStyle(
                                                  fontFamily: "Roboto-Regular",
                                                  fontSize: 25),
                                            ),
                                            const Text(
                                              "Article submitted successfully.",
                                              style: TextStyle(
                                                  fontFamily: "Roboto-Regular",
                                                  fontSize: 12,
                                                  color: Colors.grey),
                                            )
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
                                                textStyle: const TextStyle(
                                                    fontFamily:
                                                        "Roboto-Regular"),
                                                shape:
                                                    const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    3)))),
                                            child: const Text("Got It"),
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
                          } else {
                            showModalBottomSheet<void>(
                              context: context,
                              isDismissible: false,
                              enableDrag: false,
                              builder: (BuildContext context) {
                                return SizedBox(
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        const Expanded(
                                            child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Something went wrong",
                                              style: TextStyle(
                                                  fontFamily: "Roboto-Regular",
                                                  fontSize: 25),
                                            ),
                                            Text(
                                              "Please try again letter.",
                                              style: TextStyle(
                                                  fontFamily: "Roboto-Regular",
                                                  fontSize: 12,
                                                  color: Colors.grey),
                                            )
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
                                                textStyle: const TextStyle(
                                                    fontFamily:
                                                        "Roboto-Regular"),
                                                shape:
                                                    const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    3)))),
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
                        } else {
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Something went wrong",
                                            style: TextStyle(
                                                fontFamily: "Roboto-Regular",
                                                fontSize: 25),
                                          ),
                                          Text(
                                            "Please try again letter.",
                                            style: TextStyle(
                                                fontFamily: "Roboto-Regular",
                                                fontSize: 12,
                                                color: Colors.grey),
                                          )
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
                                              textStyle: const TextStyle(
                                                  fontFamily: "Roboto-Regular"),
                                              shape:
                                                  const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  3)))),
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
                      }
                    }
                  : null,
              child: const Text("Submit",
                  style: TextStyle(fontFamily: "Roboto-Regular"))),
          Container(
            width: 15,
          )
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(0),
                        width: double.infinity,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                textStyle: const TextStyle(
                                    fontFamily: "Roboto-Regular"),
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(3)))),
                            onPressed: () {},
                            child: Stack(
                              children: [
                                ListTile(
                                  leading: const CircleAvatar(
                                    child: Icon(Icons.person),
                                  ),
                                  title: Text(
                                    _userName ?? "Unknown",
                                    style: const TextStyle(
                                        fontFamily: "Roboto-Regular"),
                                  ),
                                  subtitle: Text(
                                    _userType ?? "Unknown",
                                    style: const TextStyle(
                                        fontFamily: "Roboto-Regular"),
                                  ),
                                  trailing: const Icon(Icons.arrow_drop_down),
                                ),

                                // Banner on top-left of ListTile
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.blue, // banner color
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(4),
                                        bottomRight: Radius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      widget.slicker, // your banner text
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Roboto-Regular",
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      TextFormField(
                        controller: _articleInput,
                        obscureText: false,
                        readOnly: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'This field cannot be empty'; // Error message
                          }
                          return null; // No error
                        },
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Article",
                            labelStyle: TextStyle(fontFamily: "Roboto-Regular"),
                            errorStyle: TextStyle(
                                fontFamily: "Roboto-Regular",
                                color: Colors.red)),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Select a type',
                          labelStyle: TextStyle(fontFamily: "Roboto-Regular"),
                          border:
                              OutlineInputBorder(), // Adds the TextField-like border
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                        ),
                        items: _typeSelection.map((element) {
                          return DropdownMenuItem<String>(
                            value:
                                element, // The value that will be passed when this item is selected
                            child: Text(
                              element,
                              style:
                                  const TextStyle(fontFamily: "Roboto-Regular"),
                            ), // The displayed text in the dropdown menu
                          );
                        }).toList(),
                        isExpanded: true,
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a type'; // Error message
                          }
                          return null; // No error
                        },
                        onChanged: _isTypeSelected
                            ? null // ✅ disable after first selection
                            : (String? value) {
                          setState(() {
                            _typeInput.text = value!;
                            _isTypeSelected = true; // ✅ lock dropdown
                          });
                        },
                        value: _typeInput.text.isNotEmpty ? _typeInput.text : null, // keep selected
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: sizeQuantities.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(top: 30),
                            child: Row(
                              children: [
                                // Size dropdown
                                Expanded(
                                  flex: 2,
                                  child: DropdownSearch<String>(
                                    items: _sizeSelection
                                        .where((s) =>
                                            // Keep sizes not chosen OR the one currently selected in this block
                                            !sizeQuantities
                                                .where((sq) =>
                                                    sq != sizeQuantities[index])
                                                .map((sq) => sq.size)
                                                .contains(s))
                                        .toList(),
                                    selectedItem: sizeQuantities[index].size,
                                    dropdownDecoratorProps:
                                        const DropDownDecoratorProps(
                                      dropdownSearchDecoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: "Size",
                                        labelStyle: TextStyle(
                                            fontFamily: "Roboto-Regular"),
                                        errorStyle: TextStyle(
                                          fontFamily: "Roboto-Regular",
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                    popupProps: const PopupProps.menu(
                                      showSearchBox: true,
                                    ),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        sizeQuantities[index].size = newValue;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select a size';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // Quantity field
                              // In your ListView.builder's itemBuilder for the Quantity field
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  // Change this line
                                  controller: sizeQuantities[index].quantityController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "Quantity",
                                    labelStyle: TextStyle(fontFamily: "Roboto-Regular"),
                                    errorStyle: TextStyle(color: Colors.red),
                                  ),
                                  onChanged: (value) {
                                    sizeQuantities[index].quantity = value;
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter quantity';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                                const SizedBox(width: 10),

                                // Add / Remove button
                            // In your ListView.builder...
                            IconButton(
                              icon: Icon(
                                Icons.remove_circle,
                                color: sizeQuantities.length > 1 ? Colors.red : Colors.grey, // Change color to show if disabled
                              ),
                              onPressed: sizeQuantities.length > 1
                                  ? () {
                                setState(() {
                                  sizeQuantities.removeAt(index);
                                });
                              }
                                  : null, // Disable the button if it's the last item
                            ),
                              ],
                            ),
                          );
                        },
                      ),const SizedBox(height: 5),
                      Center(
                        // Wrap with Center to control width and keep it centered
                        child: SizedBox(
                          // Use SizedBox to set a maximum width
                          width: MediaQuery.of(context).size.width *
                              0.8, // 80% of screen width, adjust as needed
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                sizeQuantities.add(SizeQuantity());
                              });
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Size & Quantity'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              Colors.black, // Set background color to black
                              foregroundColor:
                              Colors.white, // Text and icon color
                              minimumSize: const Size(double.infinity,
                                  50), // This will now take 100% of SizedBox's width
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          CustomLoader(isLoading: _isLoading)
        ],
      ),
    );
  }
}
