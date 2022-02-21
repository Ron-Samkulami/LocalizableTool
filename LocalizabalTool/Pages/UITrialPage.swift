//
//  UITrialPage.swift
//  LocalizabalTool
//
//  Created by 111 on 2022/2/18.
//

import SwiftUI

struct UITrialPage: View {
    @State private var isPresented = false
    @State private var isToastShow = false
    @State private var resultStr = ""
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        Button("Pressent a Sheet") {
                    self.isPresented = true
                }.sheet(isPresented: $isPresented, content: {
                    SheetView()
                })
        Button("将文件转成Excel"){
            resultStr = transformSelectedFileToXLSX()
            print(resultStr)
            isToastShow = true
        }.toast(show: $isToastShow, title: $resultStr)
    }
}




struct SheetView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: 600, height: 600)
                .foregroundColor(.yellow)
                .onTapGesture(count: 1,perform: {
                    //                    self.presentationMode.wrappedValue.dismiss()
                })
            HStack {
                Button("Close1") {
                    self.presentationMode.wrappedValue.dismiss()
                }.padding()
            }.position(x: 50, y: 30)
        }.edgesIgnoringSafeArea(.all)

    }
}

struct MenuPage_Previews: PreviewProvider {
    static var previews: some View {
        UITrialPage()
    }
}


/// 将文件转换成为xlsx文件
/// - Parameter logMsg: 打印窗口信息
func transformSelectedFileToXLSX() -> String {
    //选择文件
    let fullPath : String = (openFile(foldOnly: false) as NSString).expandingTildeInPath
    if fullPath == OPENFILEF_FAILED {
        return OPENFILEF_FAILED
    }
    if fullPath.extension == ".xlsx"{
        return OPENFILEF_UNSUPPORTTED_TYPE
    }
    
    //用于打印显示
    var resultStr = String()
    
    //读取文件内容
    let fileContent = try? NSString.init(contentsOfFile: fullPath, encoding: String.Encoding.utf8.rawValue)
    //用换行符切割
    let allLineStrings : [String] = (fileContent?.components(separatedBy: "\n"))!
    
    //创建空白工作簿
    let book = workbook_new(exportPath+"targetExcel.xlsx")
    let sheet = workbook_add_worksheet(book, "sheet1")
    
    for subStr in allLineStrings {
        //去掉空白行
        if subStr.isEmpty {
            continue
        }
        //写入表格
        let index = (allLineStrings as NSArray).index(of: subStr)
        worksheet_write_string(sheet, lxw_row_t(index), 0, subStr.cString(using: .utf8), nil)
        
        resultStr.append("\(subStr)\n")
    }
    //保存表格
    workbook_close(book);
    
    return "保存成功\(allLineStrings.count) in total \n"+resultStr
}
