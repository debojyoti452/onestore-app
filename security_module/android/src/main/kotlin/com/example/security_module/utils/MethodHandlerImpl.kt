package com.example.security_module.utils

import android.app.Activity
import android.content.Context
import android.view.WindowManager
import androidx.biometric.BiometricPrompt
import androidx.fragment.app.FragmentActivity
import com.example.security_module.constants.AppConstants
import com.example.security_module.core.SecureWindow
import com.example.security_module.core.SecurityAuthCallback
import com.example.security_module.core.SecurityAuthHandler
import com.example.security_module.utils.Extensions.hasBiometricSupport
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MethodHandlerImpl constructor(
    messenger: BinaryMessenger,
    private val context: Context,
    private val activity: Activity,
) :
    MethodChannel.MethodCallHandler {

    private var methodChannel: MethodChannel? = null
    private var securityAuthHandler: SecurityAuthHandler? = null

    init {
        methodChannel = MethodChannel(messenger, AppConstants.CHANNEL_NAME)
        methodChannel?.setMethodCallHandler(this)
        if (activity !is FragmentActivity) {
            throw IllegalStateException("Activity must be a FragmentActivity")
        }
        securityAuthHandler = SecurityAuthHandler(activity)
    }

    override fun onMethodCall(call: MethodCall, methodResult: MethodChannel.Result) {
        when (call.method) {
            AppConstants.HAS_BIOMETRIC_SUPPORT -> {
                methodResult.success(context.hasBiometricSupport())
            }
            AppConstants.AUTHENTICATE -> {
                securityAuthHandler?.initBiometricPrompt(object :
                    SecurityAuthCallback {
                    override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                        when (errorCode) {
                            BiometricPrompt.ERROR_NEGATIVE_BUTTON -> {
                                // Because in this app, the negative button allows the user to enter an account password. This is completely optional and your app doesn’t have to do it.
                                securityAuthHandler?.loginWithPassword()
                            }
                            BiometricPrompt.ERROR_USER_CANCELED -> {
                                activity.finish()
                            }
                            else -> {
                                methodResult.error(errorCode.toString(), errString.toString(), null)
                            }
                        }
                    }

                    override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
                        methodResult.success(true)
                    }
                })
                securityAuthHandler?.initPromptInfo()
                securityAuthHandler?.authenticate()
            }
            AppConstants.SECURE_APP -> {
                val flag = call.argument<Int>(AppConstants.SECURE_APP)
                if (flag != null) {
                    if (SecureWindow.secureApp(flag)) {
                        activity.window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        activity.window.addFlags(WindowManager.LayoutParams.FLAG_BLUR_BEHIND)
                        activity.window.addFlags(WindowManager.LayoutParams.FLAG_DIM_BEHIND)
                        methodResult.success(true)
                    } else {
                        activity.window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        methodResult.success(false)
                    }
                } else {
                    methodResult.error("400", "Bad Request", null)
                }
            }
            else -> {
                methodResult.notImplemented()
            }
        }
    }


    fun dispose() {
        methodChannel?.setMethodCallHandler(null)
    }
}
