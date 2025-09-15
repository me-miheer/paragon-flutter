import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:paragon/extensions/loader.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../apis/auth.dart';
import '../extensions/snackbar.dart';

class ProfileScreen extends StatefulWidget{
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  dynamic response;
  bool _isLoading = false;

  TextEditingController _nameInput = TextEditingController();
  TextEditingController _shopNameInput = TextEditingController();
  TextEditingController _townInput = TextEditingController();
  TextEditingController _emailInput = TextEditingController();
  TextEditingController _mobileInput = TextEditingController();
  TextEditingController _retailType = TextEditingController();
  final _retailTypeList = ["Retail", "Dealer"];

  @override
  void initState() {
    super.initState();
    _initialTask();
  }

  void _creationError(String title, String desc){
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
                Expanded(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(title, style: TextStyle(fontFamily: "Roboto-Regular", fontSize: 25),),
                    Text(desc, style: TextStyle(fontFamily: "Roboto-Regular", fontSize: 12, color: Colors.grey),)
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
    );
  }


  Future<void> _initialTask()async {
    setState(() {
      _isLoading = true;
    });
    final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
    final String? usersData = await asyncPrefs.getString('user');
    var _userJson = jsonDecode(jsonDecode(usersData!));
    print(_userJson);
    _nameInput.text = _userJson['name'];
    _shopNameInput.text = _userJson['shop'];
    _townInput.text = _userJson['town'];
    _emailInput.text = _userJson['email'];
    _mobileInput.text = _userJson['mobile'];
    _retailType.text = _userJson['retailType'];

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  const Text("Profile", style: TextStyle(fontFamily: "Roboto-Regular"),),
        backgroundColor: const Color(0xFFdcdaf5),
        actions: [
          ElevatedButton(onPressed: () async {
              if(_formKey.currentState!.validate()){
                setState(() {
                  _isLoading = true;
                });

              final String _createUserUrl = "${dotenv.env['API_URL']}auth/updateUser.php";
              var _body = {
                "name": _nameInput.text,
                "email": _emailInput.text,
                "mobile": _mobileInput.text,
                "dealer": _emailInput.text,
                "retailType": _retailType.text,
                "shop": _shopNameInput.text,
                "town": _townInput.text,
              };

              var _res = await getDataWithPost(_createUserUrl, _body);

              response = _res?.body;

              if (response != null) {
                if (jsonDecode(response)['task_status'] == "true") {
                  setState(() {
                    _isLoading = false;
                  });

                  final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
                  await asyncPrefs.setString("user", jsonEncode(response));

                  showModalBottomSheet<void>(
                    context: context,
                    isDismissible: true,
                    enableDrag: true,
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
                                        "Profile has been updated successfully.",
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
                  );

                } else {
                  setState(() {
                    _isLoading = false;
                  });
                  showSnackBar(context, jsonDecode(response)['message'], "OK");
                }
              } else {
                setState(() {
                  _isLoading = false;
                });
                _creationError("Something went wrong","Please try again letter.");
              }
            }
          },style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0056cd), foregroundColor: Colors.white),child: const Text("Save", style: TextStyle(fontFamily: "Roboto-Regular"),)),
          const SizedBox(width: 15,)
        ],
      ),
      body: Stack(
        children: [
          const SizedBox(height: 15,),
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Name",
                            labelStyle: TextStyle(fontFamily: "Roboto-Regular"),
                            errorStyle: TextStyle(fontFamily: "Roboto-Regular", color: Colors.red)
                        ),validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'This field cannot be empty'; // Error message
                        }
                        return null; // No error
                      },
                        controller: _nameInput,
                      ),
                      const SizedBox(height: 30,),
                      TextFormField(
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Shop Name",
                            labelStyle: TextStyle(fontFamily: "Roboto-Regular"),
                            errorStyle: TextStyle(fontFamily: "Roboto-Regular", color: Colors.red)
                        ),validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'This field cannot be empty'; // Error message
                        }
                        return null; // No error
                      },
                        controller: _shopNameInput,
                      ),
                      const SizedBox(height: 30,),
                      TextFormField(
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Town",
                            labelStyle: TextStyle(fontFamily: "Roboto-Regular"),
                            errorStyle: TextStyle(fontFamily: "Roboto-Regular", color: Colors.red)
                        ),validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'This field cannot be empty'; // Error message
                        }
                        return null; // No error
                      },
                        controller: _townInput,
                      ),
                      SizedBox(height: 30,),
                      DropdownButtonFormField<String>(
                        value: _retailType.text,
                        decoration: const InputDecoration(
                          labelText: 'Meet Type',
                          labelStyle: TextStyle(fontFamily: "Roboto-Regular"),
                          border:
                          OutlineInputBorder(), // Adds the TextField-like border
                          contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        ),
                        items: _retailTypeList.map((element) {
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
                            _retailType.text = value!;
                          });
                        },
                      )
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