//
//  ViewController.swift
//  JSWebView
//
//  Created by yupeng. on 2020/5/22.
//  Copyright © 2020 yp. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {

    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let injector = WebViewInjector()
        let config = WKWebViewConfiguration()
        let controller = WKUserContentController()
        controller.add(injector, name: "JSModule")
        config.userContentController = controller
        
        webView = WKWebView.init(frame: view.frame, configuration: config)
        view.addSubview(webView)
        injector.inject(to: webView)
        
        let path = Bundle.main.path(forResource: "test-framework", ofType: "html")
        let url = URL.init(fileURLWithPath: path ?? "")
        let request = URLRequest.init(url: url)
        webView.load(request)
    }


}

