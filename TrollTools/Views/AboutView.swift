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
                    LinkCell(imageName: "discord", url: "https://discord.gg/VyVcNjRMeg", title: "sourcelocation's tweaks")
                    LinkCell(imageName: "twitter", url: "https://twitter.com/sourceloc", title: "@sourceloc")
                    LinkCell(imageName: "github", url: "https://github.com/sourcelocation", title: "@sourcelocation")
                    LinkCell(imageName: "reddit", url: "https://reddit.com/u/sourcelocation", title: "u/sourcelocation")
                    
                } header: {
                    Text("Links ")
                }
                
                Section {
                    LinkCell(imageName: "sourcelocation", url: "https://twitter.com/sourceloc", title: "@sourceloc", circle: true)
                    LinkCell(imageName: "haxi0", url: "https://twitter.com/haxi0sm", title: "@haxi0sm", circle: true)
                    LinkCell(imageName: "iTechExpert21", url: "https://twitter.com/iTechExpert21", title: "@iTechExpert21", circle: true)
                    LinkCell(imageName: "swayea", url: "https://github.com/swayea", title: "@swayea", circle: true)
                } header: {
                    Text("Credits")
                }
                
                Section {
                    LinkCell(imageName: "shippingbox", url: "https://github.com/mhdhejazi/Dynamic/blob/master/LICENSE", title: "mhdhejazi/Dynamic", systemImage: true)
                    LinkCell(imageName: "shippingbox", url: "https://github.com/SerenaKit/SantanderWrappers", title: "SerenaKit/SantanderWrappers", systemImage: true)
                    LinkCell(imageName: "shippingbox", url: "https://github.com/yahoojapan/SwiftyXMLParser/blob/master/LICENSE", title: "yahoojapan/SwiftyXMLParser", systemImage: true)
                } header: {
                    Text("Libraries")
                }
                
                Section {
                    LinkCell(imageName: "cydia", url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ", title: "Cydia")
                    LinkCell(imageName: "sileo", url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ", title: "Sileo")
                    LinkCell(imageName: "zebra", url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ", title: "Zebra", circle: true)
                    LinkCell(imageName: "installer5", url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ", title: "Installer 5")
                    LinkCell(imageName: "saily", url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ", title: "Saily")
                } header: {
                    Text("Very cool stuff")
                }
            }
            .navigationTitle("About")
        }
    }
}

struct LinkCell: View {
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

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
