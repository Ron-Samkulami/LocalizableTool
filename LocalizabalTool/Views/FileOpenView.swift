//
//  FileOpenView.swift
//  LocalizabalTool
//
//  Created by 111 on 2021/12/6.
//

import Foundation
import SwiftUI

//!< 路径类型
enum filePathType {
    case filePathTypeImport
    case filePathTypeExport
}

func getFilePathType(_ aType : filePathType) -> String {
    switch aType {
    case .filePathTypeImport:
        return "项目路径"
    case .filePathTypeExport:
        return "结果导出路径"
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
            //标题
            Text(typeStr)
                .foregroundColor(.gray)
                .padding(EdgeInsets.init(top: 20, leading: 20, bottom: 20, trailing: 0))
            //输入框
            TextField("选择\(typeStr)路径", text:$pathStr)
                .cornerRadius(6.0)
                .disabled(true)
            //按钮
            Button(action: {
                let path = openFile(foldOnly: true)
                if path == OPENFILEF_FAILED {
                    return
                }
                pathStr = path
                
                switch aType {
                case .filePathTypeImport:
                    importPath = path
                case .filePathTypeExport:
                    exportPath = path
                }
                
            }) {
                Text("选择")
            }.padding(.trailing, 20)
        }
    }
    
    
}
