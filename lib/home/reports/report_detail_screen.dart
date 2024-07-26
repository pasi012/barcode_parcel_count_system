import 'dart:typed_data';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../../utils/footer.dart';

class ReportDetailScreen extends StatefulWidget {
  final Map<String, dynamic> report;

  const ReportDetailScreen({required this.report, Key? key}) : super(key: key);

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  String username = "";
  String companyName = "";

  @override
  void initState() {
    super.initState();
    getSettingsData();

    String? email = FirebaseAuth.instance.currentUser!.email;

    if (email != null) {
      setState(() {
        username = email.split('@')[0];
      });
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
          companyName = userDoc.get('companyName');
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

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Date: ${widget.report['timestamp'] != null ? (widget.report['timestamp'] as Timestamp).toDate() : 'N/A'}',
                style: const pw.TextStyle(
                  fontSize: 18,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Column(children: [
                  pw.Text(
                    companyName,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                  pw.Text(
                    'Parcel / Package Loading report',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ]),
              ),
              pw.SizedBox(height: 50),
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Vehicle No: ${widget.report['vehicleNumber']}',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    pw.Text(
                      'Loading ID: ${widget.report['loadingId']}',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ]),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: ['Barcode List'],
                data: List<List<dynamic>>.from(
                  widget.report['barcodes'].map((barcode) => [barcode]),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Total Count of Barcodes: ${widget.report['count']}',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Counting Officer: ${widget.report['countingOfficerName']}',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              pw.Text(
                'Authorized Officer: $username',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: const Text(
          "Report Details",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 30),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date: ${widget.report['timestamp'] != null ? (widget.report['timestamp'] as Timestamp).toDate() : 'N/A'}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                companyName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            const Align(
              alignment: Alignment.center,
              child: Text(
                'Parcel / Package Loading report',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Vehicle No: ${widget.report['vehicleNumber']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Loading ID: ${widget.report['loadingId']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            // Title and ListView for barcodes
            const Text(
              'Barcode List:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Add a container to specify height for ListView
            SizedBox(
              height: 150, // Adjust height as needed
              child: ListView.builder(
                itemCount: widget.report['barcodes'].length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      widget.report['barcodes'][index],
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Total Count of Barcodes: ${widget.report['count']}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Counting Officer: ${widget.report['countingOfficerName']}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Authorized Officer: $username',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: SizedBox(
                height: 50,
                width: double.infinity,
                child: TextButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  onPressed: () async {
                    // Generate and display the PDF
                    await Printing.layoutPdf(
                      onLayout: (PdfPageFormat format) => _generatePdf(format),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.black,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Get Report".toUpperCase(),
                        style:
                            const TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
            const Align(alignment: Alignment.center, child: Footer()),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
