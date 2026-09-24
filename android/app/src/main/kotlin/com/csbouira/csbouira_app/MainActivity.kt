package com.csbouira.csbouira_app

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "csbouira_app/file_utils"
    private val LINKS_CHANNEL = "csbouira_app/deep_links"

    private var initialLink: String? = null
    private var linksChannel: MethodChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        // Only a fresh launch carries a new link; a recreated activity would
        // otherwise open the same file again.
        if (savedInstanceState == null) initialLink = appLinkFrom(intent)
        super.onCreate(savedInstanceState)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        appLinkFrom(intent)?.let { linksChannel?.invokeMethod("onLink", it) }
    }

    private fun appLinkFrom(intent: Intent?): String? {
        if (intent?.action != Intent.ACTION_VIEW) return null
        val data = intent.data ?: return null
        return if (data.scheme == "csbouira") data.toString() else null
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        linksChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, LINKS_CHANNEL).apply {
            setMethodCallHandler { call, result ->
                if (call.method == "getInitialLink") {
                    result.success(initialLink)
                    initialLink = null
                } else {
                    result.notImplemented()
                }
            }
        }

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
