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
    var token: Token = Token()
    
    // 余额
    var balance: Double = 0.0
    
    //MARK:-
    public  init(wallet:MCWallet, token:Token) {
        self.wallet = wallet
        self.token = token
        super.init()
    }
    
    // 从服务端更新该币种的
    public func refreshFromServer() {
        
    }
    
    // 从服务端获取交易数据
    public func fecthTransinfo() -> [EthTranscation] {
        let trans = [EthTranscation]()
        return trans
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

    /// 签名交易，并返回签名的字符串
    public func signTranscationData() throws -> String {
        let privateKey = self.exportPrivateKye()
        let w = Wallet(network: MCAppConfig.network, privateKey: privateKey, debugPrints: false)
        var tx: String
        
        let coinType = Coin(rawValue: UInt32(self.token.coinIdx))
        if Coin.ethereum == coinType { // 以太坊上的交易
            if self.token.contract == "" {// ETH 交易
                
            } else {// 代币交易
                let erc20Coin = ERC20(contractAddress: self.token.contract,
                                      decimal: self.token.decimals,
                                      symbol: self.token.symbol)
                let parameterData: Data
                do {
                    parameterData = try erc20Coin.generateDataParameter(toAddress: "0x000",
                                                                        amount: "10")
                } catch let error {
                    fatalError("Error:\(error.localizedDescription)")
                }
                let rawTransacton = RawTransaction(wei: "0",
                                                   to: erc20Coin.contractAddress,
                                                   gasPrice: Converter.toWei(GWei: 10), // 从服务器获取合理值
                    gasLimit: 210000,    // 从服务器获取合理值
                    nonce: 0,    // 从服务器获取合理值
                    data: parameterData)
                
                tx = try w.sign(rawTransaction: rawTransacton)
                return tx
            }
            
        } else if Coin.bitcoin == coinType{ // 比特币上的交易
            
        }
        return ""
    }
}

