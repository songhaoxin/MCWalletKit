//
//  MCAppConfig.swift
//  MCWalletKit
//
//  Created by song mj on 2018/9/16.
//

import Foundation
public struct MCAppConfig {
    
    // 网络类型
    public static let network: Network = .mainnet
    
    // 钱包相关业务的服务端API处理者
    public static var walletServiceHandler: WalletServiceble? = WalletServiceEthProvider.shared
    
    // Eth帐户相关业务的服务端API处理者
    public static var ethAccountServiceHandler: AccountServiceble? = EthAccountServiceProvider.shared
    
    // Btc 帐户相关业务的服务端API处理者
    public static var btcAccountServiceHandler: AccountServiceble?
    
}
