//
//  ViewController.swift
//  Example-iOS-Swift
//
//  Created by Wolf3D on 26/5/21.
//
import UIKit
import WebKit
import Foundation

protocol WebViewDelegate {
    func avatarUrlCallback(url : String)
}

class WebViewController: UIViewController, WKScriptMessageHandler {
    

    var avatarUrlDelegate:WebViewDelegate?
    var webView: WKWebView!
    let cookieName = "rpm-uid"
    var subscriptionCreated = false
    
    //Update to your custom URL here
    //let readyPlayerMeUrl = URL(string: "https://demo.readyplayer.me/avatar")!
    let readyPlayerMeUrl = URL(string: "https://demo.develop.readyplayer.me/avatar?frameApi")!
    
        let source = """
            window.addEventListener('message', function(event){
                const json = parse(event)
        
                if(event.data.includes('.glb')){
                    window.webkit.messageHandlers.iosListener.postMessage(event.data);
                    return;
                }

                if (json?.source !== 'readyplayerme') {
                  return;
                }

                // Susbribe to all events sent from Ready Player Me once frame is ready
                if (json.eventName === 'v1.frame.ready') {
                  window.postMessage(
                    JSON.stringify({
                      target: 'readyplayerme',
                      type: 'subscribe',
                      eventName: 'v1.**'
                    }),
                    '*'
                  );
                }

                window.webkit.messageHandlers.iosListener.postMessage(event.data);


                function parse(event) {
                    try {
                        return JSON.parse(event.data)
                    } catch (error) {
                        return null
                    }
                };
            });
        """
    
    override func loadView(){
        
        let config = WKWebViewConfiguration()
        let script = WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        config.userContentController.addUserScript(script)
        config.userContentController.add(self, name: "iosListener")
        webView = WKWebView(frame: .zero, configuration: config)
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webView.allowsBackForwardNavigationGestures = true
    }
    
    struct MessageData: Decodable {
        let source: String?
        let eventName: String?
        let data: Dictionary<String, String>?
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if let body = message.body as? String{
            
            let jsonData = body.data(using: .utf8)
            
            if let bodyStruct = try? JSONDecoder().decode(MessageData.self, from: jsonData!){
                switch bodyStruct.eventName {
                case "v1.avatar.exported":
                    avatarUrlDelegate?.avatarUrlCallback(url : "\(String(describing: bodyStruct.data?["url"]))")
                    reloadPage(clearHistory: false)
                case "v1.subscription.created":
                    subscriptionCreated = true
                default:
                    print("Default event. bodyStruct = \(bodyStruct)")
                }
            }
            else if (!subscriptionCreated) {
                if (body.contains("glb")){
                    avatarUrlDelegate?.avatarUrlCallback(url : "\(body)")
                    reloadPage(clearHistory: false)
                }
            }
            

        }
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
