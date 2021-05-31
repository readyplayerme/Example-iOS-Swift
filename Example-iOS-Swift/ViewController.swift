//
//  ViewController.swift
//  Example-iOS-Swift
//
//  Created by Harrison Hough on 31/5/21.
//

import UIKit
import WebKit

class ViewController: UIViewController, WebViewDelegate {
    
    let webViewControllerTag = 100
    let webViewIdentifier = "WebViewController"
    var controller = UIViewController()
    
    @IBOutlet weak var editAvatarButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editAvatarButton?.isHidden = true
        // Do any additional setup after loading the view.
    }

    @IBAction func onCreateNewAvatarAction(_ sender: Any) {
        createWebView(clearHistory: true)
    }
    
    @IBAction func onEditAvatarAction(_ sender: Any) {
        createWebView(clearHistory: false)
    }
    
    func createWebView(clearHistory : Bool){
        if(clearHistory){
            WebCacheCleaner.clean()
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        controller = storyboard.instantiateViewController(withIdentifier: webViewIdentifier) as UIViewController

        //let webViewController = controller as WebViewController
        guard let webViewController = controller as? WebViewController else {
            // uh oh, casting failed. maybe do some error handling.
            return
        }
        webViewController.avatarUrlDelegate = self
        
        //add as a childviewcontroller
        addChild(controller)

        // Add the child's View as a subview
        self.view.addSubview(controller.view)
        controller.view.frame = view.bounds
        controller.view.tag = webViewControllerTag
        controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // tell the childviewcontroller it's contained in it's parent
        controller.didMove(toParent: self)
    }
    
    func avatarUrlCallback(url: String){
        showAlert(message: url)
        destroyWebView()
        editAvatarButton?.isHidden = false
    }
    
    func showAlert(message: String){
        let alert = UIAlertController(title: "Avatar URL Generated", message: message, preferredStyle: .alert)

             let okButton = UIAlertAction(title: "OK", style: .default, handler: { action in
             })
             alert.addAction(okButton)
             DispatchQueue.main.async(execute: {
                self.present(alert, animated: true)
        })
    }
    
    func destroyWebView(){
        if let viewWithTag = self.view.viewWithTag(webViewControllerTag) {
            
            controller.dismiss(animated: true, completion: nil)
            viewWithTag.removeFromSuperview()
        }else{
            print("No WebView to destroy!")
        }
    }
}
