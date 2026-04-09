package amobi.module.flutter.common.utils

import amobi.module.flutter.common.configs.AMOBI_CONFIG_APP_CHECK_KEY
import amobi.module.flutter.common.configs.CommFigs
import com.google.firebase.Firebase
import com.google.firebase.appcheck.FirebaseAppCheck
import com.google.firebase.appcheck.appCheck
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlin.coroutines.resume

object AppCheckUtils {
    fun requestToken(callback: (String?) -> Unit) {
        Firebase.appCheck.limitedUseAppCheckToken.addOnSuccessListener { appCheckTokenResult ->
            val appCheckToken = appCheckTokenResult.token
            debugLog("Success to get App Check token")
            callback(appCheckToken)
        }.addOnFailureListener { exception ->
            debugLog("Failed to get App Check token: ${exception.message}")
            callback(null)
        }
    }

    suspend fun requestTokenSuspend(): String? = suspendCancellableCoroutine { cont ->
        Firebase.appCheck.limitedUseAppCheckToken
            .addOnSuccessListener { appCheckTokenResult ->
                val appCheckToken = appCheckTokenResult.token
                debugLog("Success to get App Check token")
                cont.resume(appCheckToken)
            }
            .addOnFailureListener { exception ->
                debugLog("Failed to get App Check token: ${exception.message}")
                cont.resume(null)
            }
    }

    fun setupProviderFactory() {
        FirebaseAppCheck.getInstance().installAppCheckProviderFactory(
            CustomAppCheckProviderFactory(AMOBI_CONFIG_APP_CHECK_KEY.toCharArray()),
        )

        if (CommFigs.IS_DEBUG) {
            debugLog("❕ Invoke App Check token")
            requestToken {
                debugLog("✅ Done to get App Check token")
            }
        }
    }
}