//
//  EthAccount.swift
//  MCWalletKit
//
//  Created by song mj on 2018/9/16.
//

import UIKit
import RealmSwift

public class EthAccount: Object {
    // MARK:- Realm 属性
    // 地址
    @objc dynamic var address: String = ""
    
    // 对应的token
    @objc dynamic var token: Token? = nil
    
    // 所属的钱包
    let wallet = LinkingObjects(fromType: MCWallet.self, property: "accounts")
    
    // 设置主键
    override public static func primaryKey() -> String? {
        return "address"
    }
    
    //MARK:- 公有方法
    public static func existAddress(address: String) -> Bool {
        if 0 == address.count {return false}
        
        let realm = RealmDBHelper.shared.mcDB;
        let w = realm.objects(EthAccount.self).filter("address = %@",address).first
        if nil != w {
            return true
        }
        
        return false
    }
    
    //MARK:- EthAccountable 协议方法
    /// 导出私钥
    public func exportPrivateKye() -> String {
        return ""
    }
    
    /// 导出地址
    public func exportAddress() -> String {
        return ""
    }
    
    /// 签名
    public func sign() -> String {
        return ""
    }
    
    
    /// 转帐
    public func transcateByRaw(to: String, gasPrice: Int, gasLimit: Int, nonce: Int, data: Data) {
        
    }
    
    /// 余额
    public func getBalance() -> Double {
        return 0.0
    }
    
    

}
extension EthAccount: Accountable {
    
}
