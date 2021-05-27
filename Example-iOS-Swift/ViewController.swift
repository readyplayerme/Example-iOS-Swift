//
//  ViewController.swift
//  Example-iOS-Swift
//
//  Created by Harrison Hough on 26/5/21.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    
    //Update to your custom URL here
    let url = URL(string: "https://readyplayer.me/avatar")!
    
    let source = "window.addEventListener('message', function(event){ document.querySelector('.content').remove(); setTimeout(() => {window.webkit.messageHandlers.iosListener.postMessage(event.data);}, 1000) });"
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let alert = UIAlertController(title: "Avatar URL Generated", message: "\(message.body)", preferredStyle: .alert)
            
             let okButton = UIAlertAction(title: "OK", style: .default, handler: { action in
             })
             alert.addAction(okButton)
             DispatchQueue.main.async(execute: {
                self.present(alert, animated: true)
        })
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }


}

