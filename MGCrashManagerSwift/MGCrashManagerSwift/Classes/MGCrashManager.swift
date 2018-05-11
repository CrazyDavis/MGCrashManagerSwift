//
//  MGCrashManager.swift
//  MGCrashManagerSwift
//
//  Created by Magical Water on 2018/5/7.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import MachO

public class MGCrashManager {

    public static var shared: MGCrashManager = MGCrashManager()

    private init() {}

    /*
     註冊崩潰訊息攔截, 通常app剛開啟之後即註冊, 並且同時間返回上次發生crash的文字內容
     */
    public func registerCrashHandler() {
        registerSignalHandler()
        registerUncaughtExceptionHandler()
    }

    //獲取所有崩潰訊息
    public func readAllCrashInfo() -> [String] {
        return MGCrashStore.shared.readAllCrashInfo()
    }

    //刪除所有崩潰訊息
    public func removeAllCrashInfo() {
        MGCrashStore.shared.deleteAllCrashInfo()
    }

    //註冊 - 信號類型崩潰
    private func registerSignalHandler() {

        // 如果在運行時遇到意外情況，Swift代碼將以SIGTRAP此異常類型終止，例如：
        // 1.具有nil值的非可選類型
        // 2.一個失敗的強制類型轉換
        // 查看Backtraces以確定遇到意外情況的位置。附加信息也可能已被記錄到設備的控制台。您應該修改崩潰位置的代碼，以正常處理運行時故障。例如，使用可選綁定而不是強制解開可選的
        signal(SIGABRT, signalExceptionHandler)
        signal(SIGSEGV, signalExceptionHandler)
        signal(SIGBUS, signalExceptionHandler)
        signal(SIGTRAP, signalExceptionHandler)
        signal(SIGILL, signalExceptionHandler)

        //如果需要蒐集其他信號崩潰則按需打開如下代碼
        //    signal(SIGHUP, SignalExceptionHandler)
        //    signal(SIGINT, SignalExceptionHandler)
        //    signal(SIGQUIT, SignalExceptionHandler)
        //    signal(SIGFPE, SignalExceptionHandler)
        //    signal(SIGPIPE, SignalExceptionHandler)

    }

    //註冊 - OC的NSException導致的異常崩潰
    private func registerUncaughtExceptionHandler() {
        NSSetUncaughtExceptionHandler(uncaughtExceptionHandler)
    }

}


//MARK: - 獲取偏移量位址
private func calculate() -> Int {
    var slide: Int = 0
    for i in 0..<_dyld_image_count() where _dyld_get_image_header(i).pointee.filetype == MH_EXECUTE {
        slide = _dyld_get_image_vmaddr_slide(i)
    }
    return slide
}

//MARK: - 觸發信號後操作
private func signalExceptionHandler(signal: Int32) -> Void {
    var mstr = String()
    mstr += "Stack:\n"
    //增加偏移量位址
    mstr = mstr.appendingFormat("slideAdress:0x%0x\r\n", calculate())
    //增加錯誤訊息
    for symbol in Thread.callStackSymbols {
        mstr = mstr.appendingFormat("%@\r\n", symbol)
    }

    MGCrashStore.shared.save(mstr, type: .signal)
    exit(signal)
}

//MARK: - 觸發oc nsception後操作
private func uncaughtExceptionHandler(exception: NSException) {
    let arr = exception.callStackSymbols
    let reason = exception.reason
    let name = exception.name.rawValue
    var crash = String()
    crash += "Stack:\n"
    crash = crash.appendingFormat("slideAdress:0x%0x\r\n", calculate())
    crash += "\r\n\r\n name:\(name) \r\n reason:\(String(describing: reason)) \r\n \(arr.joined(separator: "\r\n")) \r\n\r\n"

    MGCrashStore.shared.save(crash, type: .nsException)
}

