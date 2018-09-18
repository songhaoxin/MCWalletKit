//
//  MCWalletManger.swift
//  Pods-MCWalletKit_Example
//
//  Created by admin on 2018/9/14.
//

import UIKit
import CryptoEthereumSwift

let RECENTLY_WALLET_NAME = "_recentlyWallet_name_"

public class MCWalletManger: NSObject {
    
    // MARK:- 构造方法
    override public init() {
        super.init()
        //从归档中迁移钱包到数据库
        self.migrateFromDirectoryForOldVersion()
    }
    
    
    // MARK:- 属性
    // 单例
    public static let `default` = MCWalletManger()
    
    // 请求的网络类型
    private var network: Network = MCAppConfig.network
    
    // 钱包列表
    public var walletList = RealmDBHelper.shared.mcDB.objects(MCWallet.self)
    
    // MARK:- 公有方法
    /// 是否存在钱包
    public func hasWallet() -> Bool {
        return walletList.count > 0
    }
    
    /// 最近使用的钱包名称
    public func recentlyWallet() -> MCWallet? {
        if walletList.count <= 0 {return nil}
        
        let walletName =  UserDefaults.standard.value(forKey: RECENTLY_WALLET_NAME) as? String
        if nil == walletName {
            self.setRecentlyWallet(wallet: walletList.last!)
            return walletList.last
        }
        let realm = RealmDBHelper.shared.mcDB;
        return realm.objects(MCWallet.self).filter("name = %@",walletName!).first
    }
    
    /// 设置最近使用的钱包
    public func setRecentlyWallet(wallet: MCWallet) {
        UserDefaults.standard.set(wallet.name, forKey:RECENTLY_WALLET_NAME )
    }
    
    /// 选择钱包
    public func selectWallet(id: String) -> MCWallet? {
        let wallet = walletList.filter("id = %@",id).first
        if nil != wallet {
            self.setRecentlyWallet(wallet: wallet!)
        }
        return wallet
    }
    
    /// 删除钱包
    public func removeWallet(wallet: MCWallet) {
        if 0 == walletList.count { return}
        let w = walletList.filter("id = %@", wallet.id).first
        if nil == w { return}
        let realm = RealmDBHelper.shared.mcDB
        try! realm.write {
            realm.delete(w!)
        }
    }

    /// 生成助词词
    public func generateWords(language: WordList ) -> [String] {
        return Mnemonic.create(strength: .normal, language: language)
    }
    
    
    
    public func descript() {
        let realm = RealmDBHelper.shared.mcDB
        print(realm.configuration.fileURL ?? "")
    }
    
    // MARK:- 创建（导入）钱包
    /// 根据助记词（创建、导入）HD钱包
    /// 成功返回钱包实例，失败返回nil
    public func createHDWallet(name:String!,
                               password:String,
                               worlds:[String],
                               phoneNumber: String = "") -> MCWallet?{
        
        if 0 == worlds.count {return nil}
        
        let mcWallet = MCWallet()
        let seed = try! Mnemonic.createSeed(mnemonic: worlds)
        mcWallet.hdWallet = HDWallet(seed: seed, network: network)
        // 用eth的地址作为钱包的唯一ID
        mcWallet.id = try! (mcWallet.hdWallet?.generateAddress(coin: .ethereum))!
        
        if self.existWallet(wallet: mcWallet) {
            return nil
        }
        
        mcWallet.name = name
        mcWallet.walletType = 1
        mcWallet.phoneNumber = phoneNumber
        let secPassword = CryptTools.Encode_AES_ECB(strToEncode: password, key: CryptTools.secKey)
        mcWallet.password = secPassword
        
        
        mcWallet.wallet = nil

        //加密助记词
        let mn = worlds.map {
            return CryptTools.Encode_AES_ECB(strToEncode: $0, key: CryptTools.secKey)
        }
        mcWallet.convertMnemonicWords(mnemonicWords: mn)
        
        // 钱包所关联的Tokens
        // 默认为创建Eth/BGFT两种帐户(写死）
        let ethToken: Token
        if !Token.exist(symbol: "ETH") {
            ethToken = Token()
            ethToken.symbol = "ETH"
            ethToken.decimals = 18
            ethToken.image = ""
            Token.addToken(token: ethToken)
        } else {
            ethToken = Token.getToken(symbol: "ETH")!
        }
        mcWallet.tokens.append(ethToken)
        
        let bgftToken: Token
        if !Token.exist(symbol: "BGFT") {
            bgftToken = Token()
            bgftToken.symbol = "BGFT"
            bgftToken.decimals = 18
            bgftToken.contract = ""
            bgftToken.image = ""
            Token.addToken(token: bgftToken)
        } else {
            bgftToken = Token.getToken(symbol: "BGFT")!
        }
        mcWallet.tokens.append(bgftToken)
        
        let realm = RealmDBHelper.shared.mcDB;
        try! realm.write {
            realm.add(mcWallet)
        }
        
        // 设置刚创建的钱包为当前钱包
        self.setRecentlyWallet(wallet: mcWallet)
        
        return mcWallet
    }

    
    /// 从私钥中创建（导入）钱包
    public func createWallet(privateKey:String!,
                             password:String,
                             name:String!,
                             phoneNumber: String = "") -> MCWallet? {
        let wallet = Wallet(network: network, privateKey: privateKey, debugPrints: false)
        let mcWallet = MCWallet()
        mcWallet.wallet = wallet
        mcWallet.id = wallet.generateAddress()
        if self.existWallet(wallet: mcWallet) { // 已经存在同样的私钥的钱包
            return nil
        }
        mcWallet.hdWallet = nil
        
        mcWallet.walletType = 0
        let secPassword = CryptTools.Encode_AES_ECB(strToEncode: password, key: CryptTools.secKey)
        mcWallet.password = secPassword
        mcWallet.name = name
        mcWallet.phoneNumber = phoneNumber
        
        // 钱包所关联的Tokens
        // 默认为创建Eth/BGFT两种帐户(写死）
        let ethToken: Token
        if !Token.exist(symbol: "ETH") {
            ethToken = Token()
            ethToken.symbol = "ETH"
            ethToken.decimals = 18
            ethToken.image = ""
            Token.addToken(token: ethToken)
        } else {
            ethToken = Token.getToken(symbol: "ETH")!
        }
        mcWallet.tokens.append(ethToken)
        
        let bgftToken: Token
        if !Token.exist(symbol: "BGFT") {
            bgftToken = Token()
            bgftToken.symbol = "BGFT"
            bgftToken.decimals = 18
            bgftToken.contract = ""
            bgftToken.image = ""
            Token.addToken(token: bgftToken)
        } else {
            bgftToken = Token.getToken(symbol: "BGFT")!
        }
        mcWallet.tokens.append(bgftToken)
        
        let realm = RealmDBHelper.shared.mcDB;
        try! realm.write {
            realm.add(mcWallet)
        }
        
        // 设置刚创建的钱包为当前钱包
        self.setRecentlyWallet(wallet: mcWallet)
        
        return mcWallet
    }
    
    // MARK:- 辅助性私有方法
    /// 是否存在 同名 的钱包
    private  func existWalletWithName(name: String) -> Bool {
        let w = self.walletList.filter("name = %@",name).first
        if nil == w {
            return false
        }
        return true
    }
    /// 是存在 ID一致 的钱包
    private func existWallet(wallet:MCWallet) -> Bool {
        let w = self.walletList.filter("id = %@",wallet.id).first
        if nil == w {
            return false
        }
        return true
    }
    
    // MARK:- 老版本的数据迁移
    private  let dataDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/data/"
    // 从归档文件中迁移钱包到数据库
    private func migrateFromDirectoryForOldVersion() {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: dataDir) {
            return
        }
        let dataDirURL = URL(fileURLWithPath: dataDir, isDirectory: true)
        try? fileManager.createDirectory(at: dataDirURL, withIntermediateDirectories: true, attributes: nil)
        
        let accountURLs = try? fileManager.contentsOfDirectory(at: dataDirURL, includingPropertiesForKeys: [], options: [.skipsHiddenFiles])
        for url in accountURLs! {
            let w = NSKeyedUnarchiver.unarchiveObject(withFile: url.path) as? CLWallet
            if nil == w { continue}
            //解密私钥
            let depassword = CryptTools.Decode_AES_ECB(strToDecode: (w?.userPassword)!, key: CryptTools.secKey)
            //解密助记词
            let mn = w?.mnemonicWords.map {
                return CryptTools.Decode_AES_ECB(strToDecode: $0, key: depassword)
            }
            
            if w!.type == .hierarchicalDeterministicWallet {
                if nil != mn {
                   _ =  self.createHDWallet(name: w?.name, password: depassword, worlds: mn!)
                }
            } else {
                let deprivateKey = CryptTools.Decode_AES_ECB(strToDecode: (w?.privateKey)!, key: depassword)
                if 0 == deprivateKey.count {continue}
                _ = self.createWallet(privateKey: deprivateKey, password: depassword, name: w?.name)
            }
            try? fileManager.removeItem(at: url)
        }
        
    }


}
