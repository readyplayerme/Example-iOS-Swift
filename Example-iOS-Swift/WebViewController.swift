//
//  ViewController.swift
//  Example-iOS-Swift
//
//  Created by Wolf3D on 26/5/21.
//
import UIKit
import WebKit

protocol WebViewDelegate {
    func avatarUrlCallback(url : String)
}

class WebViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    

    var avatarUrlDelegate:WebViewDelegate?
    
    //Update to your custom URL here
    let url = URL(string: "https://readyplayer.me/avatar")!
    
    let source = "window.addEventListener('message', function(event){ document.querySelector('.content').remove(); setTimeout(() => {window.webkit.messageHandlers.iosListener.postMessage(event.data);}, 1000) });"
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        avatarUrlDelegate?.avatarUrlCallback(url : "\(message.body)")
    }
    
    var webView: WKWebView!
    
    override func loadView(){
        let config = WKWebViewConfiguration()
        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        config.userContentController.addUserScript(script)
        config.userContentController.add(self, name: "iosListener")
        webView = WKWebView(frame: UIScreen.main.bounds, configuration: config)
        webView.navigationDelegate = self
        view = webView
    }
    
//    func clearCacheAndCookies(){
//        guard #available(iOS 9.0, *) else {return}
//
//        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
//
//        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
//            records.forEach { record in
//                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
//                #if DEBUG
//                    print("WKWebsiteDataStore record deleted:", record)
//                #endif
//            }
//        }
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }

    func setCallback(delegate: WebViewDelegate){
        avatarUrlDelegate = delegate
        print("TEST")
    }
}
