package amobi.module.flutter.common.configs

import android.util.Base64
import javax.crypto.Cipher
import javax.crypto.spec.IvParameterSpec
import javax.crypto.spec.SecretKeySpec

object UtilitiesNdk {
    private val libraryLoaded: Boolean = runCatching {
        System.loadLibrary("utilities_ndk")
        true
    }.getOrElse { false }

    private fun getDecrypted(
        text: String,
        keyBytes: ByteArray,
    ): String {
        val keySpec = SecretKeySpec(keyBytes, "AES")
        cipher.init(Cipher.DECRYPT_MODE, keySpec, ivSpec)
        val plainText = cipher.doFinal(Base64.decode(text, Base64.DEFAULT))
        return String(plainText)
    }


    external fun validatorNative(): String
    fun validator(keyChars: CharArray): String {
        fun tryGetValidatorNative(): String? {
            if (!libraryLoaded) return null
            return try {
                validatorNative()
            } catch (_: UnsatisfiedLinkError) {
                null
            } catch (_: Throwable) {
                null
            }
        }

        val nativeValue = tryGetValidatorNative() ?: return ""
        var keyBytes: ByteArray? = null
        try {
            keyBytes = String(keyChars).toByteArray()
            return getDecrypted(nativeValue, keyBytes)
        } finally {
            if (keyBytes != null) {
                java.util.Arrays.fill(keyBytes, 0)
            }
            java.util.Arrays.fill(keyChars, '\u0000')
        }
    }


    private const val algorithm = "AES/CBC/PKCS5Padding"
    private val cipher = Cipher.getInstance(algorithm)
    private val iv = ByteArray(16)
    private val ivSpec = IvParameterSpec(iv)


    external fun secretTokenNative(): String
    fun secretToken(keyChars: CharArray = "40e0mwm62j6cq9ab".toCharArray()): String {
        fun tryGetSecretTokenNative(): String? {
            if (!libraryLoaded) return null
            return try {
                secretTokenNative()
            } catch (_: UnsatisfiedLinkError) {
                null
            } catch (_: Throwable) {
                null
            }
        }

        val nativeValue = tryGetSecretTokenNative() ?: return ""
        var keyBytes: ByteArray? = null
        try {
            keyBytes = String(keyChars).toByteArray()
            return getDecrypted(nativeValue, keyBytes)
        } finally {
            if (keyBytes != null) {
                java.util.Arrays.fill(keyBytes, 0)
            }
            java.util.Arrays.fill(keyChars, '\u0000')
        }
    }

}