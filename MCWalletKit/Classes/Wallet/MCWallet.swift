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
    // 钱包ID (以地址为唯一标识）
    @objc dynamic public var id:String = ""
    
    // 钱包的名称
    @objc dynamic public var name:String = ""
    
    // 钱包类型：1为HD钱包，0为非HD钱包
    @objc dynamic public var walletType: Int = 1
    
    // 手机号
    @objc dynamic public var phoneNumber: String = ""
    
    // 在服务端的id,空表示没有上传到服务器
    @objc dynamic public var serverId: String = ""
    
    // 钱包的助记词（加密！）
    let mnemonicWords = List<String>()
    
    // 私钥（当钱包不为HD钱包时，会保存对应的私钥）（加密！）
    @objc dynamic public var privateKey: String = ""
    
    // 钱包密码（加密！）
    @objc dynamic public var password: String = ""
    
    // 钱包所关联的Tokens
    public let tokens = List<Token>()
    
    // HD钱包实例
    var hdWallet: HDWallet? = nil
    
    // 非HD钱包实例
    var wallet: Wallet? = nil
    
    // 处理钱包的服务者对象
    //var serviceProvider: WalletServiceble? = nil
        
    // 设置主键
    override public static func primaryKey() -> String? {
        return "id"
    }
    
    // 忽略的字段
    override public static func ignoredProperties() -> [String] {
        return ["hdWallet","wallet"]
    }
    
    // MARK:- 业务方法
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
    
    /// 导出（查看）钱包的私钥
    public func exportPrivateKey()  -> String {
        if 1 == self.walletType { //如果是HD钱包
            if nil == self.hdWallet {return ""}
            return self.hdWallet!.dumpMainPrivateKey()
        } else {
            if nil == self.wallet {return ""}
            return self.wallet!.dumpPrivateKey()
        }
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
    
    
    /// 修改钱包的密码
    public func modifyPassword(password: String) {
        if 0 == password.count {return}
        let secPassword = CryptTools.Encode_AES_ECB(strToEncode: password, key: CryptTools.secKey)
        
        let realmSelf = MCWalletManger.default.walletList.filter("id = %@",self.id).first
        if nil == realmSelf {return}
        
        let realm = RealmDBHelper.shared.mcDB
        try! realm.write {
            realmSelf?.password = secPassword
        }
    }
    
    // 获取交易帐户
    public func getAccountWithToken(token:Token) -> Accountalbe? {
        if !tokens.contains(token) {return nil}
        var account:Accountalbe
        if Coin(rawValue: UInt32(token.coinIdx)) == Coin.bitcoin {
            account = BtcAccount(wallet: self, token: token)
        } else {
            account = EthAccount(wallet: self, token: token)
        }
        return account
    }
    
    // 是否包含指定的Token
    public func existToken(token:Token) -> Bool{
        if 0 == tokens.count { return false}
        return tokens.contains(token)
    }
    
    /// 增加Token
    public func addToken(token:Token) {
        // 如果不存在token,就增加
        if !Token.exist(symbol: token.symbol) {
            Token.addToken(token: token)
        }
        let realmSelf = MCWalletManger.default.walletList.filter("id = %@",self.id).first
        if nil == realmSelf {return}
        
        let realm = RealmDBHelper.shared.mcDB
        try! realm.write {
            realmSelf?.tokens.append(token)
        }
    }
    
    /// 删除Token
    public func removeToken(token:Token) {
        let realmSelf = MCWalletManger.default.walletList.filter("id = %@",self.id).first
        if realmSelf?.tokens == nil {return}
        if !realmSelf!.tokens.contains(token) { return}
        let idx = realmSelf?.tokens.index(of: token)
        
        let realm = RealmDBHelper.shared.mcDB
        try! realm.write {
            realmSelf?.tokens.remove(at: idx!)
        }
    }
    
    /// 判断密码是否正确
    public func verfyPassword(password: String) -> Bool {
        if 0 == password.count {return false}
        let secPassword = CryptTools.Encode_AES_ECB(strToEncode: password, key: CryptTools.secKey)
        return secPassword == self.password
    }
    
    /// 是否存在 Token
    private func existTokenWithSymbol(symbol: String) -> Bool {
        let t = self.tokens.filter("symbol = %@",symbol).first
        if nil == t {return false}
        return true
    }
    
    /// 对Eth帐户进行签名
    public func signEth(rawTransaction: RawTransaction,token:Token,network:Network) throws -> String {
        var privateSignKey: String = ""
        if walletType == 0 {
            //解密password
            let pass = CryptTools.Decode_AES_ECB(strToDecode: self.password, key: CryptTools.secKey)
            privateSignKey = CryptTools.Encode_AES_ECB(strToEncode: self.privateKey, key: pass)
        } else if walletType == 1 {
            privateSignKey = self.exportPrivateKey()
        }
        
        ///这个地方需要重构，以适应所有的币种签名（因为不同的币种签名方法是不一样的），目前只考虑以太坊一种情况
        let signWallet = Wallet(network: network, privateKey: privateSignKey, debugPrints: false)
        return try signWallet.sign(rawTransaction: rawTransaction)
    }
    
    // MARK:- 与服务相关方法
    /// 帐户总余额
    public func getBalanceCount() -> Double {
        if "" == self.serverId {
            self.send2Server()
        }
        if nil == MCAppConfig.walletServiceHandler {
            return 0.0
        } else {
            return (MCAppConfig.walletServiceHandler!.getBalanceCount(serverId: self.serverId))
        }
    }
    
    /// 分批获取帐户列表
    public func getAccounts() -> [Accountalbe] {
        self.refreshTokens()
        var accounts = [Accountalbe]()
        for t in self.tokens {
            var theAccount: Accountalbe
            if Coin(rawValue: UInt32(t.coinIdx)) == Coin.bitcoin {
                theAccount = BtcAccount(wallet: self, token: t)
            } else {
                theAccount = EthAccount(wallet: self, token: t)
            }
            theAccount.setBalance()//获取最新的余额
            
            accounts.append(theAccount)
        }
        return accounts
    }
    
    // 一次性从服务端返回当前钱包的所有帐户信息
    public func getAccountsOnce() -> [Accountalbe]? {
        if nil == MCAppConfig.walletServiceHandler {return nil}
        return MCAppConfig.walletServiceHandler!.fecthAccounts(wallet: self)
    }
    
    
    /// 上传钱包信息到服务器
    public func send2Server() {
        
        if nil == MCAppConfig.walletServiceHandler { return}
        
        let realmSelf = MCWalletManger.default.walletList.filter("id = %@",self.id).first
        if nil == realmSelf {return}
        
        let realm = RealmDBHelper.shared.mcDB
        try! realm.write {
            realmSelf?.password = (MCAppConfig.walletServiceHandler!.sendWalletInfo2Server(wallet: self))
        }
    }
    
    
    /// 钱包信息是否已经上传到服务器
    private func isSend2Server() -> Bool {
        return self.serverId != ""
    }
    
    // 从服务端根据钱包serverId刷新钱包token信息列表
    private func refreshTokens() {
        if "" == self.serverId {
            self.send2Server()
        }
        if nil == MCAppConfig.walletServiceHandler {return}
        
        let tokens = MCAppConfig.walletServiceHandler!.fecthTokens(serverId: self.serverId)
        if 0 == tokens.count {return}
        
        let realmSelf = MCWalletManger.default.walletList.filter("id = %@",self.id).first
        let existTokens = realmSelf?.tokens
        
        let realm = RealmDBHelper.shared.mcDB
        for t in tokens {
            if !(existTokens?.contains(t))! {
                try! realm.write {
                    existTokens?.append(t)
                }
            }
        }
    }
}
