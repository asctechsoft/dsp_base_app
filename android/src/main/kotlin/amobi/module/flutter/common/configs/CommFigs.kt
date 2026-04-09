package amobi.module.flutter.common.configs

import android.app.ActivityManager
import android.content.Context
import android.content.Context.ACTIVITY_SERVICE

object CommFigs {
    // Build Config Flags
    const val IS_DEBUG = AMOBI_CONFIG_IS_DEBUG
    const val IS_ALPHA = AMOBI_CONFIG_IS_ALPHA
    const val IS_DEV = AMOBI_CONFIG_IS_DEV
    const val IS_PRODUCT = AMOBI_CONFIG_IS_PRODUCT

    const val IS_PROD_RELEASE = IS_PRODUCT && !IS_DEBUG
    const val IS_TEST_RTL = false && !IS_PROD_RELEASE
    const val IS_SHOW_TEST_OPTION = IS_ALPHA || IS_DEV
    const val IS_ADD_TEST_DEVICE = IS_SHOW_TEST_OPTION

    // Time when the app was opened
    @Volatile
    var MILLIS_OPENED_APP = 0L
        private set


    fun initialize(context: Context) {
        if (MILLIS_OPENED_APP > 0L) {
            // Already initialized
            return
        }

        MILLIS_OPENED_APP = System.currentTimeMillis()

        fun setDeviceMemoryFlags(
            isLower6GB: Boolean,
            isWeak: Boolean,
            isSuperWeak: Boolean,
        ) {
            IS_LOWER_6GB_DEVICE = isLower6GB
            IS_WEAK_DEVICE = isWeak
            IS_SUPER_WEAK_DEVICE = isSuperWeak
        }

        val actManager = context.getSystemService(ACTIVITY_SERVICE) as ActivityManager
        val memInfo = ActivityManager.MemoryInfo()
        actManager.getMemoryInfo(memInfo)
        val totalMemGigabyte = memInfo.totalMem / (1024.0 * 1024.0 * 1024.0)

        // debugLog("totalMemGigabyte ${totalMemGigabyte}")
        // Set device capability flags based on memory
        when {
            totalMemGigabyte < 2 -> {
                setDeviceMemoryFlags(
                    isLower6GB = true,
                    isWeak = true,
                    isSuperWeak = true,
                )
            }

            totalMemGigabyte < 3.6 -> {
                setDeviceMemoryFlags(
                    isLower6GB = true,
                    isWeak = true,
                    isSuperWeak = false,
                )
            }

            totalMemGigabyte < 5.6 -> {
                setDeviceMemoryFlags(
                    isLower6GB = true,
                    isWeak = false,
                    isSuperWeak = false,
                )
            }

            else -> {
                setDeviceMemoryFlags(
                    isLower6GB = false,
                    isWeak = false,
                    isSuperWeak = false,
                )
            }
        }

    }

    // Device Memory Flags
    @Volatile
    var IS_LOWER_6GB_DEVICE = false
        private set

    @Volatile
    var IS_WEAK_DEVICE = false
        private set

    @Volatile
    var IS_SUPER_WEAK_DEVICE = false
        private set

    // Log Tags
    const val LOG_TAG_INTER_AD = "interAdsLogTest"
    const val LOG_TAG_NATIVE_AD = "nativeAdsLogTest"
    const val LOG_TAG_BANNER_AD = "bannerAdsLogTest"
    const val LOG_TAG_OPEN_AD = "openAdsLogTest"
    const val LOG_TAG_REWARD_AD = "rewardAdsLogTest"


    // Time Constants
    const val MILLIS_SECOND = 1_000L
    const val MILLIS_MINUTE = 60 * MILLIS_SECOND
    const val MILLIS_HOUR = 60 * MILLIS_MINUTE
    const val MILLIS_DAY = 24 * MILLIS_HOUR

    const val SECONDS_MINUTE = 60L
    const val SECONDS_HOUR = 60 * SECONDS_MINUTE
    const val SECONDS_DAY = 24 * SECONDS_HOUR

    const val MINUTES_DAY = 24 * 60


    // Misc Constants
    const val HINT_REQUIRE_CHAR = " <font color=\"#ff0000\">*</font>"
    const val THIN_SPACE = "\u2009"
}
