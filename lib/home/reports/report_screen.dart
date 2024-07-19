import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parcel_counting_system/home/reports/report_detail_screen.dart';
import '../../utils/footer.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  List<Map<String, dynamic>> reports = [];
  List<Map<String, dynamic>> filteredReports = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchReports();
    searchController.addListener(() {
      filterReports();
    });
  }

  Future<void> fetchReports() async {
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
          reports = data.values
              .map((value) => value as Map<String, dynamic>)
              .toList();
          filteredReports = reports;
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: $error')),
      );
    }
  }

  void filterReports() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredReports = reports.where((report) {
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
          "Reports",
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
              child: filteredReports.isEmpty
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
                      itemCount:
                          filteredReports.length, // Number of items in the grid
                      itemBuilder: (BuildContext context, int index) {
                        final report = filteredReports[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ReportDetailScreen(report: report),
                              ),
                            );
                          },
                          child: Card(
                            color: Colors.blueAccent,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  'Loading ID: ${report['loadingId']}\n'
                                  'Vehicle No: ${report['vehicleNumber']}\n'
                                  'Count Officer: ${report['countingOfficerName']}',
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
