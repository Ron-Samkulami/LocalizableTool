//
//  Func.swift
//  LocalizabalTool
//
//  Created by 111 on 2021/12/6.
//

import Foundation
import SwiftUI

//!< 查找xib中的指定内容
func searchContent( fileFolder fileStr : String, searchKey keyStr : String, result logMsg: Binding<String>, searchXib readXib : Bool) {
    sleep(1)
    logMsg.wrappedValue = "正在查找，请稍候..."

    let resultInAllFile = NSMutableArray()
    let home = (fileStr as NSString).expandingTildeInPath
    
    //筛选出xib文件
    let mgr = FileManager.default
    let directNum = mgr.enumerator(atPath: home)
    let fileArr = NSMutableArray()
    
    while let fileName = directNum?.nextObject() as? NSString {
        if readXib {
            if fileName.pathExtension == "xib" {
                fileArr.add(fileName)
            }
        } else {
            for fileExt in ["m","h"] {
                if fileName.pathExtension == fileExt{
                    fileArr.add(fileName)
                }
            }
        }
    }
    
    
    //遍历每个文件，正则匹配关键字
    let fileEnum = fileArr.objectEnumerator()
    var fileCount = 0
    
    while let fileName = fileEnum.nextObject() as? String {
        let fullPath = home+"/"+fileName
        
        let contentStr = try? NSString.init(contentsOfFile: fullPath, encoding: String.Encoding.utf8.rawValue)
        let regular = try? NSRegularExpression(pattern: keyStr, options: .caseInsensitive)
        let matches = regular?.matches(in: contentStr! as String, options: .reportProgress, range: NSMakeRange(0, contentStr?.length ?? 0))
        if !(matches?.isEmpty ?? true) {
            if resultInAllFile.contains(fileName) {
                continue
            }
            resultInAllFile.add(fileName)
            fileCount+=1
        }
        
    }
    //获取结果
    var resultStr = String()
    for subStr in resultInAllFile {
        resultStr.append(subStr as! String)
        resultStr.append("\n")
    }
    
    logMsg.wrappedValue = "查找完成：共\(fileCount)个文件包含指定字符串"+"\n"+resultStr
    
}
