import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:parcel_counting_system/home/settings_screen.dart';
import 'package:parcel_counting_system/utils/footer.dart';
import 'editLoadings/edit_loading_screen.dart';
import 'newLoadings/new_loading_screen.dart';
import 'reports/report_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      if (userDoc != null) {
        setState(() {
          logoImage = userDoc.get('logo');
        });
      }
    } catch (error) {

      print(error);

      // Fluttertoast.showToast(
      //   msg: 'Failed to load data: $error',
      //   toastLength: Toast.LENGTH_SHORT,
      //   gravity: ToastGravity.SNACKBAR,
      //   timeInSecForIosWeb: 1,
      //   backgroundColor: Colors.red,
      //   textColor: Colors.black,
      //   fontSize: 16.0,
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: const Text(
          "Home",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 30),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 30, top: 30),
              child: logoImage.isEmpty
                  ? Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.fill,
                      height: 100,
                      width: 100,
                    )
                  : Image.network(
                      logoImage,
                      fit: BoxFit.fill,
                      height: 100,
                      width: 100,
                    ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  child: const Card(
                    child: SizedBox(
                      width: 170,
                      height: 170,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.upload, size: 50),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "New Loading",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NewLoadingScreen(),
                      ),
                    );
                  },
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditLoadingScreen(),
                      ),
                    );
                  },
                  child: const Card(
                    child: SizedBox(
                      width: 170,
                      height: 170,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit, size: 50),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Edit Loading",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  child: const Card(
                    child: SizedBox(
                      width: 170,
                      height: 170,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_note_rounded, size: 50),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Reports",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReportScreen(),
                      ),
                    );
                  },
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                  child: const Card(
                    child: SizedBox(
                      width: 170,
                      height: 170,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.settings, size: 50),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Settings",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Footer(),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
