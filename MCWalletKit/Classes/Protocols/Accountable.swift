//
//  Accountable.swift
//  MCWalletKit
//
//  Created by admin on 2018/9/18.
//

import Foundation
public protocol Accountalbe {
    var token: Token {get set}
    var balance: Double {get set}
    func setBalance()
}
