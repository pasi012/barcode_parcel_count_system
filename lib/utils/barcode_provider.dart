import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:fluttertoast/fluttertoast.dart';

class BarcodeProvider with ChangeNotifier {
  static const platform = MethodChannel('com.example.barcode/usb');

  final FlutterBlue _flutterBlue = FlutterBlue.instance;
  final List<String> _barcodes = [];
  List<String> get barcodes => _barcodes;

  BarcodeProvider(BuildContext context) {
    // Initialize both Bluetooth and general barcode scanning
    _initBluetooth();
    _initUSB();
  }

  void _initBluetooth() {
    // Start scanning for Bluetooth devices
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
    // Display toast with the connected device name
    Fluttertoast.showToast(
      msg: "Connected to ${device.name}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      fontSize: 16.0,
    );
    // Discover services
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      // Get the correct characteristic (update with your device's characteristic UUID)
      var characteristics = service.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        c.value.listen((value) {
          String barcode = String.fromCharCodes(value);
          addBarcode(barcode);
        });
        c.setNotifyValue(true);
      }
    }
  }

  void _initUSB() {
    platform.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onBarcodeScanned') {
        String barcode = call.arguments;
        addBarcode(barcode);
      } else if (call.method == 'onDeviceConnected') {
        String deviceName = call.arguments;
        _showUsbConnectedToast(deviceName);
      }
    });
    // Initialize USB connection on the native side
    _initializeUSBConnection();
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

  void addBarcode(String barcode) {
    _barcodes.add(barcode);
    notifyListeners();
  }

  void clearBarcodes() {
    _barcodes.clear();
    notifyListeners();
  }
}