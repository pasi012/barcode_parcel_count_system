import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../utils/barcode_provider.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

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
  String whatsappNumber = "";
  String emailID = "";

  var barcodeProvider;

  @override
  void initState() {
    super.initState();
    getSettingsData();
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
          whatsappNumber = userDoc.get('whatsapp');
          emailID = userDoc.get('email');
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$error')),
      );
    }
  }

  Future<void> saveDataToFirestore(String vehicleNumber, String loadingId,
      List<String> barcodes, String countingOfficerName) async {
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
              'count': barcodeProvider.barcodes.length,
              'timestamp': FieldValue.serverTimestamp(),
            }
          },
          SetOptions(
              merge: true)); // Merge options to update or create if not exists

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data saved successfully')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save data: $error')),
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
                    barcodeProvider.barcodes.map((barcode) => [barcode])),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Total Count of Barcodes: ${barcodeProvider.barcodes.length}',
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

  Future<File> generatePdfFile(PdfPageFormat format) async {
    final pdf = await _generatePdf(format);
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/report.pdf");
    await file.writeAsBytes(pdf);
    return file;
  }

  void _showDuplicateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Duplicate Barcode'),
          content: const Text('This barcode has already been scanned.'),
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

  @override
  Widget build(BuildContext context) {
    barcodeProvider = Provider.of<BarcodeProvider>(context);
    return Scaffold(
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
                  'Count: ${barcodeProvider.barcodes.length}',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Expanded(
              child: barcodeProvider.barcodes.isEmpty
                  ? const Center(
                      child: Text('Please start barcode scan'),
                    )
                  : ListView.builder(
                      itemCount: barcodeProvider.barcodes.length,
                      itemBuilder: (context, index) {
                        String barcode = barcodeProvider.barcodes[index];

                        // Check for duplicate barcode
                        if (duplicateBarcode &&
                            barcodeProvider.barcodes
                                .sublist(0, index)
                                .contains(barcode)) {
                          _showDuplicateDialog();
                        }

                        return ListTile(
                          title: Text(barcode),
                          trailing: const Text('1'),
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
                    if (widget.quantity == barcodeProvider.barcodes.length) {
                      // Logic to hold and save
                      saveDataToFirestore(
                          widget.VehicalNumber,
                          widget.LoadingId,
                          barcodeProvider.barcodes,
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
                        style:
                            const TextStyle(fontSize: 15, color: Colors.black),
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
                    if (widget.quantity == barcodeProvider.barcodes.length) {
                      // Logic to hold and save
                      saveDataToFirestore(
                          widget.VehicalNumber,
                          widget.LoadingId,
                          barcodeProvider.barcodes,
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
                        style:
                            const TextStyle(fontSize: 15, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButtonWithOptions(
        whatsapp: whatsappNumber,
        email: emailID,
        quantity: widget.quantity,
        barcodeProvider: barcodeProvider,
        globalKey: widget.globalKey,
      ),
      floatingActionButtonLocation: CustomFabLocation(),
    );
  }
}

class CustomFabLocation extends FloatingActionButtonLocation {
  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    // Customize the position
    double x = scaffoldGeometry.scaffoldSize.width - 80;
    double y = scaffoldGeometry.scaffoldSize.height -
        150; // 100 pixels from the bottom
    return Offset(x, y);
  }
}

class FloatingActionButtonWithOptions extends StatelessWidget {
  final int quantity;
  final BarcodeProvider barcodeProvider;
  final String whatsapp;
  final String email;
  final GlobalKey<_StartCountingScreenState> globalKey;

  FloatingActionButtonWithOptions({
    super.key,
    required this.email,
    required this.whatsapp,
    required this.barcodeProvider,
    required this.quantity,
    required this.globalKey,
  });

  void _launchWhatsApp() async {
    const message = 'Hello, this is a test message!';

    final url = 'https://wa.me/$whatsapp?text=${Uri.encodeComponent(message)}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<String> uploadFile(String filePath) async {
    File file = File(filePath);

    try {
      TaskSnapshot snapshot = await FirebaseStorage.instance
          .ref('uploads/${file.path}')
          .putFile(file);

      if (snapshot.state == TaskState.success) {
        String downloadURL = await snapshot.ref.getDownloadURL();
        return downloadURL;
      } else {
        throw 'Could not upload file';
      }
    } catch (e) {
      print(e);
      throw 'Could not upload file';
    }
  }

  Future<void> _launchEmail() async {
    final pdfFile =
        await globalKey.currentState!.generatePdfFile(PdfPageFormat.a4);
    const subject = 'Loading Report';
    const body = 'Please find the attached report.';

    // Replace with your file path
    final filePath = pdfFile.path;
    final downloadURL = await uploadFile(filePath);

    final fullBody = '$body\n\nDownload the attachment here: $downloadURL';

    final url =
        'mailto:$email?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(fullBody)}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {},
      child: PopupMenuButton<int>(
        icon: const Icon(Icons.share),
        onSelected: (value) {
          switch (value) {
            case 0:
              if (quantity == barcodeProvider.barcodes.length) {
                _launchWhatsApp();
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
              break;
            case 1:
              if (quantity == barcodeProvider.barcodes.length) {
                _launchEmail();
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
              break;
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 0,
            child: Text('WhatsApp'),
          ),
          const PopupMenuItem(
            value: 1,
            child: Text('Email'),
          ),
        ],
      ),
    );
  }
}
