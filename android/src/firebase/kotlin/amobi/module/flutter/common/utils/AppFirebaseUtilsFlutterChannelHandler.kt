package amobi.module.flutter.common.utils

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

// It shows "Class "AppFirebaseUtilsFlutterChannelHandler" is never used"
// but this class is actually be used in AmobiCommonPlugin class using class reflection
// DO NOT REMOVE THIS!
class AppFirebaseUtilsFlutterChannelHandler : MethodChannel.MethodCallHandler {
    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        when (call.method) {
            "setupAppCheckCustomProviderFactory" -> {
                AppCheckUtils.setupProviderFactory()
                result.success(null)
            }
        }
    }
}