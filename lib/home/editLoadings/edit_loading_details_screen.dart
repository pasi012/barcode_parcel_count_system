import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class EditLoadingDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> loading;

  const EditLoadingDetailsScreen({Key? key, required this.loading})
      : super(key: key);

  @override
  State<EditLoadingDetailsScreen> createState() =>
      _EditLoadingDetailsScreenState();
}

class _EditLoadingDetailsScreenState extends State<EditLoadingDetailsScreen> {
  bool duplicateBarcode = false;
  String companyName = "";
  String digit = "";

  static const platform =
      MethodChannel('com.example.parcel_counting_system/scanner');
  String scannedData = '';
  List<String> scannedDataList = [];

  @override
  void initState() {
    super.initState();

    // Convert dynamic list to string list
    scannedDataList.addAll(
        List<String>.from(widget.loading['barcodes'].map((e) => e.toString())));

    getSettingsData();
    platform.setMethodCallHandler(_handleMethod);
  }

  Future<void> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'onScannedData':
        setState(() {
          scannedData += call.arguments;
          scannedDataList = scannedData.trim().split(RegExp(r'\s+'));

          //scannedDataList.addAll(scannedData.trim().split(RegExp(r'\s+')));
        });
        break;
      default:
        print('Unknown method ${call.method}');
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
          duplicateBarcode = userDoc.get('duplicateBarcode');
          companyName = userDoc.get('companyName');
          digit = userDoc.get('digit');
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

  Future<void> updateDataInFirestore(List<String> barcodes) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      // Reference the 'loadings' document directly
      await FirebaseFirestore.instance.collection(uid).doc('loadings').update({
        widget.loading['id']: {
          'userId': widget.loading['userId'],
          'id': widget.loading['id'],
          'countingOfficerName': widget.loading['countingOfficerName'],
          'vehicleNumber': widget.loading['vehicleNumber'],
          'loadingId': widget.loading['loadingId'],
          'barcodes': barcodes,
          'targetQuantity': widget.loading['targetQuantity'],
          'count': barcodes.length,
          'timestamp': FieldValue.serverTimestamp(),
        }
      }); // Merge options to update or create if not exists
    } catch (error) {
      Fluttertoast.showToast(
        msg: 'Failed to save data: $error',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.black,
        fontSize: 16.0,
      );
    }
  }

  String username = "";

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    String? email = FirebaseAuth.instance.currentUser!.email;

    if (email != null) {
      setState(() {
        username = email.split('@')[0];
      });
    }

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd : kk:mm').format(now);

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Date: $formattedDate',
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
                      'Vehicle No: ${widget.loading['vehicleNumber']}',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    pw.Text(
                      'Loading Number: ${widget.loading['loadingId']}',
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
                    scannedDataList.map((barcode) => [barcode])),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Total Count of Barcodes: ${scannedDataList.length}',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Counting Officer: ${widget.loading['countingOfficerName']}',
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

  void _showDigitNotEqualDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Not Equal to Required Digits'),
          content: Text('Barcode Digits Not Equal to Required digits - $digit'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _onWillPop() async {
    scannedData = "";
    scannedDataList.clear(); // Call clearBarcodes method here
    return true; // Return true to allow the pop
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: const Text(
            "Edit Loading",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black, fontSize: 30),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Veh No: ${widget.loading['vehicleNumber']}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Loading ID: ${widget.loading['loadingId']}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Target Quantity: ${widget.loading['targetQuantity'].toString()}',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Count: ${scannedDataList.length}',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Expanded(
                child: scannedDataList.isEmpty
                    ? const Center(
                        child: Text('Please start barcode scan'),
                      )
                    : ListView.builder(
                        itemCount: scannedDataList.length,
                        itemBuilder: (context, index) {
                          String barcode = scannedDataList[index];

                          // if(scannedData.length != int.parse(digit)){
                          //   WidgetsBinding.instance.addPostFrameCallback((_) {
                          //     setState(() {
                          //       scannedDataList.removeAt(index);
                          //     });
                          //     _showDigitNotEqualDialog();
                          //   });
                          //
                          //   return Container();
                          // }

                          // Check for duplicate barcodes if duplicateBarcode is true
                          if (duplicateBarcode == false &&
                              scannedDataList
                                  .sublist(0, index)
                                  .contains(barcode)) {
                            // Remove the duplicate barcode
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              setState(() {
                                scannedDataList.removeAt(index);
                              });
                            });

                            return Container(); // Return empty container to hide duplicate barcode
                          }

                          return ListTile(
                            title: Text(barcode),
                          );
                        },
                      ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    onPressed: () async {
                      if (widget.loading['targetQuantity'] ==
                          scannedDataList.length) {
                        // Generate and display the PDF
                        await Printing.layoutPdf(
                          onLayout: (PdfPageFormat format) =>
                              _generatePdf(format),
                        );
                      } else {
                        Fluttertoast.showToast(
                          msg: "Target Quantity not equal to barcode count",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.black,
                          fontSize: 16.0,
                        );
                      }
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
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    onPressed: () {
                      if (widget.loading['targetQuantity'] >=
                          scannedDataList.length) {
                        // Logic to hold and save
                        updateDataInFirestore(scannedDataList);

                        Fluttertoast.showToast(
                          msg: "Successfully Updated Data",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.green,
                          textColor: Colors.black,
                          fontSize: 16.0,
                        );

                        scannedDataList.clear();
                        scannedData = "";
                        Navigator.pop(context);
                      } else {
                        Fluttertoast.showToast(
                          msg: "Target Quantity not equal to barcode count",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.black,
                          fontSize: 16.0,
                        );
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.update,
                          color: Colors.black,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Update Data".toUpperCase(),
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      updateDataInFirestore(scannedDataList);
    }else if (state == AppLifecycleState.inactive) {
      updateDataInFirestore(scannedDataList);
    }
  }

}
