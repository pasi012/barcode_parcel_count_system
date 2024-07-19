import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';

import '../../utils/footer.dart';

class EditLoadingDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> loading;

  const EditLoadingDetailsScreen({Key? key, required this.loading})
      : super(key: key);

  @override
  _EditLoadingDetailsScreenState createState() =>
      _EditLoadingDetailsScreenState();
}

class _EditLoadingDetailsScreenState extends State<EditLoadingDetailsScreen> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _vehicleNoController;
  late final TextEditingController _loadingIDController;
  late final TextEditingController _countOfficerNameController;

  @override
  void initState() {
    super.initState();
    _vehicleNoController =
        TextEditingController(text: widget.loading['vehicleNumber']);
    _loadingIDController =
        TextEditingController(text: widget.loading['loadingId']);
    _countOfficerNameController =
        TextEditingController(text: widget.loading['countingOfficerName']);
  }

  @override
  void dispose() {
    _vehicleNoController.dispose();
    _loadingIDController.dispose();
    _countOfficerNameController.dispose();
    super.dispose();
  }

  Future<void> _updateDataToFirestore() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _isLoading = true);

      String uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection(uid).doc('loadings').update({
        widget.loading['id']: {
          'userId': widget.loading['userId'],
          'id': widget.loading['id'],
          'countingOfficerName': _countOfficerNameController.text,
          'vehicleNumber': _vehicleNoController.text,
          'loadingId': _loadingIDController.text,
          'barcodes': widget.loading['barcodes'],
          'count': widget.loading['count'],
          'timestamp': widget.loading['timestamp'],
        }
      });

      Fluttertoast.showToast(
        msg: "Data updated successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update data: $error')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: const Text(
          "Edit Loading Details",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 30,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                controller: _loadingIDController,
                label: 'Loading ID',
                hintText: 'Enter Loading ID',
                validator: (value) =>
                    value!.isEmpty ? "This Field is missing" : null,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                controller: _vehicleNoController,
                label: 'Vehicle No',
                hintText: 'Enter Vehicle No',
                validator: (value) =>
                    value!.isEmpty ? "This Field is missing" : null,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                controller: _countOfficerNameController,
                label: 'Counting Officer Name',
                hintText: 'Enter Counting Officer Name',
                validator: (value) =>
                    value!.isEmpty ? "This Field is missing" : null,
              ),
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () {
                    _updateDataToFirestore();
                    //Navigator.pop(context);
                  },
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : Row(
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
                              "Update Loading".toUpperCase(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(
                height: 250,
              ),
              const Footer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.text,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.blue),
            ),
          ),
          style: const TextStyle(color: Colors.black),
        ),
      ],
    );
  }
}
