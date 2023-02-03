package com.example.security_module

import androidx.fragment.app.FragmentActivity
import com.example.security_module.utils.MethodHandlerImpl
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

/** SecurityModulePlugin */
class SecurityModulePlugin : FlutterPlugin, ActivityAware {
    private var methodHandlerImpl: MethodHandlerImpl? = null
    private var flutterPluginBinding: FlutterPlugin.FlutterPluginBinding? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        this.flutterPluginBinding = binding
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        flutterPluginBinding = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        methodHandlerImpl =
            flutterPluginBinding?.let {
                MethodHandlerImpl(
                    it.binaryMessenger,
                    binding.activity.applicationContext,
                    binding.activity
                )
            }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        if (methodHandlerImpl != null) {
            methodHandlerImpl!!.dispose()
            methodHandlerImpl = null
        }
    }
}
