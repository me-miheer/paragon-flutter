import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:paragon/extensions/loader.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../apis/auth.dart';
import '../extensions/snackbar.dart';

class SizeQuantity {
  String? size;
  String? quantity;

  TextEditingController quantityController;

  SizeQuantity({this.size, this.quantity})
      : quantityController = TextEditingController(text: quantity);
}

class EditScreen extends StatefulWidget {
  final String article;
  final String slicker;
  final VoidCallback? refreshHome;

  const EditScreen(this.article, this.slicker, {super.key, this.refreshHome});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  var _userName;
  var _userType;
  dynamic response;
  bool _showButton = true;
  List<String?> selectedSizes = [null];
  List<SizeQuantity> sizeQuantities = [SizeQuantity()];

  final TextEditingController _articleInput = TextEditingController();

  final TextEditingController _typeInput = TextEditingController();

  final _typeSelection = ["Set", "Pair", "Carton"];
  List<String> _sizeSelection = [];

  @override
  void initState() {
    super.initState();
    _articleInput.text = widget.article;
    _getSize();
  }

  Future<void> _getSize() async {
    final SharedPreferencesAsync _asyncPrefs = await SharedPreferencesAsync();
    final String? usersData = await _asyncPrefs.getString('user');
    var _userJson = jsonDecode(jsonDecode(usersData!));
    setState(() {
      _userName = _userJson['name'];
      _userType = _userJson['user_type'] == "admin"
          ? _userJson['user_type']
          : _userJson['retailType'];
    });

    setState(() {
      _isLoading = true;
    });

    final String mobnob = _userJson['mobile'];
    final String _qrCheckerUrl =
        "${dotenv.env['API_URL']}settings/appArticleUpdate.php?key=${widget.article}&mobile=${mobnob}";
    var res = await getDataWithPost(_qrCheckerUrl, {});

    response = res?.body;

    if (response != null) {
      var _decodedResponse = jsonDecode(response);

      if (_decodedResponse['task_status'] == "true") {
        var data = _decodedResponse['data'];

        // Prefill article
        _articleInput.text = data['article'] ?? "";

        // Prefill type
        _typeInput.text = data['type'];

        // Prefill sizes with quantities
        List sizes = data['sizes'] ?? [];
        final Map<String, int> sizeMap = {};

        for (var s in sizes) {
          final size = s['size'];
          // Handle case where quantity is not a number or null
          final qty = int.tryParse(s['quantity'].toString()) ?? 0;
          sizeMap[size] = (sizeMap[size] ?? 0) + qty;
        }

// Map the size quantities to a list of SizeQuantity objects
        sizeQuantities = sizeMap.entries.map((entry) {
          return SizeQuantity(
            size: entry.key,
            quantity: entry.value.toString(),
          );
        }).toList();

// Optional: available sizes for dropdown
        _sizeSelection = List<String>.from(_decodedResponse['size']);

        setState(() {});
      } else {
        _showButton = false;
      }
    } else {
      _showButton = false;
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
            appBar: AppBar(
              title: const Text("Edit article",
                  style: TextStyle(fontFamily: "Roboto-Regular")),
              backgroundColor: const Color(0xFFdcdaf5),
              actions: <Widget>[
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white),
                    onPressed: _showButton
                        ? () async {
                            bool? confirmDelete = await showDialog<bool>(
                              context: context,
                              barrierDismissible:
                                  false, // User must tap a button
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Delete Article"),
                                  content: const Text(
                                      "Do you really want to delete this article?"),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(false); // User pressed No
                                      },
                                      child: const Text("No"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(true); // User pressed Yes
                                      },
                                      child: const Text("Yes"),
                                    ),
                                  ],
                                );
                              },
                            );

                            // Check user choice
                            if (confirmDelete != null && confirmDelete) {
                              // User pressed Yes → perform delete action
                              final SharedPreferencesAsync _asyncPrefs =
                                  await SharedPreferencesAsync();
                              final String? usersData =
                                  await _asyncPrefs.getString('user');
                              var _userJson =
                                  jsonDecode(jsonDecode(usersData!));

                              setState(() {
                                _isLoading = true;
                              });

                              final String mobnob = _userJson['mobile'];
                              final String _qrDeleteUrl =
                                  "${dotenv.env['API_URL']}csv/csvDelete.php?article=${widget.article}&mobile=${mobnob}";

                              var res = await getDataWithPost(_qrDeleteUrl, {});

                              

                              response = res?.body;

                              if (response != null) {
                                var _decodedResponse = jsonDecode(response);
                                if (_decodedResponse['task_status'] == "true") {
                                  if (widget.refreshHome != null) {
                                    widget.refreshHome!();
                                  }
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext dialogContext) {
                                      // Delayed auto-close
                                      Future.delayed(const Duration(seconds: 1),
                                          () {
                                        if (Navigator.canPop(dialogContext)) {
                                          Navigator.pop(
                                              dialogContext); // close dialog
                                        }
                                        if (Navigator.canPop(context)) {
                                          Navigator.pop(
                                              context); // close screen
                                        }
                                      });

                                      // **Return a widget here**
                                      return Dialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(
                                                width: 80,
                                                height: 80,
                                                child: Image.asset(
                                                    "assets/images/5290058.png"),
                                              ),
                                              const SizedBox(height: 15),
                                              const Text(
                                                "Success",
                                                style: TextStyle(
                                                  fontFamily: "Roboto-Regular",
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              const Text(
                                                "Article deleted successfully.",
                                                style: TextStyle(
                                                  fontFamily: "Roboto-Regular",
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                } else {
                                  // _showButton = false;
                                }
                              } else {
                                // _showButton = false;
                              }

                              setState(() {
                                _isLoading = false;
                              });
                            }
                          }
                        : null,
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white, // Icon color
                    )),
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
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(3)))),
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
                                        trailing:
                                            const Icon(Icons.arrow_drop_down),
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
                                            borderRadius:
                                                const BorderRadius.only(
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
                                  labelStyle:
                                      TextStyle(fontFamily: "Roboto-Regular"),
                                  errorStyle: TextStyle(
                                      fontFamily: "Roboto-Regular",
                                      color: Colors.red)),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            DropdownButtonFormField<String>(
                              value: _typeInput.text.isEmpty
                                  ? null
                                  : _typeInput.text,
                              decoration: const InputDecoration(
                                labelText: 'Select a type',
                                labelStyle:
                                    TextStyle(fontFamily: "Roboto-Regular"),
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 16),
                              ),
                              items: _typeSelection.map((element) {
                                return DropdownMenuItem<String>(
                                  value: element,
                                  child: Text(
                                    element,
                                    style: const TextStyle(
                                        fontFamily: "Roboto-Regular"),
                                  ),
                                );
                              }).toList(),
                              isExpanded: true,
                              onChanged:
                                  null, // 👈 disables dropdown (readonly)
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
                                                          sq !=
                                                          sizeQuantities[index])
                                                      .map((sq) => sq.size)
                                                      .contains(s))
                                              .toList(),
                                          selectedItem:
                                              sizeQuantities[index].size,
                                          dropdownDecoratorProps:
                                              const DropDownDecoratorProps(
                                            dropdownSearchDecoration:
                                                InputDecoration(
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
                                              sizeQuantities[index].size =
                                                  newValue;
                                            });
                                          },
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please select a size';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 10),

                                      // Quantity field
                                      Expanded(
                                        flex: 2,
                                        child: TextFormField(
                                          controller: sizeQuantities[index]
                                              .quantityController,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: "Quantity",
                                            labelStyle: TextStyle(
                                                fontFamily: "Roboto-Regular"),
                                            errorStyle:
                                                TextStyle(color: Colors.red),
                                          ),
                                          onChanged: (value) {
                                            sizeQuantities[index].quantity =
                                                value;
                                          },
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
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
                                          color: sizeQuantities.length > 1
                                              ? Colors.red
                                              : Colors
                                                  .grey, // Change color to show if disabled
                                        ),
                                        onPressed: sizeQuantities.length > 1
                                            ? () {
                                                setState(() {
                                                  sizeQuantities
                                                      .removeAt(index);
                                                });
                                              }
                                            : null, // Disable the button if it's the last item
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            // After your ListView.builder widget...
                            const SizedBox(height: 5),
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
                                    backgroundColor: Colors
                                        .black, // Set background color to black
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
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
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
                            "${dotenv.env['API_URL']}csv/csvUpdateDynamic.php?key=${widget.slicker!}";

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
                          "consumerSizes": consumerDataString,
                        });

                        setState(() {
                          response = res
                              ?.body; // Store the response body for display or further processing
                          _isLoading = false; // Hide the loader
                        });

                        if (response != null) {
                          if (jsonDecode(response)['task_status'] == "true") {
                            if (widget.refreshHome != null) {
                              widget.refreshHome!();
                            }
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext dialogContext) {
                                // Delayed auto-close
                                Future.delayed(const Duration(seconds: 1), () {
                                  if (Navigator.canPop(dialogContext)) {
                                    Navigator.pop(
                                        dialogContext); // close dialog
                                  }
                                  if (Navigator.canPop(context)) {
                                    Navigator.pop(context); // close screen
                                  }
                                });

                                // **Return a widget here**
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 80,
                                          height: 80,
                                          child: Image.asset(
                                              "assets/images/5290058.png"),
                                        ),
                                        const SizedBox(height: 15),
                                        const Text(
                                          "Success",
                                          style: TextStyle(
                                            fontFamily: "Roboto-Regular",
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          "Article updated successfully.",
                                          style: TextStyle(
                                            fontFamily: "Roboto-Regular",
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          } else {
                            showSnackBar(context, jsonDecode(response)['message'], "OK");
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
              icon: const Icon(
                Icons.check,
                color: Colors.white, // Icon color
              ),
              label: const Text(
                "Save",
                style: TextStyle(
                  fontFamily: "Roboto-Regular",
                  color: Colors.white, // Text color
                ),
              ),
              backgroundColor: const Color(0xFF0056cd), // Button background
            )),
        CustomLoader(isLoading: _isLoading)
      ],
    );
  }
}
