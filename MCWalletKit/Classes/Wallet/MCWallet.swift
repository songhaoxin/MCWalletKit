//
//  Wallet.swift
//  MCWalletKit
//
//  Created by song mj on 2018/9/16.
//

import UIKit
import RealmSwift

public class MCWallet: Object {

    // MARK:- Realm 属性
    // 钱包ID
    @objc dynamic public var id:String = ""
    // 钱包的名称
    @objc dynamic public var name:String = ""
    
    // 钱包类型：1为HD钱包，0为非HD钱包
    @objc dynamic public var walletType: Int = 1
    
    // 手机号
    @objc dynamic public var phoneNumber: String = ""
    
    // 钱包的助记词（加密！）
    let mnemonicWords = List<String>()
    
    // 私钥（当钱包不为HD钱包时，会保存对应的私钥）（加密！）
    @objc dynamic public var privateKey: String = ""
    
    // 钱包密码（加密！）
    @objc dynamic public var password: String = ""
    
    // 钱包所关联的Tokens
    public let accounts = List<EthAccount>()
    
    // HD钱包实例
    var hdWallet: HDWallet? = nil
    
    // 非HD钱包实例
    var wallet: Wallet? = nil
    
    
    // 设置主键
    override public static func primaryKey() -> String? {
        return "id"
    }
    
    // 忽略的字段
    override public static func ignoredProperties() -> [String] {
        return ["hdWallet","wallet"]
    }
    
    // MARK:- 业务方法
    /// 设置最近使用的钱包
    public func setRecentlyWallet() {
        UserDefaults.standard.set(self.name, forKey:RECENTLY_WALLET_NAME )
    }
    
    /// 设置 助记词 到 对象实例
    public func convertMnemonicWords(mnemonicWords: [String]) {
        self.mnemonicWords.removeAll()
        for word in mnemonicWords {
            self.mnemonicWords.append(word)
        }
    }
    
    
    /// 导出 助记词
    public func exportMnemonicWords() -> [String]? {
        if 0 == self.mnemonicWords.count {
            return nil
        }
        var words = [String]()
        
        for word in self.mnemonicWords {
            let deWord = CryptTools.Decode_AES_ECB(strToDecode: word, key: CryptTools.secKey)
            words.append(deWord)
        }
        
        return words
    }
    
    /// 修改钱包的名称
    public func modifyName(name: String){
        if self.name == name {
            return
        }
        let realm = RealmDBHelper.shared.mcDB;
        let w = realm.objects(MCWallet.self).filter("id = %@",self.id).first
        if nil == w {
            return
        }
        
        try! realm.write {
            w!.name = name
        }
    }
    
    /// 判断密码是否正确
    public func verfyPassword(password: String) -> Bool {
        if 0 == password.count {return false}
        let secPassword = CryptTools.Encode_AES_ECB(strToEncode: password, key: CryptTools.secKey)
        return secPassword == self.password
    }
    
    /// 修改钱包的密码
    public func modifyPassword(password: String) {
        if 0 == password.count {return}
        let secPassword = CryptTools.Encode_AES_ECB(strToEncode: password, key: CryptTools.secKey)
        self.password = secPassword
    }
    
    /// 是否存在 帐户
    public func existAccount(address: String) -> Bool {
        return EthAccount.existAddress(address: address)
    }
    
    /// 增加帐户
    public func addAccountWithToken(token:Token) {
        if nil == hdWallet { return  }
        
        let tokenCoin = Coin(rawValue: UInt32(token.coinIdx))
        let address = try! self.hdWallet!.generateAddress(coin: tokenCoin!)

        let w = MCWalletManger.default.walletList.filter("id = %@",self.id).first
        if nil == w { return}
        
        var account = w!.accounts.filter("address = %@",address).first
        if nil != account { return}
        
        // 创建Account
        account = EthAccount()
        account?.address = address
        account?.token = token
        
        
        let realm = RealmDBHelper.shared.mcDB
        try! realm.write {
            w?.accounts.append(account!)
        }
        
    }
    
    /// 删除帐户
    
    /// 获取帐户列表
   
}
