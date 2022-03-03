//
//  SearchPage.swift
//  LocalizabalTool
//
//  Created by 111 on 2022/2/18.
//

import SwiftUI


struct SearchPage: View {
    @State var logMsg :String = ""
    @State var searchKey :String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            HStack(alignment: .center, spacing: 10) {
                Text("查找关键字：").padding(EdgeInsets.init(top: 10, leading: 20, bottom: 10, trailing: 0))
                TextField("请输入查找关键字", text:$searchKey)
                    .cornerRadius(6.0)
                Button("查找.m/.h") {
                    searchContent(fileFolder: importPath, searchKey: searchKey, result: $logMsg, searchXib: false)
                }
                Button("查找.xib") {
                    searchContent(fileFolder: importPath, searchKey: searchKey, result: $logMsg, searchXib: true)
                }
                Spacer()
            }

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

struct ToolPage_Previews: PreviewProvider {
    static var previews: some View {
        SearchPage()
    }
}






