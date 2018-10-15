//
//  Accountable.swift
//  MCWalletKit
//
//  Created by song mj on 2018/9/16.
//

import UIKit

/// 用于帐户的协议
public protocol AccountServiceble {
    /// 获取帐户的余额
    func setBalance(accout: Accountalbe)
    
    /// 从服务端获取交易信息
    func getTransactions(address: String) -> [AnyObject]?
    
    /// 根据交易HASH获取交易信息列表
    func getTransaction(hash: String) -> AnyObject?
    
    func notcie2UI(smybol: String)
}
