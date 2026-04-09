import Flutter
import UIKit

public class AmobiCommonPlugin: NSObject, FlutterPlugin {
    private var gdprAssistChannel: FlutterMethodChannel!
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        //    let channel = FlutterMethodChannel(name: "amobi_common", binaryMessenger: registrar.messenger())
        //    let instance = AmobiCommonPlugin()
        //    registrar.addMethodCallDelegate(instance, channel: channel)
        
        let instance = AmobiCommonPlugin()
        instance.setupChannels(registrar)
    }
    
    private func setupChannels(_ registrar: FlutterPluginRegistrar) {
        let gdprAssistChannelHandler = GDPRAssistChannelHandler()
        gdprAssistChannel = FlutterMethodChannel(name: "amobi.module.flutter.common/gdpr_assist", binaryMessenger: registrar.messenger())
        gdprAssistChannel?.setMethodCallHandler { call, result in
            gdprAssistChannelHandler.handle(call: call, result: result)
        }
    }
}
