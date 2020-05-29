//
//  GetBundleNameHandler.swift
//  JSWebView
//
//  Created by yupeng. on 2020/5/22.
//  Copyright © 2020 yp. All rights reserved.
//

import Foundation
import WebKit

class GetPackageNameHandler: JSHandler {
    
    func action() -> String {
        return "getPackageName"
    }
    
    func handleJS(from webView: WKWebView, info: [String : Any]) {
        let name = Bundle.main.bundleIdentifier
        var toJS = [String : Any].init(minimumCapacity: 4)
        toJS["result"] = true
        toJS["data"] = ["name" : name]
        invokeCallback(webView: webView, fromJS: info, toJS: toJS)
    }
}
