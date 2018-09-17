//
//  CLWallet.swift
//  MCWalletKit
//
//  Created by admin on 2018/9/17.
//

import UIKit
public enum WalletType :UInt8{
    case encryptedKey
    case hierarchicalDeterministicWallet
}
/// 该类仅仅只是为了解决从老版本中迁移钱包使用
class CLWallet: NSObject,NSCoding {
    public var id: String = ""
    public var name: String = ""
    public var type: WalletType = .hierarchicalDeterministicWallet

    public var userPassword: String = ""
    public var mnemonicWords: [String] = [""]
    public var privateKey:String = ""
    
    // MARK:- CODING 协议方法
    /// 归档方法
    public func encode(with aCoder: NSCoder){        
        aCoder.encode(id, forKey: "id")
        aCoder.encode(name,forKey:"name")
        aCoder.encode(type.rawValue, forKey: "type")
        
        aCoder.encode(privateKey, forKey: "privateKey")
        aCoder.encode(mnemonicWords, forKey: "mnemonicWords")
        aCoder.encode(userPassword, forKey: "userPassword")
    }
    
    /// 解档方法
    required public init(coder aDecoder: NSCoder){
        super.init()
        id = aDecoder.decodeObject(forKey: "id") as! String
        name = aDecoder.decodeObject(forKey: "name") as! String
        type = WalletType(rawValue: aDecoder.decodeObject(forKey: "type") as! WalletType.RawValue)!
        
        privateKey = aDecoder.decodeObject(forKey: "privateKey") as! String
        mnemonicWords = aDecoder.decodeObject(forKey: "mnemonicWords") as! [String]
        userPassword = aDecoder.decodeObject(forKey: "userPassword") as! String
    }

}
