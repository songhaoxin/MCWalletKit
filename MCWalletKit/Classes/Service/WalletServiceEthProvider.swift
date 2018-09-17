//
//  WalletService.swift
//  MCWalletKit
//
//  Created by song mj on 2018/9/18.
//

import Foundation

/// 负责处理 钱包 中以太坊服务端相关业务 的类
class WalletServiceEthProvider: NSObject {
    //全局唯一实例
    static var shared: WalletServiceEthProvider = {
        let instance = WalletServiceEthProvider()
        return instance
    }()
    
    /// 从服务端根据钱包serverId拉取token信息列表
    public func sendWalletInfo2Server(wallet: MCWallet) -> String {
        return "serverId from server"
    }
    
    // 从服务端根据钱包serverId拉取token信息列表
    public func fecthTokens(serverId:String) -> [Token] {
        let tokens = [Token]()
        // do some thing ...
        return tokens
    }
    
    public func getBalanceCount(serverId: String) -> Double {
        // do some thing form server ...
        return 0
    }
}
