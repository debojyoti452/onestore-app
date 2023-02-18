package com.swing.onestore

import io.flutter.embedding.android.FlutterFragmentActivity
import android.os.Bundle
import android.provider.SyncStateContract
import com.swing.onestore.constants.Constants
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugins.GeneratedPluginRegistrant
import kotlin.system.exitProcess
import com.swing.onestore.BuildConfig

class MainActivity: FlutterFragmentActivity(), MethodChannel.MethodCallHandler {

    private lateinit var methodCallHandler: MethodChannel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        methodCallHandler =
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, Constants.PLATFORM_CHANNEL_ID)
        methodCallHandler.setMethodCallHandler(this)
    }
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                Constants.PLATFORM_VERSION -> {
                    val versionCode = BuildConfig.VERSION_CODE
                    val versionName = BuildConfig.VERSION_NAME
                    result.success("$versionName ($versionCode)")
                }
                Constants.TERMINATE_APP -> {
                    exitProcess(1)
                }
                else -> result.notImplemented()
            }
        } catch (e: Exception) {
            result.error("Exception", e.message, null)
        }
    }

    override fun onDestroy() {
        methodCallHandler.setMethodCallHandler(null)
        super.onDestroy()
    }
}
