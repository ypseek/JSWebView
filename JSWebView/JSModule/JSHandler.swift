//
//  JSHandle.swift
//  JSWebView
//
//  Created by yupeng. on 2020/5/22.
//  Copyright © 2020 yp. All rights reserved.
//

import Foundation
import WebKit

protocol JSHandler {

    func action() -> String
    func handleJS(from webView: WKWebView, info: [String : Any])
}

extension JSHandler {
    
    func action() -> String {
        return ""
    }
    
    func handleJS(from webView: WKWebView, info: [String : Any]) {
        var toJS = [String : Any].init(minimumCapacity: 4)
        toJS["result"] = false
        invokeCallback(webView: webView, fromJS: info, toJS: toJS)
    }
}

public func invokeCallback(webView: WKWebView, fromJS: [String : Any], toJS: [String : Any]) {
    guard let callback = fromJS["callback"] as? String else {return}
    var newJS = toJS
    newJS["id"] = fromJS["id"]
    newJS["action"] = fromJS["action"]
    guard let data = try? JSONSerialization.data(withJSONObject: newJS, options: []) else { return }
    guard let jsonStr = String(data: data, encoding: .utf8) else { return }
    let jsStr = callback + "(" + jsonStr + ")"
    //传给JS
    webView.evaluateJavaScript(jsStr, completionHandler: nil)
}
