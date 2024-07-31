import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class StartCountingScreen extends StatefulWidget {
  StartCountingScreen(
      {super.key,
      required this.LoadingId,
      required this.quantity,
      required this.VehicalNumber,
      required this.countingOfficerName});

  String VehicalNumber;
  String countingOfficerName;
  String LoadingId;
  int quantity;
  final GlobalKey<_StartCountingScreenState> globalKey = GlobalKey();

  @override
  State<StartCountingScreen> createState() => _StartCountingScreenState();
}

class _StartCountingScreenState extends State<StartCountingScreen> {
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
    getSettingsData();
    platform.setMethodCallHandler(_handleMethod);
  }

  Future<void> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'onScannedData':
        setState(() {
          scannedData += call.arguments;
          scannedDataList = scannedData.trim().split(RegExp(r'\s+'));
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

  Future<void> saveDataToFirestore(
      String vehicleNumber,
      String loadingId,
      List<String> barcodes,
      int targetQuantity,
      int scannedBarcodeCount,
      String countingOfficerName) async {
    try {
      String _uid = FirebaseAuth.instance.currentUser!.uid;
      final _uuid = const Uuid().v4();

      // Reference the 'loadings' document directly
      await FirebaseFirestore.instance.collection(_uid).doc('loadings').set(
          {
            _uuid: {
              'userId': _uid,
              'id': _uuid,
              'countingOfficerName': countingOfficerName,
              'vehicleNumber': vehicleNumber,
              'loadingId': loadingId,
              'barcodes': barcodes,
              'targetQuantity': targetQuantity,
              'count': scannedBarcodeCount,
              'timestamp': FieldValue.serverTimestamp(),
            }
          },
          SetOptions(
              merge: true)); // Merge options to update or create if not exists

      Fluttertoast.showToast(
        msg: 'Data saved successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.black,
        fontSize: 16.0,
      );
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
                      'Vehicle No: ${widget.VehicalNumber}',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    pw.Text(
                      'Loading Number: ${widget.LoadingId}',
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
                'Counting Officer: ${widget.countingOfficerName}',
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
            "Start Counting",
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
                    'Veh No: ${widget.VehicalNumber}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Loading ID: ${widget.LoadingId}',
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
                    'Target Quantity: ${widget.quantity}',
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
                      if (widget.quantity == scannedDataList.length) {
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
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    onPressed: () {
                      if (widget.quantity >= scannedDataList.length) {
                        // Logic to hold and save
                        saveDataToFirestore(
                            widget.VehicalNumber,
                            widget.LoadingId,
                            scannedDataList,
                            widget.quantity,
                            scannedDataList.length,
                            widget.countingOfficerName);

                        Fluttertoast.showToast(
                          msg: "Successfully Save Data",
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
                          Icons.save,
                          color: Colors.black,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Save Data".toUpperCase(),
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
      saveDataToFirestore(
          widget.VehicalNumber,
          widget.LoadingId,
          scannedDataList,
          widget.quantity,
          scannedDataList.length,
          widget.countingOfficerName);
    } else if (state == AppLifecycleState.inactive) {
      saveDataToFirestore(
          widget.VehicalNumber,
          widget.LoadingId,
          scannedDataList,
          widget.quantity,
          scannedDataList.length,
          widget.countingOfficerName);
    }
  }
}
