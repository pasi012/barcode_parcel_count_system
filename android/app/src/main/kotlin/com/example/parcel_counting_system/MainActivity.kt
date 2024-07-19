package com.example.parcel_counting_system

import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.barcode/usb"
    private lateinit var usbManager: UsbManager

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            if (call.method == "initializeUSB") {
                initializeUSB(result)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun initializeUSB(result: MethodChannel.Result) {
        usbManager = getSystemService(Context.USB_SERVICE) as UsbManager
        val filter = IntentFilter()
        filter.addAction(UsbManager.ACTION_USB_DEVICE_ATTACHED)
        filter.addAction(UsbManager.ACTION_USB_DEVICE_DETACHED)
        registerReceiver(usbReceiver, filter)
        result.success(null)
    }

    private val usbReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val action = intent.action
            val device = intent.getParcelableExtra<UsbDevice>(UsbManager.EXTRA_DEVICE)
            if (UsbManager.ACTION_USB_DEVICE_ATTACHED == action) {
                device?.let {
                    // Handle USB device attached
                }
            } else if (UsbManager.ACTION_USB_DEVICE_DETACHED == action) {
                device?.let {
                    // Handle USB device detached
                }
            }
        }
    }
}