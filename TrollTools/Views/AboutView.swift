//
//  AboutView.swift
//  TrollTools
//
//  Created by exerhythm on 10.11.2022.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        NavigationView {
            List {
                Section {
                    Link(imageName: "discord", url: "https://discord.gg/VyVcNjRMeg", title: "sourcelocation's tweaks")
                    Link(imageName: "twitter", url: "https://twitter.com/sourceloc", title: "@sourceloc")
                    Link(imageName: "github", url: "https://github.com/sourcelocation", title: "@sourcelocation")
                    Link(imageName: "reddit", url: "https://reddit.com/u/sourcelocation", title: "u/sourcelocation")
                    
                } header: {
                    Text("Links ")
                }
                
                Section {
                    Link(imageName: "sourcelocation", url: "https://twitter.com/sourceloc", title: "@sourceloc", circle: true)
                    Link(imageName: "haxi0", url: "https://twitter.com/haxi0sm", title: "@haxi0sm", circle: true)
                    Link(imageName: "iTechExpert21", url: "https://twitter.com/haxi0sm", title: "@iTechExpert21", circle: true)
                } header: {
                    Text("Credits")
                }
                
                Section {
                    Link(imageName: "shippingbox", url: "https://github.com/mhdhejazi/Dynamic/blob/master/LICENSE", title: "mhdhejazi/Dynamic", systemImage: true)
                    Link(imageName: "shippingbox", url: "https://github.com/SerenaKit/SantanderWrappers", title: "SerenaKit/SantanderWrappers", systemImage: true)
                    Link(imageName: "shippingbox", url: "https://github.com/yahoojapan/SwiftyXMLParser/blob/master/LICENSE", title: "yahoojapan/SwiftyXMLParser", systemImage: true)
                } header: {
                    Text("Libraries")
                }
            }
            .navigationTitle("About")
        }
    }
    
    struct Link: View {
        var imageName: String
        var url: String
        var title: String
        var systemImage: Bool = false
        var circle: Bool = false
        
        var body: some View {
            HStack(alignment: .center) {
                Group {
                    if systemImage {
                        Image(systemName: imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                }
                .cornerRadius(circle ? .infinity : 0)
                .frame(width: 24, height: 24)
                Button(title) {
                    UIApplication.shared.open(URL(string: url)!)
                }
                .padding(.horizontal, 4)
            }
            .foregroundColor(.blue)
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
