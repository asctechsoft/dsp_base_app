package amobi.module.flutter.common.methodchannels

import amobi.module.flutter.common.configs.GDPRAssist
import android.app.Activity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class GDPRAssistChannelHandler(val binding: FlutterPlugin.FlutterPluginBinding) :
    MethodChannel.MethodCallHandler, ActivityAware {
    private var activityAttached: Activity? = null

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        val context = activityAttached ?: binding.applicationContext

        when (call.method) {
            "isGDPR" -> {
                try {
                    val isGdpr = GDPRAssist.isGDPR(context)
                    result.success(isGdpr)
                } catch (e: Exception) {
                    result.error("GDPR_ERROR", "Failed to check GDPR status", e.message)
                }
            }

            "canShowAds" -> {
                try {
                    val canShow = GDPRAssist.canShowAds(context)
                    result.success(canShow)
                } catch (e: Exception) {
                    result.error("GDPR_ERROR", "Failed to check if ads can be shown", e.message)
                }
            }

            "canShowPersonalizedAds" -> {
                try {
                    val canShowPersonalized = GDPRAssist.canShowPersonalizedAds(context)
                    result.success(canShowPersonalized)
                } catch (e: Exception) {
                    result.error(
                        "GDPR_ERROR",
                        "Failed to check if personalized ads can be shown",
                        e.message
                    )
                }
            }

            "isAdmobAvailable" -> {
                try {
                    val gdprIsEnabled = GDPRAssist.isGDPR(context)
                    if (!gdprIsEnabled) {
                        result.success(true)
                    } else {
                        val gdprCanShowAds = GDPRAssist.canShowAds(context)
                        result.success(gdprCanShowAds)
                    }
                } catch (e: Exception) {
                    result.error("GDPR_ERROR", "Failed to check if AdMob is available", e.message)
                }
            }

            else -> {
                result.notImplemented()
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