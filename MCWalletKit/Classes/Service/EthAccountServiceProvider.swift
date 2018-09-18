//
//  AccountServiceProvider.swift
//  MCWalletKit
//
//  Created by song mj on 2018/9/18.
//

import Foundation

/// 负责处理 以太坊帐户 服务端相关业务 的类
class EthAccountServiceProvider: NSObject {
    ///全局唯一实例
    static var shared: EthAccountServiceProvider = {
        let instance = EthAccountServiceProvider()
        return instance
    }()
    
    /// 获取帐户的余额
    public func getBalance(address: String,symbol: String) -> Double {
        // fecth form server ...
        return 0.0
    }
    
    /// 从服务端获取交易信息
    public func getTransactions(address: String) -> [AnyObject]? {
        let transacations = [EthTranscation]()
        // fecth form server ...
        return transacations
    }
    
    /// 根据交易HASH获取交易信息列表
    public func getTransaction(hash: String) -> AnyObject? {
        // fecth from server ...
        return nil
    }
}

extension EthAccountServiceProvider:AccountServiceble {
    
}
