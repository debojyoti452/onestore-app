package com.example.security_module.core

import android.os.Handler
import android.os.Looper
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricPrompt
import androidx.fragment.app.FragmentActivity
import java.util.concurrent.Executor

interface SecurityAuthCallback {
    fun onAuthenticationError(errorCode: Int, errString: CharSequence)
    fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult)
}

internal class SecurityAuthHandler(
    private val activity: FragmentActivity,
) {
    private lateinit var executor: Executor
    private lateinit var biometricPrompt: BiometricPrompt
    private lateinit var promptInfo: BiometricPrompt.PromptInfo

    // Initialize the BiometricPrompt object
    fun initBiometricPrompt(callback: SecurityAuthCallback) {
        executor = ExecutorHandler()
        biometricPrompt = BiometricPrompt(activity, executor,
            object : BiometricPrompt.AuthenticationCallback() {
                override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                    super.onAuthenticationError(errorCode, errString)
                    callback.onAuthenticationError(errorCode, errString)
                }

                override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
                    super.onAuthenticationSucceeded(result)
                    callback.onAuthenticationSucceeded(result)
                }
            })
    }

    // Initialize the BiometricPrompt.PromptInfo object
    fun initPromptInfo() {
        promptInfo = BiometricPrompt.PromptInfo.Builder()
            .setTitle("Biometric login for my app")
            .setSubtitle("Log in using your biometric credential")
            .setAllowedAuthenticators(BiometricManager.Authenticators.BIOMETRIC_STRONG or BiometricManager.Authenticators.DEVICE_CREDENTIAL)
            .build()
    }

    // Start the authentication process
    fun authenticate() {
        biometricPrompt.authenticate(promptInfo)
    }

    // Login with password
    fun loginWithPassword() {
    }


    // class for handling executor
    internal class ExecutorHandler : Executor {
        private val handler = Handler(Looper.getMainLooper())
        override fun execute(command: Runnable) {
            handler.post(command)
        }
    }
}


