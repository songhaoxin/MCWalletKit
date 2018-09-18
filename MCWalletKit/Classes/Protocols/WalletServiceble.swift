//
//  WalletServicable.swift
//  MCWalletKit
//
//  Created by song mj on 2018/9/18.
//

import Foundation

/// 用于处理钱包服务相关的协议
public protocol WalletServiceble {
    
    /// 从服务端根据钱包serverId拉取token信息列表
    func sendWalletInfo2Server(wallet: MCWallet) -> String
    
    // 从服务端根据钱包serverId拉取token信息列表
    func fecthTokens(serverId:String) -> [Token]
    
    // 一次性从服务端返回指定钱包中所有帐户信息（包括 币种 + 余额 ）
    func fecthAccounts(wallet: MCWallet) -> [Accountalbe]
    
    // 获取钱包的总余额
    func getBalanceCount(serverId: String) -> Double
}
