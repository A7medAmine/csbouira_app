package com.csbouira.csbouira_app

import androidx.core.content.FileProvider

/**
 * Shares files from `<cache>/ai_share` with AI apps ("Ask AI" in the
 * previewer). Its own subclass so the manifest entry doesn't clash with the
 * FileProviders that plugins declare.
 */
class AiShareFileProvider : FileProvider()
