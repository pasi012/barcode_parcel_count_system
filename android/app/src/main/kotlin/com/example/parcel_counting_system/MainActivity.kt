package com.example.parcel_counting_system

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import android.view.KeyEvent

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.parcel_counting_system/scanner"

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getScannedData") {
                val data = getScannedData() // Implement this method to get scanned data
                result.success(data)
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        if (event?.action == KeyEvent.ACTION_DOWN) {
            val char = event.unicodeChar.toChar()
            if (char != null) {
                // Send the character to Flutter
                flutterEngine?.dartExecutor?.binaryMessenger?.let {
                    MethodChannel(it, CHANNEL).invokeMethod("onScannedData", char.toString())
                }
            }
        }
        return super.onKeyDown(keyCode, event)
    }

    private fun getScannedData(): String {
        // Implement this method to return the scanned data
        return "Sample Data"
    }
}
