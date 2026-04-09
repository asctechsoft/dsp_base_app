//
//  GDPRAssistChannelHandler.swift
//  amobi_common
//
//  Created by Nguyen Ngoc Long on 13/11/25.
//

import Foundation
import Flutter
import UIKit

public class GDPRAssistChannelHandler {
    func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "isGDPR":
            let isGdpr = GDPRAssist.isGDPR()
            result(isGdpr)
            
        case "canShowAds":
            let canShow = GDPRAssist.canShowAds()
            result(canShow)
            
        case "canShowPersonalizedAds":
            let canShowPersonalized = GDPRAssist.canShowPersonalizedAds()
            result(canShowPersonalized)
            
        case "isAdmobAvailable":
            let gdprIsEnabled = GDPRAssist.isGDPR()
            if !gdprIsEnabled {
                result(true)
            } else {
                let gdprCanShowAds = GDPRAssist.canShowAds()
                result(gdprCanShowAds)
            }
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
