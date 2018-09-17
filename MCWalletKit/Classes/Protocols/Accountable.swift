//
//  Accountable.swift
//  MCWalletKit
//
//  Created by song mj on 2018/9/16.
//

import UIKit

/// 用于帐户的协议
public protocol Accountable {
    
    /// 导出私钥
    func exportPrivateKye() -> String
    
    /// 签名
    func sign() -> String
    
    /// 地址
    func exportAddress() -> String
    
    /// 转帐
    func transcateByRaw(to: String, gasPrice: Int, gasLimit: Int, nonce: Int, data: Data)
  
    /// 余额
    func getBalance() -> Double
    
}
