//
//  Extensions.swift
//  LocalizabalTool
//
//  Created by 111 on 2022/2/21.
//

import Foundation
import SwiftUI

extension String {
    var `extension`: String {
        if let index = self.lastIndex(of: ".") {
            return String(self[index...])
        } else {
            return ""
        }
    }
}

extension View {
    func toast(show: Binding<Bool>, title: Binding<String>) -> some View {
        self.modifier(Toast(show: show, title: title))
    }
}

struct Toast: ViewModifier {
    
    @Binding var show: Bool //是否显示
    @Binding var title: String //显示文字
    
    func body(content: Content) -> some View {
        GeometryReader { geo in
            ZStack(){
                content.zIndex(0).disabled(show)
                
                //防止多次点击 .disabled(show)
                VStack {
                    HStack {
                        Text(title)
                            .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.white)
                    }
                    .background(Color.black.opacity(0.4)).cornerRadius(5)
                    .frame(maxWidth: geo.size.width - 100)
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .background(Color.clear)
                .zIndex(1)
                .opacity((show) ? 1 : 0)
                .animation(.easeIn(duration: 0.25)) //动画
            }
            
            .onChange(of: show) { e in
                if(e){
                    //消失
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        show.toggle()
                    }
                    
                }
            }
        }
    }
}
