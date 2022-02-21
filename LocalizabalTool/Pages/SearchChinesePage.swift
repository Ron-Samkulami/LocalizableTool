//
//  SearchChinesePage.swift
//  LocalizabalTool
//
//  Created by 111 on 2022/2/21.
//

import SwiftUI

struct SearchChinesePage: View {
    @State var logMsg :String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            HStack(alignment: .center, spacing: 10, content: {
                Text("查找范围：")
                    .padding(EdgeInsets.init(top: 20, leading: 20, bottom: 20, trailing: 0))
                Button("查找.m/.h") {
                    let openQueue = DispatchQueue(label: "my_queue")
                    openQueue.async {
                        searchChinese(importPath,$logMsg,false)
                    }
                }
                Button("查找xib") {
                    let openQueue = DispatchQueue(label: "my_queue")
                    openQueue.async {
                        searchChinese(importPath,$logMsg,true)
                    }
                }
            })
            
            HStack(alignment: .center, spacing: 10, content: {
                Text("保存方式：")
                    .padding(EdgeInsets.init(top: 20, leading: 20, bottom: 20, trailing: 0))
                Button("保存为txt"){
                    saveResultAsTXT($logMsg)
                }
                Button("保存为xlsx"){
                    saveResultAsXLSX($logMsg)
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

struct SearchChinesePage_Previews: PreviewProvider {
    static var previews: some View {
        SearchChinesePage()
    }
}
