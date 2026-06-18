package com.example.file_reader

import android.content.ContentResolver
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.InputStream

class MainActivity : FlutterActivity() {

    private val CHANNEL = "pdf_reader/channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->

                if (call.method == "getPdfBytes") {
                    val uriString = call.argument<String>("uri")

                    try {
                        val uri = Uri.parse(uriString)
                        val inputStream: InputStream =
                            contentResolver.openInputStream(uri)!!

                        val bytes = inputStream.readBytes()
                        inputStream.close()

                        result.success(bytes)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }
}