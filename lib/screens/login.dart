import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:paragon/screens/forget_password.dart';
import 'package:paragon/screens/home.dart';
import 'package:paragon/screens/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../apis/auth.dart';
import '../extensions/loader.dart'; // Import your loader
import '../extensions/snackbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final String _loginUrl = "${dotenv.env['API_URL']}auth/loginUser.php";
  dynamic response;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false; // Add a loading state
  bool _showPassword = true;

  
  // Function to trigger the API call
  Future<void> _login() async {
    if (_emailController.text.isEmpty) {
      showSnackBar(context, "Please enter email or mobile number", "Ok");
      return;
    } else if (_passwordController.text.isEmpty) {
      showSnackBar(context, "Please enter password", "Ok");
      return;
    }

    setState(() {
      _isLoading = true; // Show the loader
    });

    var body = {
      "username": _emailController.text,
      "password": _passwordController.text
    };

    var res = await getDataWithPost(_loginUrl, body); // Call the API with email and password

    setState(() {
      response = res?.body;  // Store the response body for display or further processing
      _isLoading = false; // Hide the loader
    });

    if (response != null) {
      if (jsonDecode(response)['task_status'] == "true") {
        final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
        await asyncPrefs.setBool('loggedin', true);
        await asyncPrefs.setString("user", jsonEncode(response));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
      } else {
        showSnackBar(context, jsonDecode(response)['message'], "OK");
      }
    } else {
      showSnackBar(context, "Something went wrong", "OK");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Login", style: TextStyle(fontFamily: "Roboto-Regular"),),
        backgroundColor: const Color(0xFFdcdaf5),
        actions: <Widget>[
          IconButton(onPressed: (){
            
          }, icon: const Icon(Icons.help))
        ],
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            alignment: AlignmentDirectional.center,
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  Container(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          alignment: AlignmentDirectional.centerStart,
                            child: const Text("Welcome back!", style: TextStyle(fontSize: 25, fontFamily: "Roboto-Regular"),)
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _emailController,
                          obscureText: false,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Email or mobile number",
                              prefixIcon: Icon(
                                Icons.email,
                                color: Colors.black54,
                              ),
                              labelStyle: TextStyle(fontFamily: "Roboto-Regular")),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _passwordController,
                          obscureText: _showPassword,
                          decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: "Password",
                              prefixIcon: const Icon(
                                Icons.lock,
                                color: Colors.black54,
                              ),
                              suffixIcon: IconButton(onPressed: (){
                                setState(() {
                                  _showPassword = !_showPassword;
                                });
                              }, icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility, color: Colors.black54,)),
                              labelStyle: const TextStyle(fontFamily: "Roboto-Regular")),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          alignment: AlignmentDirectional.centerStart,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: InkWell(
                              child: const Text(
                                "Forget password?",
                                style: TextStyle(
                                  fontFamily: "Roboto-Regular",
                                  fontWeight: FontWeight.w100,
                                  color: Color(0xFF0056cd)
                                ),
                              ),
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context)=> ForgetScreen()));
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0056cd),
                                  foregroundColor: Colors.white,
                                  textStyle: const TextStyle(fontFamily: "Roboto-Regular"),
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(3)))),
                              child: const Text("LOGIN")),
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          "By continuing you agree our",
                          style: TextStyle(color: Colors.grey, fontFamily: "Roboto-Regular"),
                        ),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Privacy policy ", style: TextStyle(color: Color(0xFF0056cd), fontFamily: "Roboto-Regular")),
                            Text("and ", style: TextStyle(color: Colors.grey, fontFamily: "Roboto-Regular")),
                            Text("Terms of service", style: TextStyle(color: Color(0xFF0056cd), fontFamily: "Roboto-Regular")),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("New user? ", style: TextStyle(color: Colors.grey, fontFamily: "Roboto-Regular")),
                            InkWell(
                              onTap: () {
                                // Handle new account creation
                                Navigator.push(context, MaterialPageRoute(builder: (context) => SignupScreen()));
                              },
                              child: const Text("Create a new account", style: TextStyle(color: Color(0xFF0056cd), fontFamily: "Roboto-Regular")),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: 30,
                  ),
                  // Show loader if isLoading is true
                ],
              ),
            ),
          ),
          CustomLoader(isLoading: _isLoading),
        ],
      ),
    );
  }
}
