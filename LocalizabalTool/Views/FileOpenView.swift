//
//  FileOpenView.swift
//  LocalizabalTool
//
//  Created by 111 on 2021/12/6.
//

import Foundation
import SwiftUI

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
