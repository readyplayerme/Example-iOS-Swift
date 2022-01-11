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

class WebViewController: UIViewController, WKScriptMessageHandler {
    

    var avatarUrlDelegate:WebViewDelegate?
    var webView: WKWebView!
    let cookieName = "rpm-uid"
    
    //Update to your custom URL here
    let readyPlayerMeUrl = URL(string: "https://demo.readyplayer.me/avatar")!
    
    let source = "window.addEventListener('message', function(event){ document.querySelector('.content').remove(); setTimeout(() => {window.webkit.messageHandlers.iosListener.postMessage(event.data);}, 1000) });"
    
    override func loadView(){
        let config = WKWebViewConfiguration()
        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        config.userContentController.addUserScript(script)
        config.userContentController.add(self, name: "iosListener")
        webView = WKWebView(frame: .zero, configuration: config)
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webView.allowsBackForwardNavigationGestures = true
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        avatarUrlDelegate?.avatarUrlCallback(url : "\(message.body)")
        reloadPage(clearHistory: false)
    }
    
    func reloadPage(clearHistory : Bool){
        if(clearHistory){
            WebCacheCleaner.clean()
        }
        webView.load(URLRequest(url: readyPlayerMeUrl))
    }

    func setCallback(delegate: WebViewDelegate){
        avatarUrlDelegate = delegate
    }
    
    func hasCookies() -> Bool {
        var hasRpmCookies = false
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies() { cookies in
            for cookie in cookies {
                hasRpmCookies = cookie.name.contains(self.cookieName)
                if(hasRpmCookies){
                    break
                }
            }
        }
        return hasRpmCookies
    }
}
