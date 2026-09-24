package com.csbouira.csbouira_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray

/**
 * Home screen widget listing recently opened files. The Flutter side writes
 * the list as JSON under "recent_files" (lib/data/services/home_widget_service.dart);
 * each row opens csbouira://file/<id> in MainActivity. Tapping the peeking cat
 * plays its full animation once (see [playCat]).
 */
class RecentFilesWidgetProvider : HomeWidgetProvider() {

    private data class Row(val container: Int, val tile: Int, val name: Int, val subtitle: Int)

    private val rows = listOf(
        Row(R.id.widget_row_0, R.id.widget_row_0_tile, R.id.widget_row_0_name, R.id.widget_row_0_subtitle),
        Row(R.id.widget_row_1, R.id.widget_row_1_tile, R.id.widget_row_1_name, R.id.widget_row_1_subtitle),
        Row(R.id.widget_row_2, R.id.widget_row_2_tile, R.id.widget_row_2_name, R.id.widget_row_2_subtitle),
        Row(R.id.widget_row_3, R.id.widget_row_3_tile, R.id.widget_row_3_name, R.id.widget_row_3_subtitle),
    )

    // Pastel icon tile per row: blue, pink, mint, peach.
    private val tileColors = intArrayOf(
        0xFFB2C5FF.toInt(),
        0xFFFFB3CF.toInt(),
        0xFFA8E6C8.toInt(),
        0xFFFFD59E.toInt(),
    )

    private data class Item(val id: String, val name: String, val subtitle: String)

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val items = parse(widgetData.getString("recent_files", null))
        val showCat = widgetData.getBoolean("show_cat", true)
        val density = context.resources.displayMetrics.density
        val pad = (PADDING_DP * density).toInt()
        val bottomPad = ((if (showCat) CAT_STRIP_DP else PADDING_DP) * density).toInt()
        for (widgetId in appWidgetIds) {
            val fit = rowsThatFit(appWidgetManager.getAppWidgetOptions(widgetId), showCat)
            val views = RemoteViews(context.packageName, R.layout.recent_files_widget)
            views.setViewVisibility(R.id.widget_cat, if (showCat) View.VISIBLE else View.GONE)
            views.removeAllViews(R.id.widget_cat_play_slot)
            views.setOnClickPendingIntent(R.id.widget_cat, catTap(context, widgetId))
            views.setViewPadding(R.id.widget_content, pad, pad, pad, bottomPad)
            views.setOnClickPendingIntent(R.id.widget_header, openApp(context, null, 0))
            rows.forEachIndexed { i, row ->
                val item = items.getOrNull(i)
                if (item == null || i >= fit) {
                    views.setViewVisibility(row.container, View.GONE)
                } else {
                    views.setViewVisibility(row.container, View.VISIBLE)
                    views.setTextViewText(row.name, item.name)
                    views.setTextViewText(row.subtitle, item.subtitle)
                    views.setInt(row.tile, "setColorFilter", tileColors[i % tileColors.size])
                    views.setOnClickPendingIntent(
                        row.container,
                        openApp(context, "csbouira://file/${Uri.encode(item.id)}", i + 1),
                    )
                }
            }
            views.setViewVisibility(
                R.id.widget_empty,
                if (items.isEmpty()) View.VISIBLE else View.GONE,
            )
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle,
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        onUpdate(context, appWidgetManager, intArrayOf(appWidgetId), HomeWidgetPlugin.getData(context))
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == ACTION_CAT_TAP) {
            val widgetId = intent.getIntExtra(
                AppWidgetManager.EXTRA_APPWIDGET_ID,
                AppWidgetManager.INVALID_APPWIDGET_ID,
            )
            if (widgetId != AppWidgetManager.INVALID_APPWIDGET_ID) playCat(context, widgetId)
            return
        }
        super.onReceive(context, intent)
    }

    /**
     * Swaps the blinking idle cat for the full animation, then swaps back once
     * it has played through. The launcher runs the ViewFlipper by itself; this
     * process only sends the two partial updates.
     */
    private fun playCat(context: Context, widgetId: Int) {
        val manager = AppWidgetManager.getInstance(context)
        val token = ++playToken
        val start = RemoteViews(context.packageName, R.layout.recent_files_widget).apply {
            removeAllViews(R.id.widget_cat_play_slot)
            addView(
                R.id.widget_cat_play_slot,
                RemoteViews(context.packageName, R.layout.widget_cat_play),
            )
            // Hidden rather than covered, so its ears don't show behind the
            // animated ones.
            setViewVisibility(R.id.widget_cat, View.INVISIBLE)
        }
        manager.partiallyUpdateAppWidget(widgetId, start)

        val pending = goAsync()
        Handler(Looper.getMainLooper()).postDelayed({
            // A newer tap owns the widget now; let it do the swap back.
            if (token == playToken) {
                val showCat = HomeWidgetPlugin.getData(context).getBoolean("show_cat", true)
                val stop = RemoteViews(context.packageName, R.layout.recent_files_widget).apply {
                    removeAllViews(R.id.widget_cat_play_slot)
                    setViewVisibility(R.id.widget_cat, if (showCat) View.VISIBLE else View.GONE)
                }
                manager.partiallyUpdateAppWidget(widgetId, stop)
            }
            pending.finish()
        }, CAT_PLAY_MS)
    }

    private fun catTap(context: Context, widgetId: Int): PendingIntent {
        val intent = Intent(context, RecentFilesWidgetProvider::class.java).apply {
            action = ACTION_CAT_TAP
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
        }
        return PendingIntent.getBroadcast(
            context,
            widgetId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    /**
     * How many rows fit the widget's current height, so a small widget shows
     * fewer whole rows instead of clipping the last one. Uses the portrait
     * height (MAX_HEIGHT); falls back to all rows when the launcher reports none.
     */
    private fun rowsThatFit(options: Bundle, showCat: Boolean): Int {
        val height = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT, 0)
        if (height <= 0) return rows.size
        val bottom = if (showCat) CAT_STRIP_DP else PADDING_DP
        val available = height - PADDING_DP - bottom - HEADER_DP
        return (available / ROW_DP).coerceIn(1, rows.size)
    }

    private fun parse(json: String?): List<Item> {
        if (json.isNullOrEmpty()) return emptyList()
        return try {
            val array = JSONArray(json)
            (0 until array.length()).map { i ->
                val o = array.getJSONObject(i)
                Item(o.getString("id"), o.optString("name"), o.optString("subtitle"))
            }
        } catch (e: Exception) {
            emptyList()
        }
    }

    private fun openApp(context: Context, link: String?, requestCode: Int): PendingIntent {
        val intent = Intent(context, MainActivity::class.java).apply {
            if (link != null) {
                action = Intent.ACTION_VIEW
                data = Uri.parse(link)
            } else {
                action = Intent.ACTION_MAIN
            }
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        return PendingIntent.getActivity(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private companion object {
        // Keep in sync with res/layout/recent_files_widget.xml.
        const val PADDING_DP = 10

        // Bottom padding while the peeking cat is shown ("show_cat", toggled
        // from the profile screen via lib/data/services/home_widget_service.dart).
        const val CAT_STRIP_DP = 39
        const val HEADER_DP = 20
        const val ROW_DP = 47

        const val ACTION_CAT_TAP = "com.csbouira.csbouira_app.action.WIDGET_CAT_TAP"

        // 68 frames x 83ms in res/layout/widget_cat_play.xml, minus a little
        // so the loop doesn't wrap back to its first frame before the swap.
        const val CAT_PLAY_MS = 5600L

        // Bumped on every tap so only the latest tap swaps the idle cat back.
        var playToken = 0
    }
}
