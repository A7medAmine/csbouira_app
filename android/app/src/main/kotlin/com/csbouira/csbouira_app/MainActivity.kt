package com.csbouira.csbouira_app

import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "csbouira_app/file_utils"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "readContentUri") {
                val uriString = call.arguments as? String
                if (uriString == null) {
                    result.error("INVALID_ARGUMENTS", "URI string required", null)
                    return@setMethodCallHandler
                }
                try {
                    val uri = Uri.parse(uriString)
                    val inputStream = contentResolver.openInputStream(uri)
                    val bytes = inputStream?.readBytes()
                    inputStream?.close()
                    if (bytes != null) {
                        result.success(bytes)
                    } else {
                        result.error("READ_FAILED", "Could not open input stream for URI", null)
                    }
                } catch (e: Exception) {
                    result.error("READ_FAILED", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
