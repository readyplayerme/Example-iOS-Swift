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
    func onAvatarExported(event: AvatarExportedEvent)
    func onAssetUnlocked(event: AssetUnlockedEvent)
    func onUserSet(event: UserSetEvent)
    func onUserAuthorized(event: UserAuthorizedEvent)
    func onUserUpdated(event: UserUpdatedEvent)
    func onUserLoggedOut()
}

class WebViewController: UIViewController, WKScriptMessageHandler {
    var webViewDelegate:WebViewDelegate?
    var webView: WKWebView!
    let cookieName = "rpm-uid"
    var subscriptionCreated = false
    //Update to your subdomain URL here
    let subdomain = "demo"
    
    let source = """
            window.addEventListener('message', function(event){
                const json = parse(event)

                if (json?.source !== 'readyplayerme') {
                  return;
                }

                // Susbcribe to all events sent from Ready Player Me once frame is ready
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
            
            if let bodyStruct = try? JSONDecoder().decode(MessageData.self, from: jsonData!) {
                switch bodyStruct.eventName {
                case "v1.avatar.exported":
                    let event = AvatarExportedEvent (url: bodyStruct.data!["url"]!)
                    webViewDelegate?.onAvatarExported(event: event)
                    reloadPage(clearHistory: false)
                case "v1.asset.unlock":
                    let event = AssetUnlockedEvent (userId: bodyStruct.data!["userId"]!,
                                                    assetId: bodyStruct.data!["assetId"]!)
                    webViewDelegate?.onAssetUnlocked(event: event)
                case "v1.user.set":
                    let event = UserSetEvent (id: bodyStruct.data!["id"]!)
                    webViewDelegate?.onUserSet(event: event)
                case "v1.user.updated":
                    let event = UserUpdatedEvent (id: bodyStruct.data!["id"]!)
                    webViewDelegate?.onUserUpdated(event: event)
                case "v1.user.logout":
                    webViewDelegate?.onUserLoggedOut()
                case "v1.user.authorized":
                    let event = UserAuthorizedEvent (id: bodyStruct.data!["id"]!)
                    webViewDelegate?.onUserAuthorized(event: event)
                case "v1.subscription.created":
                    subscriptionCreated = true
                default:
                    print("Default event. \(bodyStruct)")
                }
            }
        }
    }
    
    func reloadPage(clearHistory : Bool){
        let url = URL(string: "https://\(subdomain).readyplayer.me/avatar?frameApi")!
        if(clearHistory){
            WebCacheCleaner.clean()
        }
        webView.load(URLRequest(url: url))
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
