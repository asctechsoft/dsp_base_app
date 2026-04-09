package amobi.module.flutter.common.methodchannels

import android.annotation.SuppressLint
import android.app.Activity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import android.media.MediaDrm
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import java.security.MessageDigest
import java.util.UUID
import kotlin.ExperimentalStdlibApi

class DeviceUtilsChannelHandler(val binding: FlutterPlugin.FlutterPluginBinding) :
    MethodChannel.MethodCallHandler, ActivityAware {
    private var activityAttached: Activity? = null

    @SuppressLint("HardwareIds")
    @OptIn(ExperimentalStdlibApi::class)
    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        val context = activityAttached ?: binding.applicationContext

        when (call.method) {
            "getDeviceId" -> {
                val WIDEVINE_UUID = UUID(-0x121074568629b532L, -0x5c37d8232ae2de13L)
                var wvDrm: MediaDrm? = null

                try {
                    wvDrm = MediaDrm(WIDEVINE_UUID)
                    val widevineId = wvDrm.getPropertyByteArray(MediaDrm.PROPERTY_DEVICE_UNIQUE_ID)
                    val md = MessageDigest.getInstance("SHA-256")
                    md.update(widevineId)
                    result.success(md.digest().toHexString())
                } catch (_: Exception) {
                    // WIDEVINE is not available -> Fallback to using ANDROID_ID
                    try {
                        val androidId = Settings.Secure.getString(
                            context.contentResolver,
                            Settings.Secure.ANDROID_ID
                        )

                        result.success(androidId)
                    } catch (_: Exception) {
                        result.success(null)
                    }
                } finally {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P)
                        wvDrm?.close()
                    else
                        wvDrm?.release()
                }
            }
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityAttached = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activityAttached = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityAttached = binding.activity
    }

    override fun onDetachedFromActivity() {
        activityAttached = null
    }
}