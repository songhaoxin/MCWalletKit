//
//  EthAccount.swift
//  MCWalletKit
//
//  Created by song mj on 2018/9/16.
//

import UIKit
import RealmSwift

/// 帐户类，与一个具体的币种唯一关联
public class EthAccount: NSObject {
    
    //MARK:- 属性
    /// 关联的钱包实例
    var wallet: MCWallet
    
    // 与之关联的币种信息
    public var token: Token = Token()
    
    // 余额
    public var balance: Double = 0.0
    
    public var count: Double = 0.0
    
    public func setInfo(number:String,
                        price_CNY: String,
                        CNY_total: Double,
                        price_USD: String,
                        USD_total:Double) {
        
        let realm = RealmDBHelper.shared.mcDB;
        let token: Token? = realm.objects(Token.self).filter("symbol = %@",self.token.symbol).first
        if nil == token {return}

        if MCAppConfig.currentCointCounty == "CNY" {
            try! realm.write {
                self.token.price = price_CNY
                self.balance = Double(number)!
                self.count = CNY_total
            }
            
        } else {
            try! realm.write {
                self.token.price = price_USD
                self.balance = Double(number)!
                self.count = USD_total
            }
        }
    }
    
    //MARK:-
    public  init(wallet:MCWallet, token:Token) {
        self.wallet = wallet
        self.token = token
        self.balance = 0.0
        super.init()
//        self.setBalance()
    }
    
    /// 获取帐户余额
    public func setBalance() {
        if nil == MCAppConfig.ethAccountServiceHandler { return}
        MCAppConfig.ethAccountServiceHandler?.setBalance(accout: self)
    }
    
    public func notcie2UI(smybol: String) {
        MCAppConfig.ethAccountServiceHandler!.notcie2UI(smybol: smybol)
    }
    
    
    /// 获取交易信息列表
    public func getTransactions() -> [EthTranscation]? {
        
        if nil == MCAppConfig.ethAccountServiceHandler { return nil}
        let address = self.exportAddress()
        return MCAppConfig.ethAccountServiceHandler?.getTransactions(address: address) as? [EthTranscation]
    }
    
    /// 获取单条交易信息
    public func getTransaction(hash: String) -> EthTranscation? {
        if nil == MCAppConfig.ethAccountServiceHandler { return nil}
        return MCAppConfig.ethAccountServiceHandler?.getTransaction(hash: hash) as? EthTranscation
    }
    
    //MARK:- EthAccountable 协议方法
    /// 导出(显示)私钥
    public func exportPrivateKye() -> String {
        if 1 == self.wallet.walletType {
            if nil == self.wallet.hdWallet {return ""}
            let coin = Coin(rawValue: UInt32(token.coinIdx))
            return (try! self.wallet.hdWallet?.generatePrivateKey(coin: coin!).raw.toHexString())!
        } else {
            if nil == self.wallet.wallet {return ""}
            return (self.wallet.wallet?.dumpPrivateKey())!
        }
    }
    
    /// 导出（显示）地址
    public func exportAddress() -> String {
        if 1 == self.wallet.walletType {
            if nil == self.wallet.hdWallet {return ""}
            let coin = Coin(rawValue: UInt32(token.coinIdx))
            return (try! self.wallet.hdWallet?.generateAddress(coin: coin!))!
        } else {
            if nil == self.wallet.wallet {return ""}
            return (self.wallet.wallet?.generateAddress())!
        }
    }

    /// 签名ETH交易
    public func signEthTransaction(value: Wei,//需要转出的金额，单位是 以太币，调用方法转换成Wei,
                                    to: String,//收币方地址
                                    gasPrice: Int,//该笔交易的价格
                                    gasLimit: Int,//调用服务方接口,
                                    nonce: Int) throws -> String //调用服务方接口提供
    {
        let rt = RawTransaction.init(value:value,
            to: to,
            gasPrice: gasPrice,
            gasLimit: gasLimit,
            nonce: nonce)
        
        let privateKey = self.exportPrivateKye()
        let w = Wallet(network: MCAppConfig.network, privateKey: privateKey, debugPrints: false)
        let tx: String = try! w.sign(rawTransaction: rt)
        
        return tx
    }
    
    
    /// 签名ERC20代币交易
    public func signERC20Transaction(to: String,
                                     amount: String,
                                     gasPrice: Int,
                                     gasLimit: Int,
                                     nonce: Int
        ) throws -> String
    {
        
        //第一步：创建交易数据
        let erc20Coin = ERC20(contractAddress: self.token.contract,
                              decimal: self.token.decimals,
                              symbol: self.token.symbol)
        let parameterData: Data
        do {
            parameterData = try erc20Coin.generateDataParameter(toAddress: to,
                                                                amount: amount)
        } catch let err {
            fatalError("Error:\(err.localizedDescription)")
        }
        let rt = RawTransaction(wei: "0",
                                to: erc20Coin.contractAddress,
                                gasPrice: gasPrice,
                                gasLimit: gasLimit,
                                nonce: nonce,
                                data: parameterData)
        // 第二步：签名
        var tx:String
        let privateKey = self.exportPrivateKye()
        
        let chainId = Network.private(chainID: 1, testUse: true)
        let w = Wallet(network: chainId, privateKey: privateKey, debugPrints: false)
        do {
            tx = try w.sign(rawTransaction: rt)
        }catch let err {
            fatalError("Error:\(err.localizedDescription)")
        }
        return tx
    }
}

extension EthAccount:Accountalbe{

}

