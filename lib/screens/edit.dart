import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:paragon/extensions/loader.dart';

import '../apis/auth.dart';
import '../extensions/snackbar.dart';

class EditScreen extends StatefulWidget {

  final String articleProps;
  final String sizeProps;
  final String typeProps;
  final String quantityProps;
  final String idProps;
  final String consumerProps;
  final VoidCallback? reloadApi;

  const EditScreen(
      this.articleProps,
      this.sizeProps,
      this.typeProps,
      this.quantityProps,
      this.idProps,
      this.consumerProps,
      this.reloadApi
      , {
        super.key,
      });

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  bool _showButton = false;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  dynamic response;
  var _sizeSelection = [];
  final _typeSelection = ["Set", "Pair", "Carton"];
  TextEditingController _articleInput = TextEditingController();
  TextEditingController _sizeInput = TextEditingController();
  TextEditingController _typeInput = TextEditingController();
  TextEditingController _quantityInput = TextEditingController();
  TextEditingController _idInput = TextEditingController();
  TextEditingController _consumerInput = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initialState();
    _getSize();
  }

  Future<void> _initialState()async {
     _articleInput.text = widget.articleProps;
     _sizeInput.text = widget.sizeProps;
     _typeInput.text = widget.typeProps;
     _quantityInput.text = widget.quantityProps;
     _idInput.text = widget.idProps;
     _consumerInput.text = widget.consumerProps;
  }

  void handleClick(String item) {
    switch (item) {
      case "Delete":
        _deleteFunc();
        break;
    }
  }

  Future<void> _deleteFunc()async {
    setState(() {
      _isLoading = true;
    });

    var body = {
      "id": _idInput.text
    };

    final String sumbmitUrl =
        "${dotenv.env['API_URL']}csv/csvDelete.php";

    var res = await getDataWithPost(sumbmitUrl, body);

    response = res?.body;

    if (response != null) {
      if (jsonDecode(response)['task_status'] == "true") {
        setState(() {
          _isLoading = false;
          widget.reloadApi!();
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
                              "Deleted submitted successfully.",
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
        showSnackBar(context, jsonDecode(response)['message'], "OK");
      }
    } else {
      showSnackBar(context, "Something went wrong", "OK");
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _getSize() async {

    setState(() {
      _isLoading = true;
    });

    final String _qrCheckerUrl =
        "${dotenv.env['API_URL']}settings/appSizes.php?key=${widget.consumerProps!}";
    var res = await getDataWithPost(_qrCheckerUrl, {});

    response =
        res?.body; // Store the response body for display or further processing

    if (response != null) {
      var decodedResponse = jsonDecode(response);
      if (decodedResponse['task_status'] == "true") {
        _sizeSelection = List<String>.from(decodedResponse['gender']);
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
        title: Text(widget.articleProps,
            style: const TextStyle(fontFamily: "Roboto-Regular")),
        backgroundColor: const Color(0xFFdcdaf5),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if(_formKey.currentState!.validate()){

                setState(() {
                  _isLoading = true;
                });

                var body = {
                  "quantity" : _quantityInput.text,
                  "type" : _typeInput.text,
                  "consumer_size" : _sizeInput.text,
                  "id": _idInput.text
                };

                final String sumbmitUrl =
                    "${dotenv.env['API_URL']}csv/updatedCsvApi.php";

                var res = await getDataWithPost(sumbmitUrl, body);

                response = res?.body;

                if (response != null) {
                  if (jsonDecode(response)['task_status'] == "true") {
                    showSnackBar(context, "Updated successfully!", "OK");
                    widget.reloadApi!();
                  } else {
                    showSnackBar(context, jsonDecode(response)['message'], "OK");
                  }
                } else {
                  showSnackBar(context, "Something went wrong", "OK");
                }

                setState(() {
                  _isLoading = false;
                });


              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0056cd),
                foregroundColor: Colors.white),
            child: const Text(
              "Update",
              style: TextStyle(fontFamily: "Roboto-Regular"),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (item) => handleClick(item),
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                  value: "Delete",
                  child: Text(
                    'Delete',
                    style: TextStyle(fontFamily: "Roboto-Regular"),
                  )),
            ],
          )
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 15,
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
                      const SizedBox(height: 30,),
                      TextFormField(
                        controller: _quantityInput,
                        obscureText: false,
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
                            errorStyle: TextStyle(fontFamily: "Roboto-Regular", color: Colors.red)),
                      ),
                      const SizedBox(height: 30,),
                      DropdownButtonFormField<String>(
                        value: _typeInput.text,
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
                      const SizedBox(height: 30,),
                      TextFormField(
                        controller: _consumerInput,
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
                            labelText: "Consumer",
                            labelStyle: TextStyle(fontFamily: "Roboto-Regular"),
                            errorStyle: TextStyle(fontFamily: "Roboto-Regular", color: Colors.red)),
                      ),
                      const SizedBox(height: 30,),
                      DropdownButtonFormField<String>(
                        value: _sizeInput.text,
                        decoration: const InputDecoration(
                          labelText: 'Size',
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
          ),
          CustomLoader(isLoading: _isLoading)
        ],
      ),
    );
  }
}
