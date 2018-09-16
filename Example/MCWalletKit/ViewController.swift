//
//  ViewController.swift
//  MCWalletKit
//
//  Created by songhaoxin on 09/14/2018.
//  Copyright (c) 2018 songhaoxin. All rights reserved.
//

import UIKit
import MCWalletKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let wm = MCWalletManger.default
        //wm.createWallet()
        let s:String? = UserDefaults.standard.value(forKey: "abc-s") as? String
        print(s ?? "not find value")
        let walletName = "w1"
        let whereCondtion = "name = '\(String(describing: walletName))'"
        print(whereCondtion)
        
        wm.createWallet()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

