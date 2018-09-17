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
        wm.descript()
        print(wm.walletList)
        
        let curretnWallet = wm.recentlyWallet()
        if nil != curretnWallet {
            print(curretnWallet!)
        }
        
        
        /*
        //创建助记词
        let words = ["递", "荒", "它", "仪", "陆", "苯", "缩", "画", "条", "劲", "池", "融"]//wm.generateWords(language: .chinese)
        let wallet = wm.createHDWallet(name: "myWallet1", password: "smj791206", worlds: words, phoneNumber: "13129570308")
        print(wallet!.exportMnemonicWords()!)
        print("----------")
        print(wm.walletList)
 */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

