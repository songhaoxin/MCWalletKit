//
//  Token.swift
//  MCWalletKit
//
//  Created by song mj on 2018/9/16.
//

import UIKit
import RealmSwift

public enum Coin: UInt32 {
    case bitcoin = 0
    case ethereum = 60
    case ethereumClassic = 61
    case poa = 178
    case callisto = 820
    case gochain = 6060
}

public class Token: Object {
    // MARK:- Realm 属性
    @objc dynamic var symbol: String = ""
    @objc dynamic var contract: String = ""
    @objc dynamic var decimals: Int = 0
    @objc dynamic var image: String = ""
    @objc dynamic var price: Double = 0.0 //CNY
    @objc dynamic var coinIdx: Int = 60
    
    /// 设置主键
    override public static func primaryKey() -> String? {
        return "symbol"
    }
    
    // MARK:- 业务方法
    
    /// 判断是否是代币
    public func isAccesoryCoin() -> Bool {
        return contract != ""
    }
    
    /// 判断是否已经存在Token
    public static func exist(symbol: String) -> Bool{
        if 0 == symbol.count {
            return false
        }
        
        let realm = RealmDBHelper.shared.mcDB;
        let token: Token? = realm.objects(Token.self).filter("symbol = %@",symbol).first
        if nil == token{
            return false
        }
        
        return true
    }
    
    /// 获取 token 实例
    public static func getToken(symbol: String) -> Token? {
        let realm = RealmDBHelper.shared.mcDB;
        let token: Token? = realm.objects(Token.self).filter("symbol = %@",symbol).first
        return token
    }
    
    /// 添加Token
    public static func addToken(token:Token) {
        if self.exist(symbol: token.symbol) {
            return
        }
        let realm = RealmDBHelper.shared.mcDB;
        try! realm.write {
            realm.add(token)
        }
    }
}
