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
        URLProtocol.registerClass(EMGURLProtocol.self)
        
        let defaultImpl = class_getInstanceMethod(
            URLSessionConfiguration.self,
            #selector(getter: URLSessionConfiguration.protocolClasses))
        let emergeImpl = class_getInstanceMethod(
            URLSessionConfiguration.self,
            #selector(getter: URLSessionConfiguration.swizzledProtocolClasses))
        method_exchangeImplementations(defaultImpl!, emergeImpl!)
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
