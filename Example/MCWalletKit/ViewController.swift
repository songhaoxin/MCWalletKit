//
//  ViewController.swift
//  MCWalletKit
//
//  Created by songhaoxin on 09/14/2018.
//  Copyright (c) 2018 songhaoxin. All rights reserved.
//

import UIKit
import MCWalletKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //第一步（可选）：
        // 设置负责处理钱包业务的服务器接口的实例，可选，如果不设置，则使用默认的（空壳方法，什么都不干，可以在里面完善）
        //MCAppConfig.walletServiceHandler = xxxx
        
        // 设置负责处理 Eth帐户的实例(可选）如果不设置，则使用默认的（空壳方法，什么都不干，可以在里面完善）
        //MCAppConfig.ethAccountServiceHandler = xxx
        
        //设置负责处理 Btc帐户的实例(可选）如果不设置，则使用默认的（空壳方法，什么都不干，可以在里面完善）
        //MCAppConfig.btcAccountServiceHandler = xxx
        
        /// 第二步：
        // 创建管理钱包的单例
        let wm = MCWalletManger.default
        
        // 第三步：钱包的使用各种方法
        // 是否存在钱包
        if wm.hasWallet() { print("There have some wallet.")} else {print("Nothing in it")}
        
        // 获取最近使用的钱包，如果没有则设置钱包列表中的最后一个
        let myWallet:MCWallet? = wm.recentlyWallet()
        if nil != myWallet {
            //do somthing...
        }
        
        //创建一个钱包
        // 用助记词创建（或导入）HD钱包
        let words = wm.generateWords(language: .chinese)
        let myWallet2: MCWallet? = wm.createHDWallet(name: "myWallet2", password: "mypassword", worlds: words)
        if nil != myWallet2 {
            // do somthing ...
        }
        // 用私钥创建（或导入）普通钱包
        let commWallet: MCWallet? = wm.createWallet(privateKey: "long string for pravite key", password: "mypassword", name: "wallet name",phoneNumber: "131295703038")
        if nil != commWallet {
            // do somthing ...
        }
        
        // 导出钱包的 根 私钥
        _ = commWallet?.exportPrivateKey()
        
        // 导出钱包的助词词
        _ = myWallet?.exportMnemonicWords()
        
        
        
        // 根据钱包的ID选择钱包
        let myWallet3: MCWallet? = wm.selectWallet(id: "walliet's id")
        if nil != myWallet3 {
            // do somthing ...
        }
        
        // 修改钱包名称,若有同名的存在，则不会修改
        myWallet3?.modifyName(name: "new name")
        
        // 修改密码
        myWallet3?.modifyPassword(password: "new password")
        
        // 删除一个钱包
        wm.removeWallet(wallet: myWallet3!)
        
        // 获取钱包中所有的帐户信息
        let accoutArry = myWallet?.getAccountsOnce() as? [EthAccount]
        for account in accoutArry! {
            print(account)
        }
        
        
        // 往钱包中增加一个币种
        let someToken = Token()
        someToken.symbol = "wangpeng"
        someToken.coinIdx = Int(Coin.ethereum.rawValue)
        someToken.decimals = 18
        someToken.price = 12.03
        someToken.image = "someimg.png"
        myWallet?.addToken(token: someToken)
        
        
        // 获取指定 币种 的以太币平台的帐户
        let ethAccount = myWallet!.getAccountWithToken(token: someToken) as! EthAccount
        
        // 查询该帐户的地址
        print(ethAccount.exportAddress())
        
        // 查询该帐户的私钥
        print(ethAccount.exportPrivateKye())
        
        // 发送Eth交易
        //----------------------------------------------------------------------------------------------------
        var tx = try! ethAccount.signEthTransaction(value: try! Converter.toWei(ether: "0.00001"),
                                                   to: "0x000113asfd",
                                                   gasPrice: Converter.toWei(GWei: 10),
                                                   gasLimit: 21000,
                                                   nonce: 0)
        ethAccount.sendTransaction(rawTransacitionString: tx)
        
        //----------------------------------------------------------------------------------------------------
        // 发送代币交易
        tx = try! ethAccount.signERC20Transaction(to: "对方帐号",
                                                  amount: "代币的数量",
                                                  gasPrice: Converter.toWei(GWei: 10),
                                                  gasLimit: 21000,
                                                  nonce: 0)
        ethAccount.sendTransaction(rawTransacitionString: tx)
     //----------------------------------------------------------------------------------------------------
        
        // 获取指定币种的余额
        let balance = ethAccount.getBalance()
        print(balance)
        
        // 获取帐户的所有交易信息
        _ = ethAccount.getTransactions()
        
        // 根据HASH获取交易信息
        _ = ethAccount.getTransaction(hash: "trans's hash")
        
        wm.descript()
        print(wm.walletList)
        
        let curretnWallet = wm.recentlyWallet()
        if nil != curretnWallet {
            print(curretnWallet!)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

