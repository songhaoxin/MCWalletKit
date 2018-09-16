//
//  RealmDBHelper.swift
//
//  Created by song mj on 2018/9/16.
//

import UIKit
import RealmSwift

class RealmDBHelper {
    
    static let kRealmDBVersion: UInt64 = 0
    
    //数据库路径
    static var databaseFilePath: URL {
        let fileManager = FileManager.default
        var directoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        directoryURL = directoryURL.appendingPathComponent("wallet_data")
        
        if !fileManager.fileExists(atPath: directoryURL.path) {
            try! fileManager.createDirectory(atPath: directoryURL.path, withIntermediateDirectories: true, attributes: nil)
        }
        return directoryURL
    }
    
    //全局唯一实例
    static var shared: RealmDBHelper = {
        let instance = RealmDBHelper()
        
        return instance
    }()
    
    /// 全局唯一实例, 获取数据库
    var mcDB: Realm = {
        // 通过配置打开 Realm 数据库
        var path = RealmDBHelper.databaseFilePath
        
        path.appendPathComponent("eth_bit_wallet.realm")
        
        let config = Realm.Configuration(fileURL: path,
                                         schemaVersion: RealmDBHelper.kRealmDBVersion,
                                         migrationBlock: { (migration, oldSchemaVersion) in
                                            if (oldSchemaVersion < RealmDBHelper.kRealmDBVersion) {

                                            }
        })
        let realm = try! Realm(configuration: config)
        return realm
    }()
    
}

// MARK: - 扩展Results
extension Results {
    
    /**
     转为普通数组
     
     - returns:
     */
    func toArray<T:Object>() -> [T] {
        var arr = [T]()
        for obj in self {
            arr.append(obj as! T)
        }
        return arr
    }
    
}
