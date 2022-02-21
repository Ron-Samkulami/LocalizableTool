//
//  ContentView.swift
//  LocalizabalTool
//
//  Created by 111 on 2021/8/20.
//

import SwiftUI

struct ContentView: View {
    @State private var shouldShowPurple = false
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            PathPage()
                .cornerRadius(10)
                .padding(20)
                .animation(.easeInOut)
                .scaleEffect()
            HStack(alignment: .top, spacing: 0) {
                NavigationView {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Tool List")
                            .padding(EdgeInsets.init(top: 20, leading: 20, bottom: 0, trailing: 0))
                            .foregroundColor(.blue)
                        List {
                            NavigationLink(destination: SearchChinesePage(),isActive: $shouldShowPurple) {
                                Text("Search Chinese in Proj")
                            }
                            NavigationLink(destination: SearchPage()) {
                                Text("Search Content in Proj")
                            }
                            NavigationLink(destination: UITrialPage()) {
                                Text("UITrialPage")
                            }
                        }
                    }
                    Text("Select a page from the tool List.")
                }
            }
            
        }
        
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                shouldShowPurple = true
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}




