package com.example.security_module.core

import android.view.WindowManager

object SecureWindow {
    fun secureApp(flag: Int): Boolean {
        return when (flag) {
            WindowManager.LayoutParams.FLAG_SECURE ->
                true
            else -> {
                false
            }
        }
    }
}
