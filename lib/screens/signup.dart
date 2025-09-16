import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:paragon/extensions/loader.dart';

import '../apis/auth.dart';
import '../extensions/snackbar.dart';

class SignupScreen extends StatefulWidget{
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  dynamic response;
  TextEditingController _nameInput = TextEditingController();
  TextEditingController _emailInput = TextEditingController();
  TextEditingController _mobileInput = TextEditingController();
  TextEditingController _dealerInput = TextEditingController();
  TextEditingController _shopInput = TextEditingController();
  TextEditingController _townInput = TextEditingController();
  TextEditingController _passwordInput = TextEditingController();
  TextEditingController _confirmPasswordInput = TextEditingController();
  TextEditingController _retailType = TextEditingController();
  final _retailTypeList = ["Retail", "Dealer"];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create new account", style: TextStyle(fontFamily: "Roboto-Regular"),),
        backgroundColor: const Color(0xFFdcdaf5),
        actions: [
          ElevatedButton(onPressed: () async {
            if(_formKey.currentState!.validate()){

              setState(() {
                _isLoading = true;
              });

              final String _createUserUrl = "${dotenv.env['API_URL']}auth/createUser.php";
              var _body = {
                "name": _nameInput.text,
                "email": _emailInput.text,
                "mobile": _mobileInput.text,
                "dealer": _dealerInput.text,
                "shop": _shopInput.text,
                "town": _townInput.text,
                "password": _passwordInput.text,
                "retailType": _retailType.text
              };

              var _res = await getDataWithPost(_createUserUrl, _body);

              response = _res?.body;  // Store the response body for display or further processing

              if (response != null) {
                if (jsonDecode(response)['task_status'] == "true") {
                  setState(() {
                    _isLoading = false;
                  });

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
                                        "Profile has been created successfully.",
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
                                  child: const Text("Login"),
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
          },style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0056cd), foregroundColor: Colors.white),child: const Text("Create", style: TextStyle(fontFamily: "Roboto-Regular"),)),
          SizedBox(width: 15,)
        ],
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Padding(padding: EdgeInsets.all(15.0),
              child: Column(
                children: [
                  SizedBox(height: 15,),
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
                  ),SizedBox(height: 30,),
                  TextFormField(
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Email address",
                        labelStyle: TextStyle(fontFamily: "Roboto-Regular"),
                        errorStyle: TextStyle(fontFamily: "Roboto-Regular", color: Colors.red)
                    ),validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field cannot be empty'; // Error message
                    }
                    return null; // No error
                  },
                    controller: _emailInput,
                  ),SizedBox(height: 30,),
                  TextFormField(
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Mobile number",
                        labelStyle: TextStyle(fontFamily: "Roboto-Regular"),
                        errorStyle: TextStyle(fontFamily: "Roboto-Regular", color: Colors.red)
                    ),validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field cannot be empty'; // Error message
                    }else if(value.length != 10){
                      return 'Mobile number can be only 10 digits'; // Error message
                    }
                    return null; // No error
                  },
                    controller: _mobileInput,
                  ),SizedBox(height: 30,),
                  TextFormField(
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Dealer / Depot",
                        labelStyle: TextStyle(fontFamily: "Roboto-Regular"),
                        errorStyle: TextStyle(fontFamily: "Roboto-Regular", color: Colors.red)
                    ),validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field cannot be empty'; // Error message
                    }
                    return null; // No error
                  },
                    controller: _dealerInput,
                  ),SizedBox(height: 30,),
                  TextFormField(
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Shop name",
                        labelStyle: TextStyle(fontFamily: "Roboto-Regular"),
                        errorStyle: TextStyle(fontFamily: "Roboto-Regular", color: Colors.red)
                    ),validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field cannot be empty'; // Error message
                    }
                    return null; // No error
                  },
                    controller: _shopInput,
                  ),SizedBox(height: 30,),
                  TextFormField(
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Town / City",
                        labelStyle: TextStyle(fontFamily: "Roboto-Regular"),
                        errorStyle: TextStyle(fontFamily: "Roboto-Regular", color: Colors.red)
                    ),validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field cannot be empty'; // Error message
                    }
                    return null; // No error
                  },
                    controller: _townInput,
                  ),SizedBox(height: 30,),
                  DropdownButtonFormField<String>(
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
                  ),
                  SizedBox(height: 30,),
                  TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Password",
                        labelStyle: TextStyle(fontFamily: "Roboto-Regular"),
                        errorStyle: TextStyle(fontFamily: "Roboto-Regular", color: Colors.red)
                    ),validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field cannot be empty'; // Error message
                    }else if(value != _confirmPasswordInput.text){
                      return "Both passwords should match";
                    }
                    return null;// No error
                  },
                    controller: _passwordInput,
                  ),SizedBox(height: 30,),
                  TextFormField(
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Confirm password",
                        labelStyle: TextStyle(fontFamily: "Roboto-Regular"),
                        errorStyle: TextStyle(fontFamily: "Roboto-Regular", color: Colors.red)
                    ),validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field cannot be empty'; // Error message
                    }else if(value != _passwordInput.text){
                      return "Both passwords should match";
                    }
                    return null; // No error
                  },
                    controller: _confirmPasswordInput,
                  ),SizedBox(height: 30,)
                ],
              ),),
            ),
          ),
          CustomLoader(isLoading: _isLoading)
        ],
      ),
    );
  }
}