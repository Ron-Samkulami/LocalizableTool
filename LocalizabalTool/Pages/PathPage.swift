//
//  PathPage.swift
//  LocalizabalTool
//
//  Created by 111 on 2022/2/21.
//

import SwiftUI

struct PathPage: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FileOpenView(filePathType.filePathTypeImport)
            FileOpenView(filePathType.filePathTypeExport)
        }
    }
}

struct PathPage_Previews: PreviewProvider {
    static var previews: some View {
        PathPage()
    }
}
