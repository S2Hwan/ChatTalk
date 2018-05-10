//
//  LoginViewController.swift
//  ChatTalk
//
//  Created by S2H on 2018. 5. 10..
//  Copyright © 2018년 S2H. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    let remoteConfig = RemoteConfig.remoteConfig()
    
    var color : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         // statusbar 설정
        let statusBar = UIView()
        self.view.addSubview(statusBar)
        statusBar.snp.makeConstraints { (make) in
            make.right.top.left.equalTo(self.view)
            make.height.equalTo(20)
        }
        
        color = remoteConfig["splash_background"].stringValue
        
        statusBar.backgroundColor = UIColor(hex: color)
        loginButton.backgroundColor = UIColor(hex: color)
        registerButton.backgroundColor = UIColor(hex: color)
    }


   

}
