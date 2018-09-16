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
    // MARK:- 属性
    // 单例
    public static let `default` = MCWalletManger()
    
    override public init() {
        //从归档中迁移钱包到数据库
    }
    
    // 请求的网络
    public var network: Network = MCAppConfig.network
    
    // 钱包列表
    public var walletList = RealmDBHelper.shared.mcDB.objects(MCWallet.self)
    
    // 最近使用的钱包name
    public func recentlyWallet() -> MCWallet? {
        let walletName =  UserDefaults.standard.value(forKey: RECENTLY_WALLET_NAME) as? String
        if nil == walletName {
            return nil
        }
        let realm = RealmDBHelper.shared.mcDB;
        let whereCondtion = "name = '\(String(describing: walletName))'"
        return realm.objects(MCWallet.self).filter(whereCondtion).first
    }

    /// 生成助词词
    func generateWords(language: WordList ) -> [String] {
        return Mnemonic.create(strength: .normal, language: language)
    }
    
    /// 是否存在 同名 的钱包
    public  func existWalletWithName(name: String) -> Bool {
        let realm = RealmDBHelper.shared.mcDB;
        let whereCondtion = "name = '\(String(describing: name))'"
        let wallet: MCWallet? = realm.objects(MCWallet.self).filter(whereCondtion).first
        if nil != wallet {
            return true
        }
        return false
    }
    
    /// 创建HD钱包
    public func createHDWallet(name:String!,password:String,worlds:[String],phoneNumber: String = "") -> MCWallet?{
        if 0 == worlds.count {
            return nil
        }
        
        let mcWallet = MCWallet()
        // 用eth的地址作为钱包的唯一ID
        mcWallet.id = try! (mcWallet.hdWallet?.generateAddress(coin: .ethereum))!
        mcWallet.name = name
        mcWallet.walletType = 1
        mcWallet.phoneNumber = phoneNumber
        let secPassword = CryptTools.Encode_AES_ECB(strToEncode: password, key: CryptTools.secKey)
        mcWallet.password = secPassword
        
        let seed = try! Mnemonic.createSeed(mnemonic: worlds)
        mcWallet.hdWallet = HDWallet(seed: seed, network: network)
        mcWallet.wallet = nil
        
        
        //加密助记词
        let mn = worlds.map {
            return CryptTools.Encode_AES_ECB(strToEncode: $0, key: CryptTools.secKey)
        }
        mcWallet.convertMnemonicWords(mnemonicWords: mn)
        
        // 钱包所关联的Tokens
        // 默认为创建Eth/BGFT两种帐户(写死）
        let ethAccount = EthAccount()
        ethAccount.address = try! (mcWallet.hdWallet?.generateAddress(coin: .ethereum))!
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
        ethAccount.token = ethToken
        
        let bgftAccount = EthAccount()
        bgftAccount.address = try! (mcWallet.hdWallet?.generateAddress(coin: .ethereum))!
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
        bgftAccount.token = bgftToken
        
        mcWallet.accounts.append(ethAccount)
        mcWallet.accounts.append(bgftAccount)
        
        let realm = RealmDBHelper.shared.mcDB;
        try! realm.write {
            
        }
        
        return mcWallet
    }
    
    /// 选择钱包
    public func selectWallet(id: String) -> MCWallet? {
        let wallet = walletList.filter("id = %@",id).first
        if nil != wallet {
            wallet?.setRecentlyWallet()
        }
        return wallet
    }

    
    public  func createWallet() {
        print("create wallet ...")
        let mnemonic = Mnemonic.create(strength: .normal, language: .chinese)
        print(mnemonic)
        let realm = RealmDBHelper.shared.mcDB
        print(realm.configuration.fileURL ?? "")
        
#if true
        //Ceate Token
        let token1 = Token()
        token1.symbol = "BGFT"
        token1.decimals = 18
        token1.contract = "0xffflkj"
        token1.image = "abc.png"
        
        let token2 = Token()
        token2.symbol = "BGFT2"
        token2.decimals = 18
        token2.contract = "0xffflkj"
        token2.image = "abc2.png"
        
        let token3 = Token()
        token3.symbol = "BGFT3"
        token3.decimals = 18
        token3.contract = "0xffflkj"
        token3.image = "abc3.png"
        
        let account1 = EthAccount()
        account1.address = "0x111"
        account1.token = token1
        
        let wallet1 = MCWallet()
        wallet1.id = "0xfff00aad"
        wallet1.name = "w1"
        wallet1.mnemonicWords.append("abc")
        wallet1.mnemonicWords.append("bcd")
        wallet1.mnemonicWords.append("xxxx")
        wallet1.phoneNumber = "13129570308"
        wallet1.accounts.append(account1)
        
        try! realm.write {
            realm.add(token1)
            realm.add(token2)
            realm.add(token3)
            
            realm.add(account1)
            realm.add(wallet1)
        }
        
        print(self.walletList)
#endif
        
#if false
        let isExist = self.existWalletWithName(name: "mywallet2")
        if isExist {
            print("存在")
        } else {
            print("不存在")
        }
        /*
        let token2 = realm.objects(Token.self).filter("symbol = 'BGFT2'").first
        
        let account2 = EthAccount()
        account2.address = "0x222"
        account2.token = token2
        

        
        let wallet1 = realm.objects(MCWallet.self).filter("name = 'w1'").first
//        wallet2.name = "w2"
//        wallet2.mnemonicWords.append("xxx")
//        wallet2.mnemonicWords.append("yyy")
//        wallet2.mnemonicWords.append("zzz")
//        wallet2.phoneNumber = "13129570308"
       
        
        try! realm.write {
            realm.add(account2)
             wallet1!.accounts.append(account2)
            //realm.add(wallet2)
        }
        
        print(self.walletList)
 */
        
        #endif
    }

}
