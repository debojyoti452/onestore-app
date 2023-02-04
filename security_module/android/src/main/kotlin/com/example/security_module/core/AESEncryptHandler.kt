package com.example.security_module.core

import java.util.*
import javax.crypto.Cipher
import javax.crypto.spec.IvParameterSpec
import javax.crypto.spec.SecretKeySpec

internal class AESEncryptHandler {
    private fun decrypt(
        algorithm: String,
        cipherText: String,
        key: SecretKeySpec,
        iv: IvParameterSpec
    ): String {
        val cipher = Cipher.getInstance(algorithm)
        cipher.init(Cipher.DECRYPT_MODE, key, iv)
        val plainText = cipher.doFinal(Base64.getDecoder().decode(cipherText))
        return String(plainText)
    }

    private fun encrypt(
        algorithm: String,
        inputText: String,
        key: SecretKeySpec,
        iv: IvParameterSpec
    ): String {
        val cipher = Cipher.getInstance(algorithm)
        cipher.init(Cipher.ENCRYPT_MODE, key, iv)
        val cipherText = cipher.doFinal(inputText.toByteArray())
        return Base64.getEncoder().encodeToString(cipherText)
    }

    private val inputText = "abcdefghigklmnopqrstuvwxyz0123456789"
    private val algorithm = "AES/CBC/PKCS5Padding"
    private val key = SecretKeySpec("1234567890123456".toByteArray(), "AES")
    private val iv = IvParameterSpec(ByteArray(16))

    private val cipherText = encrypt(algorithm, inputText, key, iv)
    val plainText = decrypt(algorithm, cipherText, key, iv)
}
