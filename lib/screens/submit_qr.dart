import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:paragon/extensions/loader.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../apis/auth.dart';

class SubmitScreen extends StatefulWidget {
  final String article;
  final String gender;

  const SubmitScreen(this.article, this.gender, {super.key});

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

  final TextEditingController _articleInput = TextEditingController();

  final TextEditingController _quantityInput = TextEditingController();

  final TextEditingController _typeInput = TextEditingController();

  final TextEditingController _consumeInput = TextEditingController();

  final TextEditingController _sizeInput = TextEditingController();

  final _typeSelection = ["Set", "Pair", "Carton"];
  var _sizeSelection = [];

  @override
  void initState() {
    super.initState();
    _consumeInput.text = widget.gender;
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
      _userType = _userJson['user_type'];
    });
  }

  Future<void> _getSize() async {

    setState(() {
      _isLoading = true;
    });

    final String _qrCheckerUrl =
        "${dotenv.env['API_URL']}settings/appSizes.php?key=${widget.gender!}";
    var res = await getDataWithPost(_qrCheckerUrl, {});

    response =
        res?.body; // Store the response body for display or further processing

    if (response != null) {
      var _decodedResponse = jsonDecode(response);
      if (_decodedResponse['task_status'] == "true") {
        _sizeSelection = List<String>.from(_decodedResponse['gender']);
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
                foregroundColor: Colors.white
              ),
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
                        final String? _server = await _asyncPrefs.getString('server')!;
                        final String? _serverkey = await _asyncPrefs.getString('serverkey')!;
                        var _userJson = jsonDecode(jsonDecode(usersData!));
                        final String _sumbmitUrl =
                            "${dotenv.env['API_URL']}csv/csvCreate.php?key=${widget.gender!}";

                        var res = await getDataWithPost(_sumbmitUrl, {
                          "qr": _articleInput.text,
                          "name": _userJson['name'],
                          "quantity": _quantityInput.text,
                          "dealer": _userJson['dealer'] ?? "none",
                          "shop": _userJson['shop'],
                          "mobile": _userJson['mobile'],
                          "type": _typeInput.text,
                          "town": _userJson['town'],
                          "consumer": _consumeInput.text,
                          "consumerSize": _sizeInput.text,
                          "serverkey": _serverkey,
                          "server": _serverkey
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
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(0),
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            textStyle:
                                const TextStyle(fontFamily: "Roboto-Regular"),
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(3)))),
                        onPressed: () {},
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text(_userName ?? "Unknown",
                              style: const TextStyle(fontFamily: "Roboto-Regular")),
                          subtitle: Text(
                            _userType ?? "Unknown",
                            style: const TextStyle(fontFamily: "Roboto-Regular"),
                          ),
                          trailing: const Icon(Icons.arrow_drop_down),
                        ),
                      ),
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
                          errorStyle: TextStyle(fontFamily: "Roboto-Regular", color: Colors.red)),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    TextFormField(
                      obscureText: false,
                      controller: _quantityInput,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'This field cannot be empty'; // Error message
                        }
                        return null; // No error
                      },
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Quantity",
                          labelStyle: TextStyle(fontFamily: "Roboto-Regular"),
                          errorStyle: TextStyle(color: Colors.red)),
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
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
                      onChanged: (String? value) {
                        setState(() {
                          _typeInput.text = value!;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    TextFormField(
                      controller: _consumeInput,
                      obscureText: false,
                      readOnly: true,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'This field cannot be empty'; // Error message
                        }
                        return null; // No error
                      },
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Consumer",
                          errorStyle: TextStyle(color: Colors.red)),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Select a size',
                        labelStyle: TextStyle(fontFamily: "Roboto-Regular"),
                        border:
                            OutlineInputBorder(), // Adds the TextField-like border
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      items: _sizeSelection.map((element) {
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
                          return 'Please select a size'; // Error message
                        }
                        return null; // No error
                      },
                      onChanged: (String? value) {
                        setState(() {
                          _sizeInput.text = value!;
                        });
                      },
                    ),
                  ],
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
