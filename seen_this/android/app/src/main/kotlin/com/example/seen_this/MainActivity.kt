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
                    else -> result.notImplemented()
                }
            }
    }
    
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
    }
    
    private fun handleIntent(intent: Intent?) {
        if (intent != null) {
            when (intent.action) {
                Intent.ACTION_SEND -> {
                    handleSingleShare(intent)
                }
                Intent.ACTION_SEND_MULTIPLE -> {
                    handleMultipleShare(intent)
                }
            }
        }
    }
    
    private fun handleSingleShare(intent: Intent) {
        // Get shared text
        sharedText = intent.getStringExtra(Intent.EXTRA_TEXT) 
            ?: intent.getStringExtra(Intent.EXTRA_SUBJECT)
        
        // Get shared media (image/video)
        val uri = intent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM)
        if (uri != null) {
            sharedMediaPath = getRealPathFromURI(uri)
        }
    }
    
    private fun handleMultipleShare(intent: Intent) {
        // Get shared text
        sharedText = intent.getStringExtra(Intent.EXTRA_TEXT)
        
        // Get first shared media from multiple
        val uris = intent.getParcelableArrayListExtra<Uri>(Intent.EXTRA_STREAM)
        if (!uris.isNullOrEmpty()) {
            sharedMediaPath = getRealPathFromURI(uris[0])
        }
    }
    
    private fun getRealPathFromURI(uri: Uri): String? {
        return try {
            val inputStream: InputStream? = contentResolver.openInputStream(uri)
            if (inputStream != null) {
                // Copy to cache directory if it's content URI
                val cacheFile = File(cacheDir, "shared_media_${System.currentTimeMillis()}")
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
            android.util.Log.e("SeenThis", "Error getting file path from URI", e)
            null
        }
    }
}
