package amobi.module.flutter.common

import amobi.module.flutter.common.methodchannels.DeviceUtilsChannelHandler
import amobi.module.flutter.common.methodchannels.GDPRAssistChannelHandler
import amobi.module.flutter.common.utils.DebugLogCustom
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel

class AmobiCommonPlugin : FlutterPlugin {
    private var appFirebaseUtilsChannel: MethodChannel? = null
    private var gdprAssistChannel: MethodChannel? = null
    private var deviceUtilsAssistChannel: MethodChannel? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        // Firebase utils method channel
        // This module can be integrated to a non-firebase project
        // That's why we have this try
        try {
            DebugLogCustom.logd(
                "❕ onAttachedToEngine - AppFirebaseUtilsFlutterChannelHandler - trying",
                "AmobiCommonPlugin"
            )
            val appFirebaseUtilsFlutterChannelHandlerClass =
                Class.forName("amobi.module.flutter.common.utils.AppFirebaseUtilsFlutterChannelHandler")
            val appFirebaseUtilsFlutterChannelHandlerInstance =
                appFirebaseUtilsFlutterChannelHandlerClass.getDeclaredConstructor().newInstance()

            appFirebaseUtilsChannel = MethodChannel(
                binding.binaryMessenger,
                "amobi.module.flutter.common/firebase_utils"
            ).apply {
                setMethodCallHandler(appFirebaseUtilsFlutterChannelHandlerInstance as MethodChannel.MethodCallHandler)
            }

            DebugLogCustom.logd(
                "✅ onAttachedToEngine - AppFirebaseUtilsFlutterChannelHandler - success",
                "AmobiCommonPlugin"
            )
        } catch (e: Exception) {
            e.printStackTrace()

            DebugLogCustom.logd(
                "❌ onAttachedToEngine - AppFirebaseUtilsFlutterChannelHandler - error - $e",
                "AmobiCommonPlugin"
            )
        }

        // GDPR Assist method channel
        gdprAssistChannel = MethodChannel(
            binding.binaryMessenger,
            "amobi.module.flutter.common/gdpr_assist"
        ).apply {
            setMethodCallHandler(GDPRAssistChannelHandler(binding))
        }

        // Device utils method channel
        deviceUtilsAssistChannel = MethodChannel(
            binding.binaryMessenger,
            "amobi.module.flutter.common/device_utils"
        ).apply {
            setMethodCallHandler(DeviceUtilsChannelHandler(binding))
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        appFirebaseUtilsChannel?.setMethodCallHandler(null)
        appFirebaseUtilsChannel = null

        gdprAssistChannel?.setMethodCallHandler(null)
        gdprAssistChannel = null

        deviceUtilsAssistChannel?.setMethodCallHandler(null)
        deviceUtilsAssistChannel = null
    }
}