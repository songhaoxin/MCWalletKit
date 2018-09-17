//
//  Transcation.swift
//  MCWalletKit
//
//  Created by song mj on 2018/9/16.
//

import UIKit

public class EthTranscation: NSObject {
    public var id: String = ""
    public var fromAddress: String = ""
    public var toAddress: String = ""
    public var contractAddress: String = ""
    public var amount: Double = 0
    
    public var gas: Double = 0
    public var toAmount: Double = 0
    public var remark: String = ""
    public var txType: Int = 0
    public var tokenType: Double = 0
    public var txHash: String = ""
    public var txState: Int = 0 //0申请 1成功 2失败 3申请失败
    public var createdTime: String = ""
    
}
