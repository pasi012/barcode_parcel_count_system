import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:fluttertoast/fluttertoast.dart';

class BarcodeProvider with ChangeNotifier {
  static const platform = MethodChannel('com.example.parcel_counting_system/scanner');

  final FlutterBlue _flutterBlue = FlutterBlue.instance;
  String get barcodes => scannedData;
  String scannedData = '';

  BarcodeProvider(BuildContext context) {
    // Initialize both Bluetooth and general barcode scanning
    _initBluetooth();
    _initUSB();
  }

  void _initBluetooth() {
    _flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        _connectToDevice(r.device);
        break;
      }
    });
    _flutterBlue.startScan(timeout: const Duration(seconds: 4));
  }

  void _connectToDevice(BluetoothDevice device) async {
    await device.connect();
    Fluttertoast.showToast(
      msg: "Connected to ${device.name}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      fontSize: 16.0,
    );
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      var characteristics = service.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        c.value.listen((value) {
          scannedData = String.fromCharCodes(value);
          notifyListeners();
        });
        c.setNotifyValue(true);
      }
    }
  }

  void _initUSB() {
    platform.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onScannedData') {
        scannedData += call.arguments;
        notifyListeners();
      } else if (call.method == 'onDeviceConnected') {
        String deviceName = call.arguments;
        _showUsbConnectedToast(deviceName);
      }
    });
    _initializeUSBConnection();
  }

  Future<void> _initializeUSBConnection() async {
    try {
      await platform.invokeMethod('initializeUSB');
    } on PlatformException catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to initialize USB: ${e.message}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  void _showUsbConnectedToast(String deviceName) {
    Fluttertoast.showToast(
      msg: "Connected to $deviceName",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void clearBarcodes() {
    scannedData = "";
    notifyListeners();
  }
}