package com.example.seen_this

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.os.Bundle
import android.net.Uri
import android.provider.MediaStore
import java.io.File
import java.io.InputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.seen_this/share"
    private var sharedText: String? = null
    private var sharedMediaPath: String? = null
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getSharedText" -> {
                        result.success(sharedText)
                        sharedText = null // Clear after returning
                    }
                    "getSharedMedia" -> {
                        result.success(sharedMediaPath)
                        sharedMediaPath = null // Clear after returning
                    }
                    "getCachedImagePath" -> {
                        val uri = call.argument<String>("uri")
                        if (uri != null) {
                            try {
                                val cachedPath = getCachedImagePath(uri)
                                result.success(cachedPath)
                            } catch (e: Exception) {
                                result.error("IMAGE_ERROR", e.message, null)
                            }
                        } else {
                            result.error("INVALID_URI", "URI is null", null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
    
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        android.util.Log.d("SeenThis", "🔔 onNewIntent called with action: ${intent.action}")
        handleIntent(intent)
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        android.util.Log.d("SeenThis", "📱 onCreate called with action: ${intent?.action}")
        handleIntent(intent)
    }
    
    private fun handleIntent(intent: Intent?) {
        if (intent != null) {
            android.util.Log.d("SeenThis", "🔍 Processing intent with action: ${intent.action}")
            when (intent.action) {
                Intent.ACTION_SEND -> {
                    android.util.Log.d("SeenThis", "📤 ACTION_SEND received")
                    handleSingleShare(intent)
                }
                Intent.ACTION_SEND_MULTIPLE -> {
                    android.util.Log.d("SeenThis", "📤 ACTION_SEND_MULTIPLE received")
                    handleMultipleShare(intent)
                }
                else -> android.util.Log.d("SeenThis", "❓ Unknown action: ${intent.action}")
            }
        }
    }
    
    private fun handleSingleShare(intent: Intent) {
        // Get shared text
        sharedText = intent.getStringExtra(Intent.EXTRA_TEXT) 
            ?: intent.getStringExtra(Intent.EXTRA_SUBJECT)
        if (sharedText != null) {
            android.util.Log.d("SeenThis", "📝 Text shared: $sharedText")
        }
        
        // Get shared media (image/video)
        val uri = intent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM)
        if (uri != null) {
            android.util.Log.d("SeenThis", "📸 Media URI: $uri")
            sharedMediaPath = getRealPathFromURI(uri)
            if (sharedMediaPath != null) {
                android.util.Log.d("SeenThis", "✅ Media path stored: $sharedMediaPath")
            } else {
                android.util.Log.e("SeenThis", "❌ Failed to get media path from URI: $uri")
            }
        }
    }
    
    private fun handleMultipleShare(intent: Intent) {
        // Get shared text
        sharedText = intent.getStringExtra(Intent.EXTRA_TEXT)
        if (sharedText != null) {
            android.util.Log.d("SeenThis", "📝 Text from multiple: $sharedText")
        }
        
        // Get first shared media from multiple
        val uris = intent.getParcelableArrayListExtra<Uri>(Intent.EXTRA_STREAM)
        if (!uris.isNullOrEmpty()) {
            android.util.Log.d("SeenThis", "🖼️ Found ${uris.size} media items")
            sharedMediaPath = getRealPathFromURI(uris[0])
            if (sharedMediaPath != null) {
                android.util.Log.d("SeenThis", "✅ Media path from multiple: $sharedMediaPath")
            } else {
                android.util.Log.e("SeenThis", "❌ Failed to get path from first URI: ${uris[0]}")
            }
        } else {
            android.util.Log.d("SeenThis", "⚠️ SEND_MULTIPLE but no media URIs found")
        }
    }
    
    private fun getRealPathFromURI(uri: Uri): String? {
        return try {
            val inputStream: InputStream? = contentResolver.openInputStream(uri)
            if (inputStream != null) {
                // Copy to cache directory if it's content URI
                val cacheFile = File(cacheDir, "shared_media_${System.currentTimeMillis()}.jpg")
                inputStream.use { input ->
                    cacheFile.outputStream().use { output ->
                        input.copyTo(output)
                    }
                }
                android.util.Log.d("SeenThis", "✅ Cached file at: ${cacheFile.absolutePath}")
                cacheFile.absolutePath
            } else {
                android.util.Log.e("SeenThis", "❌ Could not open input stream for URI: $uri")
                null
            }
        } catch (e: Exception) {
            android.util.Log.e("SeenThis", "❌ Error getting file path from URI: $uri", e)
            null
        }
    }
    
    private fun getImageBytesFromUri(uriString: String): ByteArray? {
        return try {
            val uri = Uri.parse(uriString)
            val inputStream = contentResolver.openInputStream(uri)
            if (inputStream != null) {
                inputStream.use { input ->
                    input.readBytes()
                }
            } else {
                null
            }
        } catch (e: Exception) {
            android.util.Log.e("SeenThis", "Error getting image bytes from URI: $uriString", e)
            null
        }
    }
    
    private fun getCachedImagePath(uriString: String): String? {
        return try {
            val uri = Uri.parse(uriString)
            val inputStream = contentResolver.openInputStream(uri)
            if (inputStream != null) {
                // Copy to cache directory
                val cacheFile = File(cacheDir, "thumb_${System.currentTimeMillis()}.jpg")
                inputStream.use { input ->
                    cacheFile.outputStream().use { output ->
                        input.copyTo(output)
                    }
                }
                cacheFile.absolutePath
            } else {
                null
            }
        } catch (e: Exception) {
            android.util.Log.e("SeenThis", "Error caching image from URI: $uriString", e)
            null
        }
    }
}
