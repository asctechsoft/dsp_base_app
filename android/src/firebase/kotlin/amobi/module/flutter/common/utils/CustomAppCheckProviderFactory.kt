package amobi.module.flutter.common.utils

import amobi.module.flutter.common.configs.UtilitiesNdk
import com.google.firebase.FirebaseApp
import com.google.firebase.appcheck.AppCheckProvider
import com.google.firebase.appcheck.AppCheckProviderFactory
import com.google.firebase.appcheck.debug.InternalDebugSecretProvider
import com.google.firebase.appcheck.debug.internal.DebugAppCheckProvider
import com.google.firebase.inject.Provider
import java.util.concurrent.LinkedBlockingQueue
import java.util.concurrent.ThreadFactory
import java.util.concurrent.ThreadPoolExecutor
import java.util.concurrent.TimeUnit

class CustomAppCheckProviderFactory(var keyChars: CharArray) : AppCheckProviderFactory {
    internal inner class CustomProvider : Provider<InternalDebugSecretProvider> {
        private val internalDebugSecretProvider = CustomDebugSecretProvider()
        override fun get(): InternalDebugSecretProvider {
            return internalDebugSecretProvider
        }
    }

    internal inner class CustomDebugSecretProvider : InternalDebugSecretProvider {
        override fun getDebugSecret(): String {
            val local = keyChars
            try {
                if (true) {
                    val secret = UtilitiesNdk.validator(local)
                    debugLog("CustomDebugSecretProvider: $secret")
                    return secret
                } else {
                    return UtilitiesNdk.validator(local)
                }
            } finally {
                // UtilitiesNdk.validator(local) already clears local; ensure our field drops reference
                keyChars = CharArray(0)
            }
        }
    }

    internal class SimpleThreadFactory : ThreadFactory {
        override fun newThread(r: Runnable?): Thread {
            return Thread(r)
        }
    }

    private val NUMBER_OF_CORES = 1
    private val backgroundPriorityThreadFactory = SimpleThreadFactory()

    private val executor = ThreadPoolExecutor(
        NUMBER_OF_CORES * 2,
        NUMBER_OF_CORES * 2,
        60L,
        TimeUnit.SECONDS,
        LinkedBlockingQueue(),
        backgroundPriorityThreadFactory
    )
    private val provider = CustomProvider()
    override fun create(firebaseApp: FirebaseApp): AppCheckProvider {
        return DebugAppCheckProvider(
            firebaseApp,
            provider,
            executor,
            executor,
            executor
        )
    }
}
