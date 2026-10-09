package com.csbouira.csbouira_app

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.ClipData
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.Drawable
import androidx.core.content.FileProvider
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.File

/**
 * `csbouira_app/ai_share` channel, used by AiShareService
 * (lib/data/services/ai_share_service.dart):
 *
 * - `queryApps` lists which of the given AI apps are installed and accept a
 *   MIME type, with their label and icon. The packages must be listed under
 *   `<queries>` in AndroidManifest.xml to be visible.
 * - `shareToApp` sends a file from `<cache>/ai_share` plus a prompt to one app.
 */
class AiShareChannel(private val activity: Activity) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "queryApps" -> {
                val packages = call.argument<List<String>>("packages")
                val mimeType = call.argument<String>("mimeType")
                if (packages == null || mimeType == null) {
                    result.error("INVALID_ARGUMENTS", "packages and mimeType required", null)
                    return
                }
                result.success(queryApps(packages, mimeType))
            }
            "shareToApp" -> {
                val pkg = call.argument<String>("package")
                val path = call.argument<String>("path")
                val mimeType = call.argument<String>("mimeType")
                if (pkg == null || path == null || mimeType == null) {
                    result.error("INVALID_ARGUMENTS", "package, path and mimeType required", null)
                    return
                }
                try {
                    shareToApp(pkg, File(path), mimeType, call.argument<String>("text"))
                    result.success(null)
                } catch (e: ActivityNotFoundException) {
                    result.error("NOT_FOUND", e.message, null)
                } catch (e: IllegalArgumentException) {
                    result.error("BAD_FILE", e.message, null)
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun sendIntent(mimeType: String) = Intent(Intent.ACTION_SEND).setType(mimeType)

    private fun queryApps(packages: List<String>, mimeType: String): List<Map<String, Any>> {
        val pm = activity.packageManager
        return packages.mapNotNull { pkg ->
            @Suppress("DEPRECATION")
            val handlers = pm.queryIntentActivities(sendIntent(mimeType).setPackage(pkg), 0)
            if (handlers.isEmpty()) return@mapNotNull null
            val info = try {
                @Suppress("DEPRECATION")
                pm.getApplicationInfo(pkg, 0)
            } catch (e: PackageManager.NameNotFoundException) {
                return@mapNotNull null
            }
            mapOf(
                "package" to pkg,
                "label" to pm.getApplicationLabel(info).toString(),
                "icon" to pngBytes(pm.getApplicationIcon(info)),
            )
        }
    }

    private fun shareToApp(pkg: String, file: File, mimeType: String, text: String?) {
        val uri = FileProvider.getUriForFile(activity, "${activity.packageName}.ai_share", file)
        val intent = sendIntent(mimeType).apply {
            setPackage(pkg)
            putExtra(Intent.EXTRA_STREAM, uri)
            if (!text.isNullOrEmpty()) putExtra(Intent.EXTRA_TEXT, text)
            // ClipData carries the read grant to the receiving activity.
            clipData = ClipData.newRawUri(null, uri)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        activity.startActivity(intent)
    }

    private fun pngBytes(drawable: Drawable): ByteArray {
        val size = (48 * activity.resources.displayMetrics.density).toInt()
        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        drawable.setBounds(0, 0, size, size)
        drawable.draw(Canvas(bitmap))
        return ByteArrayOutputStream().use {
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, it)
            it.toByteArray()
        }
    }
}
