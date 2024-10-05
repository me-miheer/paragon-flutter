import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:paragon/extensions/loader.dart';

import '../apis/auth.dart';
import '../extensions/snackbar.dart';

class ForgetScreen extends StatefulWidget{
  const ForgetScreen({super.key});

  @override
  State<ForgetScreen> createState() => _ForgetScreenState();
}

class _ForgetScreenState extends State<ForgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isReset = true;
  dynamic response;
  dynamic response2;
  TextEditingController _emailInput = TextEditingController();
  TextEditingController _passwordInput = TextEditingController();
  TextEditingController _confirmPasswordInput = TextEditingController();
  TextEditingController _userIdInput = TextEditingController();

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
        title:  const Text("Reset password", style: TextStyle(fontFamily: "Roboto-Regular"),),
        backgroundColor: const Color(0xFFdcdaf5),
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            alignment: AlignmentDirectional.center,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(alignment: AlignmentDirectional.centerStart,child: Text(_isReset?"Forget password?":"New password", style: const TextStyle(fontSize: 25, fontFamily: "Roboto-Regular"),),),
                    Container(alignment: AlignmentDirectional.centerStart,child: Text(_isReset?"Reset your password here":"Enter new password here", style: TextStyle(fontSize: 12, color: Colors.grey, fontFamily: "Roboto-Regular"),),),
                    SizedBox(height: 20,),
                    _isReset?Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Email or Mobile number",
                                labelStyle: TextStyle(fontFamily: "Roboto-Regular"),
                                errorStyle: TextStyle(fontFamily: "Roboto-Regular", color: Colors.red)
                            ),validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'This field cannot be empty'; // Error message
                            }
                            return null; // No error
                          },
                            controller: _emailInput,
                          ),
                          SizedBox(height: 30,),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                                onPressed: () async {
                                  if(_formKey.currentState!.validate()){
                                    setState(() {
                                      _isLoading = true;
                                    });

                                    final String _checkEmailUrl = "${dotenv.env['API_URL']}auth/checkUser.php";
                                    var _res = await getDataWithPost(_checkEmailUrl, {
                                      "username": _emailInput.text
                                    });

                                    response = _res?.body;

                                    if (response != null) {
                                      if (jsonDecode(response)['task_status'] == "true") {
                                        setState(() {
                                          _isLoading = false;
                                          _isReset = false;
                                          _userIdInput.text = jsonDecode(response)['userid'];
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
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0056cd),
                                    foregroundColor: Colors.white,
                                    textStyle: const TextStyle(fontFamily: "Roboto-Regular"),
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(3)))),
                                child: const Text("Next")),
                          ),
                        ],
                      ),
                    ):Form(
                      key: _formKey2,
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "New password",
                                labelStyle: TextStyle(fontFamily: "Roboto-Regular"),
                                errorStyle: TextStyle(fontFamily: "Roboto-Regular", color: Colors.red)
                            ),validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'This field cannot be empty'; // Error message
                            }else if(value != _confirmPasswordInput.text){
                              return 'Both passwords must match';
                            }
                            return null; // No error
                          },
                            controller: _passwordInput,
                          ),
                          SizedBox(height: 30,),
                          TextFormField(
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Confirm new Password",
                                labelStyle: TextStyle(fontFamily: "Roboto-Regular"),
                                errorStyle: TextStyle(fontFamily: "Roboto-Regular", color: Colors.red)
                            ),validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'This field cannot be empty'; // Error message
                            }else if(value != _passwordInput.text){
                              return 'Both passwords must match';
                            }
                            return null; // No error
                          },
                            controller: _confirmPasswordInput,
                          ),
                          SizedBox(height: 30,),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                                onPressed: () async {
                                  if(_formKey2.currentState!.validate()){
                                    setState(() {
                                      _isLoading = true;
                                    });

                                    final String _checkEmailUrl = "${dotenv.env['API_URL']}auth/changePassword.php";
                                    var _res = await getDataWithPost(_checkEmailUrl, {
                                      "userid": _userIdInput.text,
                                      "password": _passwordInput.text
                                    });

                                    response = _res?.body;

                                    if (response != null) {
                                      if (jsonDecode(response)['task_status'] == "true") {
                                        setState(() {
                                          _isLoading = false;

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
                                                                "Password has been changed successfully.",
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
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0056cd),
                                    foregroundColor: Colors.white,
                                    textStyle: const TextStyle(fontFamily: "Roboto-Regular"),
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(3)))),
                                child: const Text("Reset password")),
                          ),
                        ],
                      ),
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