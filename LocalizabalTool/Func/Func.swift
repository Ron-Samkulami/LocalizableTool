//
//  Func.swift
//  LocalizabalTool
//
//  Created by 111 on 2021/12/6.
//

import Foundation
import SwiftUI
import xlsxwriter

//!< 打开系统文件路径
func openFile(foldOnly : Bool) -> String {
    let openPanel = NSOpenPanel.init()
    openPanel.canChooseDirectories = true
    openPanel.canChooseFiles = !foldOnly
    
    if openPanel.runModal() == .OK {
        let path = openPanel.urls[0].absoluteString.components(separatedBy: [":"]).last ?? "-"
        let apath = path.removingPercentEncoding ?? "-"
        return apath
    }
    openPanel.close()
    return OPENFILEF_FAILED
}


// MARK: - Search

/// 查找文件夹下的文件中包含的中文
/// - Parameters:
///   - fileStr: 文件夹路径
///   - logMsg: 打印窗口信息
///   - readXib: 是否只查找.xib文件
func searchChinese( _ fileStr : String, _ logMsg: Binding<String>, _ readXib : Bool) {
    logMsg.wrappedValue = "正在查找，请稍候..."
    
    //遍历项目，获取文件列表
    let home = (fileStr as NSString).expandingTildeInPath
    let directNum = FileManager.default.enumerator(atPath: home)
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
    
    //遍历每个文件，正则匹配确定格式的中文
    let resultInAllFile = NSMutableArray()
    let fileEnum = fileArr.objectEnumerator()
    var chineseCount = 0
    
    while let fileName = fileEnum.nextObject() as? String {
        //文件完整路径
        let fullPath = home+"/"+fileName
        //正则表达式
        var regPattern = "[^%]@\"[^\"]*[\\u4E00-\\u9FA5]+[^\"\\n]*?\""
        if readXib {
            //"开头，接任意数量空白符号，接任意长度中文，接任意多个除" \n之外的的字符，"结尾
            regPattern = "\" *[\\u4E00-\\u9FA5]+[^\"\\n]*?\""
        }
        
        let contentStr = try? NSString.init(contentsOfFile: fullPath, encoding: String.Encoding.utf8.rawValue)
        let regular = try? NSRegularExpression(pattern: regPattern, options: .caseInsensitive)
        let matches = regular?.matches(in: contentStr! as String, options: .reportProgress, range: NSMakeRange(0, contentStr?.length ?? 0))
        
        if matches != nil {
            for match in matches! {
                let range = match.range
                var subStr = contentStr?.substring(with: range)
                
                if !readXib {
                    //.m、.h匹配出来的结果，需要去除开头的 两个字符
                    let removeRange = subStr!.startIndex..<(subStr?.index(subStr!.startIndex, offsetBy: 2))!
                    subStr?.removeSubrange(removeRange)
                }
                
                print(subStr as Any)
                
                //对所有文件去重
                if resultInAllFile.contains(subStr!) {
                    continue
                }
                resultInAllFile.add(subStr!)
                chineseCount+=1
            }
        }
        
    }
    searchResultArr = resultInAllFile
    
    //获取结果
    var resultStr = String()
    for subStr in resultInAllFile {
        resultStr.append(subStr as! String)
        resultStr.append("\n")
    }
    
    logMsg.wrappedValue = "查找完成：共\(chineseCount)个中文字符串"+"\n"+resultStr
    
}


/// 查找文件中的指定内容
/// - Parameters:
///   - fileStr: 文件夹路径
///   - keyStr: 查找关键字
///   - logMsg: 打印窗口信息
///   - readXib: 是否查找.xib文件
func searchContent( fileFolder fileStr : String, searchKey keyStr : String, result logMsg: Binding<String>, searchXib readXib : Bool) {
    
    DispatchQueue.main.async {
        logMsg.wrappedValue = "正在查找，请稍候..."
    }
    
    //遍历项目，获取文件列表
    let home = (fileStr as NSString).expandingTildeInPath
    let directEnum = FileManager.default.enumerator(atPath: home)
    let fileArr = NSMutableArray()
    
    while let fileName = directEnum?.nextObject() as? NSString {
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
    let resultInAllFile = NSMutableArray()
    var fileCount = 0
    let fileEnum = fileArr.objectEnumerator()
    
    while let fileName = fileEnum.nextObject() as? String {
        let fullPath = home+"/"+fileName
        let contentStr = try? NSString.init(contentsOfFile: fullPath, encoding: String.Encoding.utf8.rawValue)
        let regular = try? NSRegularExpression(pattern: keyStr, options: .caseInsensitive)
        let matches = regular?.matches(in: contentStr! as String, options: .reportProgress, range: NSMakeRange(0, contentStr?.length ?? 0))
        
        //存在指定关键字的文件，保存其文件名
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
    
    //输出
    DispatchQueue.main.async {
        logMsg.wrappedValue = "查找完成：共\(fileCount)个文件包含指定字符串"+"\n"+resultStr
    }
    
}

// MARK: - Save
/// 保存搜索结果为.txt
/// - Parameter logMsg: 打印窗口信息
func saveResultAsTXT(_ logMsg: Binding<String>) {
    if exportPath.isEmpty {
        logMsg.wrappedValue = EXPORT_EMPTYPATH
        return
    }
    var resultStr = String()
    for subStr in searchResultArr {
        resultStr.append(subStr as! String + "\n")
    }
    resultStr.removeLast()//删除最后的换行符
    
    logMsg.wrappedValue = "\(searchResultArr.count) in total \n"+resultStr
    do {
        try resultStr.write(toFile: exportPath+"ChineseString.txt", atomically: true, encoding: String.Encoding.utf8)
    } catch {
        logMsg.wrappedValue = "写入文件失败:\(error)" + "\(searchResultArr.count) in total \n"+resultStr
    }
    logMsg.wrappedValue = "保存成功"
}


/// 保存搜索结果为xlsx文件
/// - Parameter logMsg: 打印窗口信息
func saveResultAsXLSX(_ logMsg: Binding<String>) {
    if exportPath.isEmpty {
        logMsg.wrappedValue = EXPORT_EMPTYPATH
        return
    }
    
    //创建工作簿
    let book = workbook_new(exportPath+"ChineseString.xlsx")
    let sheet = workbook_add_worksheet(book, "sheet1")
    var resultStr = String()
    
    for aStr in searchResultArr {
        let subStr = aStr as! String
        //去掉空白
        if subStr.isEmpty {
            continue
        }
        //去掉双引号，写入表格
        let subString = subStr[subStr.index(subStr.startIndex, offsetBy: 1)..<subStr.index(subStr.endIndex, offsetBy: -1)]
        let index = searchResultArr.index(of: subStr)
        worksheet_write_string(sheet, lxw_row_t(index), 0, subString.cString(using: .utf8), nil)
        
        resultStr.append(subStr+"\n")
    }
    //保存表格
    workbook_close(book);
    
    logMsg.wrappedValue = "保存成功\(searchResultArr.count) in total \n"+resultStr
}
