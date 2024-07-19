import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parcel_counting_system/home/newLoadings/start_counting_screen.dart';
import '../../utils/footer.dart';

class NewLoadingScreen extends StatefulWidget {
  const NewLoadingScreen({super.key});

  @override
  State<NewLoadingScreen> createState() => _NewLoadingScreenState();
}

class _NewLoadingScreenState extends State<NewLoadingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleNumberController = TextEditingController();
  final _vehicleNumberFocusNode = FocusNode();
  final _quantityController = TextEditingController();
  final _quantityFocusNode = FocusNode();
  final _loadingIDFocusNode = FocusNode();
  final _loadingIDController = TextEditingController();
  final _officerNameFocusNode = FocusNode();
  final _officerNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "New Loading",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 30),
        ),
      ),
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Form(
          key: _formKey,
          child: LayoutBuilder(
            builder: (context, constraints) {
              double width = constraints.maxWidth;
              bool isWideScreen = width > 600;

              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Date/Time: $formattedDate",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (isWideScreen) ...[
                      Row(
                        children: [
                          Expanded(child: _buildVehicleNumberField()),
                          const SizedBox(width: 15),
                          Expanded(child: _buildLoadingIDField()),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(child: _buildQuantityField()),
                          const SizedBox(width: 15),
                          Expanded(child: _buildOfficerNameField()),
                        ],
                      ),
                    ] else ...[
                      _buildVehicleNumberField(),
                      const SizedBox(height: 15),
                      _buildLoadingIDField(),
                      const SizedBox(height: 15),
                      _buildQuantityField(),
                      const SizedBox(height: 15),
                      _buildOfficerNameField(),
                    ],
                    const SizedBox(height: 30),
                    Container(
                      width: double.infinity,
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            String vehicleNumber =
                                _vehicleNumberController.text;
                            String loadingID = _loadingIDController.text;
                            String officerName = _officerNameController.text;
                            int quantity = int.parse(_quantityController.text);

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StartCountingScreen(
                                  LoadingId: loadingID,
                                  VehicalNumber: vehicleNumber,
                                  countingOfficerName: officerName,
                                  quantity: quantity,
                                ),
                              ),
                            );
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.start,
                              color: Colors.black,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Start Counting".toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 100,
                    ),
                    const Footer(),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Vehicle Number",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
        ),
        const SizedBox(height: 10),
        TextFormField(
          textInputAction: TextInputAction.next,
          onEditingComplete: () =>
              FocusScope.of(context).requestFocus(_vehicleNumberFocusNode),
          keyboardType: TextInputType.text,
          controller: _vehicleNumberController,
          validator: (value) {
            if (value!.isEmpty) {
              return "This Field is missing";
            } else {
              return null;
            }
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            hintText: 'Enter Vehicle Number',
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

  Widget _buildLoadingIDField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Loading ID",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
        ),
        const SizedBox(height: 10),
        TextFormField(
          textInputAction: TextInputAction.next,
          onEditingComplete: () =>
              FocusScope.of(context).requestFocus(_loadingIDFocusNode),
          keyboardType: TextInputType.text,
          controller: _loadingIDController,
          validator: (value) {
            if (value!.isEmpty) {
              return "This Field is missing";
            } else {
              return null;
            }
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            hintText: 'Enter Loading ID',
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

  Widget _buildQuantityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Target Quantity",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
        ),
        const SizedBox(height: 10),
        TextFormField(
          textInputAction: TextInputAction.next,
          onEditingComplete: () =>
              FocusScope.of(context).requestFocus(_quantityFocusNode),
          keyboardType: TextInputType.number,
          controller: _quantityController,
          validator: (value) {
            if (value!.isEmpty) {
              return "This Field is missing";
            } else {
              return null;
            }
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            hintText: 'Enter Quantity',
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

  Widget _buildOfficerNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Name of Counting Officer",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
        ),
        const SizedBox(height: 10),
        TextFormField(
          textInputAction: TextInputAction.next,
          onEditingComplete: () =>
              FocusScope.of(context).requestFocus(_officerNameFocusNode),
          keyboardType: TextInputType.text,
          controller: _officerNameController,
          validator: (value) {
            if (value!.isEmpty) {
              return "This Field is missing";
            } else {
              return null;
            }
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            hintText: "Enter Counting Officer's Name",
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
