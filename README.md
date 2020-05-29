# JavaScript与WKWebView交互框架设计

## 使用

1. 创建 `webview`，添加 `WebViewInjector`实例
```
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

```

2. 服从 `JSHandler` 协议，实现其方法
```
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
```


## 总体设计

约定所有交互都是由js发起，如果需要native不断向js传递数据，由js先通知native“可以开始传了”。

## native的设计
1. 数据协议中的每种`action`都有独立的`handler`来负责处理和回复。每添加一种`action`就是多一个它的子类。它有2个职责：
  - 声明自己负责的`action`名
  - 得到该`action`相关的整个json对象，按照实际需求做处理，如需要，生成结果json对象，再通过WebView回复给js。
2. 使用一个类`WebViewInjector`来管理所有跟注入有关的逻辑，它的实例的生命周期和WebView几乎相同，并单向依赖WebView。
3. 如果js调用了一个不支持的action，应有一个`DefaultHandler`回复`result`为`false`。

## 数据协议
### js传递给WebView的数据协议
传递的是个json对象：
```js
{
  "action": "action_name",
  "id": "random_value",
  "callback": "function_name",  // optional
  "data": {...}  // optional
}
```

### WebView传递给js的数据协议
WebView传过来的也是个json对象:
```js
{
  "action": "action_name",
  "id": "random_value"
  "result": true
  "data": {...}  // optional
}
```

## 调用方式

约定注入对象名称，此示例 JSModule

js调用native `window.webkit.messageHandlers.JSModule.postMessage(object)`

native调用js `webView.evaluateJavaScript(jsStr, completionHandler: nil)`
