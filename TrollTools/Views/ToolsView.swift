//
//  ToolsView.swift
//  TrollTools
//
//  Created by exerhythm on 08.11.2022.
//

import SwiftUI

struct ToolsView: View {
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink(destination: GesturesView()) {
                        HStack {
                            Image(systemName: "iphone")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundColor(.blue)
                            Text("iPhone X Gestures")
                                .padding(.horizontal, 10)
                        }
                    }
                    NavigationLink(destination: LockscreenRespringView()) {
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundColor(.blue)
                            Text("Locking after Respring")
                                .padding(.horizontal, 8)
                        }
                    }
                    NavigationLink(destination: BadgeChangerView()) {
                        HStack {
                            Image(systemName: "app.badge")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundColor(.blue)
                            Text("Custom Badges")
                                .padding(.horizontal, 8)
                        }
                    }
                    NavigationLink(destination: PasscodeEditorView()) {
                        HStack {
                            Image(systemName: "ellipsis.rectangle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundColor(.blue)
                            Text("Passcode faces")
                                .padding(.horizontal, 8)
                        }
                    }
                    NavigationLink(destination: LockscreenRespringView()) {
                        HStack {
                            Image(systemName: "lock")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundColor(.blue)
                            Text("Locking after Respring")
                                .padding(.horizontal, 8)
                        }
                    }
                    NavigationLink(destination: CalculatorErrorView()) {
                        HStack {
                            Image(systemName: "function")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundColor(.blue)
                            Text("Calculator Error Message")
                                .padding(.horizontal, 8)
                        }
                    }
                } header: {
                    Text("Tools")
                }
                
            }
            .navigationTitle("Tools")
        }
    }
}

struct ToolsView_Previews: PreviewProvider {
    static var previews: some View {
        ToolsView()
    }
}
