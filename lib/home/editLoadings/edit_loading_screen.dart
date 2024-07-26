import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../utils/footer.dart';
import 'edit_loading_details_screen.dart';

class EditLoadingScreen extends StatefulWidget {
  const EditLoadingScreen({super.key});

  @override
  State<EditLoadingScreen> createState() => _EditLoadingScreenState();
}

class _EditLoadingScreenState extends State<EditLoadingScreen> {
  List<Map<String, dynamic>> loadings = [];
  List<Map<String, dynamic>> filteredLoadings = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchLoadings();
    searchController.addListener(() {
      filterLoadings();
    });
  }

  Future<void> fetchLoadings() async {
    try {
      String _uid = FirebaseAuth.instance.currentUser!.uid;
      final DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection(_uid)
          .doc('loadings')
          .get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          loadings = data.values
              .map((value) => value as Map<String, dynamic>)
              .toList();
          filteredLoadings = loadings;
        });
      }
    } catch (error) {
      Fluttertoast.showToast(
        msg: 'Failed to load data: $error',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.black,
        fontSize: 16.0,
      );
    }
  }

  void filterLoadings() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredLoadings = loadings.where((report) {
        return report['countingOfficerName']
                .toString()
                .toLowerCase()
                .contains(query) ||
            report['vehicleNumber'].toString().toLowerCase().contains(query) ||
            report['loadingId'].toString().toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Edit Loadings",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 30),
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Flexible(
              flex: 5,
              child: filteredLoadings.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          'https://www.edgecrm.app/images/no-data.gif',
                          width: 300,
                          height: 300, // Replace with your GIF URL
                          fit: BoxFit.cover,
                        ),
                        const Text(
                          'No data Found!',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ],
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Number of columns in the grid
                        childAspectRatio:
                            3 / 2, // Aspect ratio for the grid items
                        crossAxisSpacing: 10.0, // Spacing between columns
                        mainAxisSpacing: 10.0, // Spacing between rows
                      ),
                      itemCount: filteredLoadings
                          .length, // Number of items in the grid
                      itemBuilder: (BuildContext context, int index) {
                        final loading = filteredLoadings[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditLoadingDetailsScreen(loading: loading),
                              ),
                            );
                          },
                          child: Card(
                            color: Colors.blueAccent,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  'Loading ID: ${loading['loadingId']}\n'
                                  'Vehicle No: ${loading['vehicleNumber']}\n'
                                  'Count Officer: ${loading['countingOfficerName']}',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 13),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
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
