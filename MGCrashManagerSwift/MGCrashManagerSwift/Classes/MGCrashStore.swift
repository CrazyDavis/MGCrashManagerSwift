//
//  MGCrashStore.swift
//  MGCrashManagerSwift
//
//  Created by Magical Water on 2018/5/8.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import MGUtilsSwift

//儲存crash相關訊息
class MGCrashStore {

    static var shared: MGCrashStore = MGCrashStore()

    private let crashDirName: String = "crashStore"
    private let signalCrash: String = "singalCrash"
    private let nsExceptionCrash: String = "nsExceptionCrash"
    private let extensionName: String = ".log"

    private var signalCrashDir: URL
    private var nsExceptionCrashDir: URL

    enum CrashType {
        case signal
        case nsException
    }

    private init() {
        let crashDir = MGFileUtils.getDirURL(crashDirName)
        signalCrashDir = MGFileUtils.getDirURL(signalCrash, path: crashDir)
        nsExceptionCrashDir = MGFileUtils.getDirURL(nsExceptionCrash, path: crashDir)
    }

    //保存崩溃信息
    func save(_ crashInfo: String, type: CrashType) {
        let fileName = MGDateUtils.format(d: Date(), format: "YYYYMMdd-HHmmss") + extensionName
        switch type {
        case .signal:
            MGFileUtils.write(fileName, content: crashInfo, path: signalCrashDir)
        case .nsException:
            MGFileUtils.write(fileName, content: crashInfo, path: nsExceptionCrashDir)
        }
    }

    //讀取所有崩潰訊息
    func readAllCrashInfo() -> [String] {
        var crashInfos: [String] = []
        //讀取signal的崩潰文件
        for signalName in crashFileList(.signal) {
            if let content = MGFileUtils.read(signalName, path: signalCrashDir) {
                crashInfos.append(content)
            }
        }
        //讀取nsException的崩潰文件
        for exceptionName in crashFileList(.nsException) {
            if let content = MGFileUtils.read(exceptionName, path: nsExceptionCrashDir) {
                crashInfos.append(content)
            }
        }
        return crashInfos
    }

    //刪除所有崩潰訊息
    func deleteAllCrashInfo() {
        _ = MGFileUtils.delete(signalCrashDir)
        _ = MGFileUtils.delete(nsExceptionCrashDir)
    }

    //獲取崩潰訊息的檔案列表(檔名)
    func crashFileList(_ type: CrashType) -> [String] {
        let fileURL: URL
        switch type {
        case .signal: fileURL = signalCrashDir
        case .nsException: fileURL = nsExceptionCrashDir
        }

        var logFiles: [String] = []
        let fileList = try? FileManager.default.contentsOfDirectory(atPath: fileURL.absoluteString)
        if let list = fileList {
            //只讀取結尾是.log的檔案
            for fileName in list {
                if fileName.hasSuffix(extensionName) {
                    let filePath = MGFileUtils.getFilePath(fileName, path: fileURL).absoluteString
                    logFiles.append(filePath)
                }
            }
        }

        return logFiles
    }
}
