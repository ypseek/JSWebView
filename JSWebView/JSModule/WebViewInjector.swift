//
//  WebViewInjector.swift
//  JSWebView
//
//  Created by yupeng. on 2020/5/22.
//  Copyright © 2020 yp. All rights reserved.
//

import Foundation
import WebKit

class WebViewInjector: NSObject, WKScriptMessageHandler {
    
    var webView: WKWebView!
    var JSHandlers: [String : JSHandler] = [:]
    
    public func inject(to webView: WKWebView) {
        self.webView = webView
        self.addHandler(handler: GetPackageNameHandler())
    }
    
    private func addHandler(handler: JSHandler) {
        JSHandlers[handler.action()] = handler
    }
    
    /*
    WebView传过来的数据结构:
    {
      "action": "action_name",
      "id": "random_value"
      "result": true
      "data": {...}  // optional
    }
    action：与传给WebView的一致。如果各种操作都用同一个回调函数，则可以此区分是哪个操作。
    id：与传给WebView的一致。
    result：操作结果。如果是true，则成功，如果是false，则为错误信息
    data：操作结果对应的数据，某些操作才有。即使只有一项数据，也应放到字典里由key来标识
    */
    
    // MARK: - WKScriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let body = message.body
        guard let dic = body as? [String : Any] else {return}
        guard let action = dic["action"] as? String else {return}
        var handler = JSHandlers[action]
        if handler == nil {
            handler = DefaultHandler.instance
        }
        handler?.handleJS(from: webView, info: dic)
    }
}
