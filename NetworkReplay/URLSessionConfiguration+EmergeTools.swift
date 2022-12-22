//
//  URLSessionConfiguration+EmergeTools.swift
//  TrevorSwiftUI
//
//  Created by Trevor Elkins on 12/22/22.
//

import Foundation

var hasSwizzled = false

public extension URLSessionConfiguration {
    
    class func performEmergeSetup() {
        // Only swizzle if we are recording or replaying network traffic
        let environment = ProcessInfo.processInfo.environment
        guard environment["EMG_RECORD_NETWORK"] == "1" || environment["EMG_NETWORK_INTERCEPT"] == "1" else {
            return
        }
        
        URLProtocol.registerClass(EMGURLProtocol.self)
        
        let originalSelector = #selector(getter: URLSessionConfiguration.protocolClasses)
        let originalMethod = class_getInstanceMethod(URLSessionConfiguration.self, originalSelector)
        let originalImp = method_getImplementation(originalMethod!)
        
        let swizzledSelector = #selector(getter: URLSessionConfiguration.swizzledProtocolClasses)
        let swizzledMethod = class_getInstanceMethod(URLSessionConfiguration.self, swizzledSelector)
        let swizzledImp = method_getImplementation(swizzledMethod!)
        
        class_replaceMethod(
            URLSessionConfiguration.self,
            swizzledSelector,
            originalImp,
            method_getTypeEncoding(originalMethod!));
        class_replaceMethod(
            URLSessionConfiguration.self,
            originalSelector,
            swizzledImp,
            method_getTypeEncoding(swizzledMethod!));
    }
    
    @objc var swizzledProtocolClasses: [AnyObject]? {
        var protocolClasses = self.swizzledProtocolClasses ?? []
        if (!hasSwizzled) {
            hasSwizzled = true
            protocolClasses.insert(EMGURLProtocol.self, at: 0)
        }
        return protocolClasses
    }
    
}
