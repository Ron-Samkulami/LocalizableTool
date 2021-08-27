//
//  ContentView.swift
//  LocalizabalTool
//
//  Created by 111 on 2021/8/20.
//

import SwiftUI

 var importPath = ""
 var exportOriginalPath = ""
var exportLocalizeStrPath = ""
var originalArr = NSMutableArray()
var translatedArr = NSMutableArray()

struct ContentView: View {
    var importFileView = FileOpenView(filePathType.filePathTypeImport)
    var exportFileView  = FileOpenView(filePathType.filePathTypeExportOriginal)
    @State var logMsg :String = ""
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            importFileView
            exportFileView
            FileOpenView(filePathType.filePathTypeExportLocalizeString)
            HStack(alignment: .center, spacing: 10, content: {
                Text("查找选项：")
                    .padding(EdgeInsets.init(top: 20, leading: 20, bottom: 20, trailing: 0))
                Button("查找xib") {
                    logMsg = "开始查找xib"
                    let openQueue = DispatchQueue(label: "my_queue")
                    openQueue.async {
                        readFiles(importPath,$logMsg,true)
                    }
                }
                Button("查找.m/.h") {
                    logMsg = "开始查找.m/.h"
                    let openQueue = DispatchQueue(label: "my_queue")
                    openQueue.async {
                        readFiles(importPath,$logMsg,false)
                    }
                }
            })
            HStack(alignment: .center, spacing: 10, content: {
                Text("保存选项：")
                    .padding(EdgeInsets.init(top: 20, leading: 20, bottom: 20, trailing: 0))
                Button("保存中文原文"){
                    saveOriginalToFile($logMsg)
                }
                Button("导入中文原文"){
                    openOriginalFile($logMsg)
                }
                Button("导入译文并生成Localization.Strings"){
                    generateTargetFile($logMsg)
                }
            })
            
            ScrollView {
                TextField("", text:$logMsg)
                    .cornerRadius(6.0)
                    .deleteDisabled(false)
                    .padding(.all, 20)
                    .lineLimit(2)
            }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//!< 读取文件
func readFiles( _ fileStr : String, _ logMsg: Binding<String>, _ readXib : Bool) {
    sleep(1)
//    DispatchQueue.main.async {
        logMsg.wrappedValue = "正在查找，请稍候..."
//    }
    
    
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
    
    
    //遍历每个xib，正则匹配里面的中文
    let fileEnum = fileArr.objectEnumerator()
    var chineseCount = 0
    
    while let fileName = fileEnum.nextObject() as? String {
        
//        let resultInOneFile = NSMutableArray()
        let fullPath = home+"/"+fileName
        var regPattern = "[^%]@\"[^\"]*[\\u4E00-\\u9FA5]+[^\"\\n]*?\""
        if readXib {
            regPattern = "\"[\\u4E00-\\u9FA5]+[^\"\\n]*?\""
        }
        
        let contentStr = try? NSString.init(contentsOfFile: fullPath, encoding: String.Encoding.utf8.rawValue)
        let regular = try? NSRegularExpression(pattern: regPattern, options: .caseInsensitive)
        let matches = regular?.matches(in: contentStr! as String, options: .reportProgress, range: NSMakeRange(0, contentStr?.length ?? 0))
//        print(matches?.count)
        if matches != nil {
            for match in matches! {
                let range = match.range
                var subStr = contentStr?.substring(with: range)
                

                if !readXib {
                    //去除开头的 *@
    //                subStr?.remove(at: subStr!.startIndex)
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
    originalArr = resultInAllFile
    //获取结果
    var resultStr = String()
    for subStr in resultInAllFile {
        resultStr.append(subStr as! String)
        resultStr.append("\n")
    }

    logMsg.wrappedValue = "查找完成：共\(chineseCount)个中文字符串"+"\n"+resultStr
    
}

//保存中文原文
func saveOriginalToFile(_ logMsg: Binding<String>) {
    if exportOriginalPath == "" {
        logMsg.wrappedValue = "中文导出路径为空"
        return
    }
    var resultStr = String()
    for subStr in originalArr {
        resultStr.append(subStr as! String)
        resultStr.append("\n")
    }
    resultStr.removeLast()//删除最后的换行符
    
    logMsg.wrappedValue = "\(originalArr.count) in total \n"+resultStr
    do {
        try resultStr.write(toFile: exportOriginalPath+"ChineseString.txt", atomically: true, encoding: String.Encoding.utf8)
    } catch {
        logMsg.wrappedValue = "写入文件失败:\(error)" + "\(originalArr.count) in total \n"+resultStr
    }
    logMsg.wrappedValue = "保存成功"
}

//手动打开中文原文
func openOriginalFile(_ logMsg: Binding<String>) {
    let fullPath : String = (OpenFile(foldOnly: false) as NSString).expandingTildeInPath
    let fileContent = try? NSString.init(contentsOfFile: fullPath, encoding: String.Encoding.utf8.rawValue)
    let allLineStrings : [String] = (fileContent?.components(separatedBy: "\n"))!
    //获取结果
    let resultInAllFile = NSMutableArray()
    var resultStr = String()
    for subStr in allLineStrings {
        resultInAllFile.add(subStr)
        resultStr.append(subStr)
        resultStr.append("\n")
    }
    
    originalArr = resultInAllFile

    logMsg.wrappedValue = "导入原文成功\n"+resultStr
}

//生成并保存LocalizeStr
func generateTargetFile(_ logMsg: Binding<String>) {
    if exportLocalizeStrPath == "" {
        logMsg.wrappedValue = "请先选择LocalizeStr导出路径"
        return
    }
    let fullPath : String = (OpenFile(foldOnly: false) as NSString).expandingTildeInPath
    let fileContent = try? NSString.init(contentsOfFile: fullPath, encoding: String.Encoding.utf8.rawValue)
    let allLineStrings : [String] = (fileContent?.components(separatedBy: "\n"))!
    var resultStr = String()
    if allLineStrings.count != originalArr.count {
        logMsg.wrappedValue = "译文与原文不一致"
    } else {
        for subStr in allLineStrings {
            let index = (allLineStrings as NSArray).index(of: subStr)
            let originalStr = originalArr.object(at: index)
            resultStr.append("\(originalStr as! String) = \(subStr)\n")
        }
        
        do {
            try resultStr.write(toFile: exportLocalizeStrPath+"localzationString.txt", atomically: true, encoding: String.Encoding.utf8)
        } catch {
            logMsg.wrappedValue = "写入文件失败:\(error)"
        }
        logMsg.wrappedValue = "保存成功\(allLineStrings.count) in total \n"+resultStr
    }

}



//!< 选择路径
func OpenFile(foldOnly : Bool) -> String {
    let openPanel = NSOpenPanel.init()
    if foldOnly {
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
    } else {
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = true
    }
    
    if openPanel.runModal() == .OK {
        let path = openPanel.urls[0].absoluteString.components(separatedBy: [":"]).last ?? "-"
        let apath = path.removingPercentEncoding ?? "-"
        return apath
    }
    return "打开失败"
}


//!< 路径类型
enum filePathType {
    case filePathTypeImport
    case filePathTypeExportOriginal
    case filePathTypeExportLocalizeString
}

func getFilePathType(_ aType : filePathType) -> String {
    switch aType {
    case .filePathTypeImport:
        return "项目"
    case .filePathTypeExportOriginal:
        return "导出中文原文"
    default:
        return "导出LocalizationString"
    }
}

//!< 封装获取路径视图
struct FileOpenView : View {
    var aType: filePathType
    
    @State var typeStr :String = ""
    @State var pathStr :String = ""
    
    init(_ fileType: filePathType) {
       aType = fileType
       _typeStr = State(initialValue: getFilePathType(fileType))
   }
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Text(typeStr)
                .foregroundColor(.gray)
                .padding(EdgeInsets.init(top: 20, leading: 20, bottom: 20, trailing: 0))
            TextField("选择\(typeStr)路径", text:$pathStr)
                .cornerRadius(6.0)
                .disabled(true)
            Button(action: {
                let path = OpenFile(foldOnly: true)
                NSLog("%@", path)
                pathStr = path
                if aType == filePathType.filePathTypeImport {
                    importPath = path
                } else if aType == filePathType.filePathTypeExportOriginal {
                    exportOriginalPath = path
                } else {
                    exportLocalizeStrPath = path
                }
            }) {
                Text("选择")
            }.padding(.trailing, 20)
        }
    }
    
     
}






