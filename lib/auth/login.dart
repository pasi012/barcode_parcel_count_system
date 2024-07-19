import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:parcel_counting_system/auth/register.dart';
import 'package:parcel_counting_system/utils/footer.dart';
import 'package:parcel_counting_system/services/auth_service.dart';

import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _passTextController = TextEditingController();
  final _fullNameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  String logoImage = '';

  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      getSettingsData();
    }
  }

  Future<void> getSettingsData() async {
    try {
      String _uid = FirebaseAuth.instance.currentUser!.uid;
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection(_uid)
          .doc('settings')
          .get();
      if (userDoc.exists) {
        setState(() {
          logoImage = userDoc.get('logo');
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50,),
                const Text(
                  "Parcel Counting System",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 25),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  "LogIn",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontSize: 25),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: logoImage.isEmpty
                      ? Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.fill,
                    height: screenHeight * 0.1,
                    width: screenWidth * 0.2,
                  )
                      : Image.network(
                    logoImage,
                    fit: BoxFit.fill,
                    height: screenHeight * 0.1,
                    width: screenWidth * 0.2,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // User name
                        const Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "User Name*",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.black),
                          ),
                        ),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () => FocusScope.of(context)
                              .requestFocus(_fullNameFocusNode),
                          keyboardType: TextInputType.name,
                          controller: _fullNameController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "This Field is missing";
                            } else {
                              return null;
                            }
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[200], // Background color
                            hintText:
                            'Enter Your Name', // Floating label text
                            hintStyle: const TextStyle(
                                color: Colors
                                    .grey), // Color of the floating label text
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  8.0), // Rounded corners (optional)
                              borderSide: BorderSide.none, // Remove border
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  8.0), // Rounded corners when focused (optional)
                              borderSide: const BorderSide(
                                  color: Colors
                                      .blue), // Border color when focused
                            ),
                          ),
                          style: const TextStyle(color: Colors.black),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
        
                        // Password
                        const Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Password*",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.black),
                          ),
                        ),
                        TextFormField(
                          focusNode: _passwordFocusNode,
                          keyboardType: TextInputType.number,
                          controller: _passTextController,
                          validator: (value) {
                            if (value!.length < 7) {
                              return "Please enter 8 digits number";
                            }if(value.isEmpty){
                              return "This Field is missing";
                            } else {
                              return null;
                            }
                          },
                          onEditingComplete: () => FocusScope.of(context)
                              .requestFocus(_passwordFocusNode),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[200], // Background color
                            hintText:
                            'Enter Your Password', // Floating label text
                            hintStyle: const TextStyle(
                                color: Colors
                                    .grey), // Color of the floating label text
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  8.0), // Rounded corners (optional)
                              borderSide: BorderSide.none, // Remove border
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  8.0), // Rounded corners when focused (optional)
                              borderSide: const BorderSide(
                                  color: Colors
                                      .blue), // Border color when focused
                            ),
                          ),
                          style: const TextStyle(color: Colors.black),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      onPressed: () async {
                        final isValid = _formKey.currentState!.validate();
                        FocusScope.of(context).unfocus();
                        if (isValid) {
                          setState(() {
                            _isLoading = true;
                          });
        
                          try {
                            var user =
                            await _authService.loginWithUsernamePassword(
                                _fullNameController.text.trim(),
                                _passTextController.text.trim());
        
                            if (user != null) {
                              // Navigate to home screen
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                      const HomeScreen()));
                            } else {
                              setState(() {
                                Fluttertoast.showToast(
                                  msg: 'Invalid username or password',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.SNACKBAR,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.black,
                                  fontSize: 16.0,
                                );
                              });
                            }
                          } catch (e) {
                            setState(() {
                              Fluttertoast.showToast(
                                msg: 'An error occurred. Please try again.',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.SNACKBAR,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.black,
                                fontSize: 16.0,
                              );
                            });
                          } finally {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        }
                      },
                      child: Text(
                        "login".toUpperCase(),
                        style: const TextStyle(
                            fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Don't have an account? Register",
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                const Footer(),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
            if (_isLoading)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}