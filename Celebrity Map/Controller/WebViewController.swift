//
//  WebViewController.swift
//  Celebrity Map
//
//  Created by Yinpeng Chen on 2018-06-20.
//  Copyright © 2018 Yinpeng Chen. All rights reserved.
//

import WebKit
import UIKit

class WebViewController: UIViewController, UIWebViewDelegate, WKUIDelegate, WKNavigationDelegate {
    
    var gotCelebrity = Celebrity()
    
    @IBOutlet weak var webWindow: WKWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setweb()
        
        webWindow.uiDelegate = self
        webWindow.navigationDelegate = self
        
        
        setnavi()
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setWebView(url: URL){
        let request = URLRequest(url: url)
        webWindow.load(request)
        
        webWindow.allowsLinkPreview = false
        webWindow.allowsBackForwardNavigationGestures = false
        
        
        webWindow.layer.borderWidth = 1
        webWindow.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        webWindow.allowsBackForwardNavigationGestures = false
//        webView.dataDetectorTypes.remove(UIDataDetectorTypes.all)

    }
    
    func setweb(){
        let wikiPrefix = "https://en.wikipedia.org/wiki/"
        let url = URL(string: "\(wikiPrefix)\(gotCelebrity.name.replacingOccurrences(of: " ", with: "_"))")
        setWebView(url: url!)
        webWindow.evaluateJavaScript("showAlert('奏是一个弹框')") { (item, error) in
            // 闭包中处理是否通过了或者执行JS错误的代码
        }

//        self.webWindow.isUserInteractionEnabled = false
    }
    
    
    func setnavi(){
        
        self.title = "\(gotCelebrity.name)"
        
        self.navigationController?.navigationBar.tintColor = UIColor.white;
        
        navigationItem.titleView?.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = UIColor.red
        
//        let backButton = UIBarButtonItem(title: "back", style: .done, target: nil, action: nil)
//        backButton.addTarget(self, action: #selector(backBtnClicked), for: .touchUpInside)
//        backButton.action = #selector(backBtnClicked)
//        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "<", style: .plain, target: self, action: #selector(backBtnClicked))
        UINavigationBar.appearance().backIndicatorImage = UIImage(named: "left")
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage(named: "left")


//        navigationItem.leftBarButtonItem = backButton


    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        //禁用webview长按后文字选择框和放大框
        webView.stringByEvaluatingJavaScript(from: "document.documentElement.style.webkitUserSelect='none'")
        webView.stringByEvaluatingJavaScript(from: "document.documentElement.style.webkitTouchCallout='none'")
    }
    
    func setGesture(){
        //Auto paste Right -> Name
        var swipeRight = UISwipeGestureRecognizer()
        swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(backTo as () -> Void))
        swipeRight.direction = .right
        self.webWindow.addGestureRecognizer(swipeRight)
    }
    
    @objc func backTo() {
        print("bakcTo")
        _ = navigationController?.popViewController(animated: true)
    }

    @IBAction func backBtnClicked(_ sender: UIButton) {
        _ = navigationController?.popViewController(animated: true)

    }
    
    //MARK - Disable all links in webview
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        if navigationType == .linkClicked {
            return false
        }
        return true
    }
    
    var isInitialLoad = true

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if self.isInitialLoad {
            self.isInitialLoad = false
            print("okok")
        } else {
            webView.stopLoading()
        }
    }


}
