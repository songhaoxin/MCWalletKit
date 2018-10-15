//
//  BtcAccount.swift
//  MCWalletKit
//
//  Created by song mj on 2018/9/18.
//

import UIKit

class BtcAccount: NSObject {
    //MARK:- 属性
    /// 关联的钱包实例
    var wallet: MCWallet
    
    // 与之关联的币种信息
    public var token: Token = Token()
    
    // 余额
    public var balance: Double = 0.0
    
    //MARK:-
    public  init(wallet:MCWallet, token:Token) {
        self.wallet = wallet
        self.token = token
        super.init()
        self.setBalance()
    }
    
    /// 获取帐户余额
    public func setBalance() {
    }
    func notcie2UI(smybol: String) {
        
    }
}

extension BtcAccount:Accountalbe {

    func setBalance(number: String, price: String, total: Double) {
        
    }
    
    
    
}
