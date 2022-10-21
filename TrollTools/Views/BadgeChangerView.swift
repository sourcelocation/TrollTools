//
//  BadgeColorChangerView.swift
//  DebToIPA
//
//  Created by exerhythm on 15.10.2022.
//

import SwiftUI

struct BadgeChangerView: View {
    @State private var color = Color.red
    @State private var radius: CGFloat = 24
    
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    @State private var showingAlert = false
    
    var body: some View {
        GeometryReader { proxy in
            let minSize = min(proxy.size.width, proxy.size.height)
            NavigationView {
                ZStack {
                    Image(uiImage: WallpaperGetter.homescreen() ?? UIImage(named: "wallpaper")!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: max(proxy.size.width, proxy.size.height) * 1.5)
                    VStack {
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: UIImage(named: "1024")!)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: minSize / 2, height: minSize / 2)
                                .cornerRadius(minSize / 8)
                            ZStack {
                                Rectangle()
                                    .fill(color)
                                    .frame(width: minSize / 5, height: minSize / 5)
                                    .cornerRadius(minSize * radius / 240)
                                Text("1")
                                    .foregroundColor(.white)
                                    .font(.system(size: 45))
                            }
                            .offset(x: minSize / 12, y:  -minSize / 22)
                        }
                        Text("TrollTools")
                            .font(.title)
                            .foregroundColor(.white)
                            .fontWeight(.medium)
                        HStack {
                            ColorPicker("Set the background color", selection: $color)
                                .labelsHidden()
                                .scaleEffect(1.5)
                                .padding()
                            Slider(value: $radius, in: 0...24)
                                .frame(width: minSize / 2)
                        }
                        Button("Apply and respring", action: {
                                do {
                                    try BadgeChanger.change(to: UIColor(color), with: radius)
                                    respring()
                                } catch {
                                    alert("An error occured. " + error.localizedDescription)
                                }
                            })
                            .padding(10)
                            .background(Color.blue)
                            .cornerRadius(8)
                            .foregroundColor(.white)
                            .padding(.top, 24)
                    }
                }
                .navigationTitle("Badge Color")
                .navigationBarTitleTextColor(Color.white)
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage)
            )
        }
    }
    
    func alert(_ message: String, title: String = "Error") {
        alertTitle = title
        alertMessage = message
        showingAlert.toggle()
    }
}

struct BadgeColorChangerView_Previews: PreviewProvider {
    static var previews: some View {
        BadgeChangerView()
    }
}


extension View {
    /// Sets the text color for a navigation bar title.
    /// - Parameter color: Color the title should be
    ///
    /// Supports both regular and large titles.
    @available(iOS 14, *)
    func navigationBarTitleTextColor(_ color: Color) -> some View {
        let uiColor = UIColor(color)
    
        // Set appearance for both normal and large sizes.
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: uiColor ]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: uiColor ]
    
        return self
    }
}
