//
//  CryptTools.swift
//  CLMWalletKit
//
//  Created by admin on 2018/8/13.
//  Copyright © 2018年 admin. All rights reserved.
//

import UIKit
import CryptoSwift

public class CryptTools: NSObject {
    public static let secKey = "_cl_multi_wallet_"
    //encode
    public static func Encode_AES_ECB(strToEncode:String,key:String) -> String {
        var encodeString = ""
        do {
            let aes = try AES(key: Padding.zeroPadding.add(to: key.bytes, blockSize: AES.blockSize),blockMode: ECB())
            let encoded = try aes.encrypt(strToEncode.bytes)
            encodeString = encoded.toBase64()!
        }catch {
            print(error.localizedDescription)
        }
        return encodeString
    }
    
    //decode
    public static func Decode_AES_ECB(strToDecode:String,key:String) -> String {
        var decodeStr = ""
        let data = NSData(base64Encoded: strToDecode, options: NSData.Base64DecodingOptions.init(rawValue: 0))
        
        var encrypted: [UInt8] = []
        let count = data?.length
        for i in 0..<count! {
            var temp:UInt8 = 0
            data?.getBytes(&temp, range: NSRange(location: i,length:1 ))
            encrypted.append(temp)
        }
        do {
            let aes = try AES(key: Padding.zeroPadding.add(to: key.bytes, blockSize: AES.blockSize),blockMode: ECB())
            let decode = try aes.decrypt(encrypted)
            let encoded = Data(decode)
            decodeStr = String(bytes: encoded.bytes, encoding: .utf8)!
        }catch{
            print(error.localizedDescription)
        }

        return decodeStr
    }

}
