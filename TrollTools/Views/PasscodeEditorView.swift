//
//  PasscodeEditorView.swift
//  DebToIPA
//
//  Created by exerhythm on 15.10.2022.
//

import SwiftUI
import Photos

struct PasscodeEditorView: View {
    
    @State private var showingImagePicker = false
    @State private var faces: [UIImage?] = [UIImage?](repeating: nil, count: 10)
    @State private var changedFaces: [Bool] = [Bool](repeating: false, count: 10)
    @State private var changingFaceN = 0
    
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    @State private var showingAlert = false
    
    var body: some View {
        GeometryReader { proxy in
            let minSize = min(proxy.size.width, proxy.size.height)
            ZStack(alignment: .center) {
                Image(uiImage: WallpaperGetter.lockscreen() ?? UIImage(named: "wallpaper")!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .scaleEffect(1.5)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .offset(y: UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0)
                MaterialView(.light)
                    .brightness(-0.4)
                    .ignoresSafeArea()
                
                //                Rectangle()
                //                    .background(Material.ultraThinMaterial)
                //                    .ignoresSafeArea()
                //                    .preferredColorScheme(.dark)
                VStack {
                    Text("Passcode Face Editor")
                        .foregroundColor(.white)
                        .font(.title2)
                        .padding(1)
                    Text("Tap on any key to edit \nit's appearance")
                        .foregroundColor(.white)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .lineSpacing(-4)
                    
                    VStack(spacing: 16) {
                        ForEach((0...2), id: \.self) { y in
                            HStack(spacing: 24) {
                                ForEach((0...2), id: \.self) { x in
                                    PasscodeKeyView(face: faces[y * 3 + x + 1], action: { showPicker(y * 3 + x + 1) })
                                }
                            }
                        }
                        PasscodeKeyView(face: faces[0], action: { showPicker(0) })
                    }
                    .padding(.vertical, 32)
                }
                VStack {
                    Spacer()
                    HStack {
                        Button("Reset faces") {
                            do {
                                try PasscodeKeyFaceManager.reset()
                                respring()
                            } catch {
                                alert("An error occured. \(error)")
                            }
                        }
                        Spacer()
                        Button("Remove all") {
                            do {
                                try PasscodeKeyFaceManager.removeAllFaces()
                                faces = try PasscodeKeyFaceManager.getFaces()
                            } catch {
                                alert("An error occured. \(error)")
                            }
                        }
                    }
                    .foregroundColor(.white)
                    .padding(32)
                }
            }
        }
        .onAppear {
            do {
                faces = try PasscodeKeyFaceManager.getFaces()
                
                if let faces = UserDefaults.standard.array(forKey: "changedFaces") as? [Bool] {
                    changedFaces = faces
                }
            } catch {
                alert("An error occured. \(error)")
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage)
            )
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePickerView(image: $faces[changingFaceN])
        }
        .onChange(of: faces[changingFaceN] ?? UIImage()) { newValue in
            print(newValue)
            do {
                try PasscodeKeyFaceManager.setFace(newValue, for: changingFaceN)
            } catch {
                alert("An error occured while changing key face. \(error)")
            }
        }
    }
    
    func alert(_ message: String, title: String = "Error") {
        alertTitle = title
        alertMessage = message
        showingAlert.toggle()
    }
    func showPicker(_ n: Int) {
        changingFaceN = n
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                showingImagePicker = status == .authorized
            }
        }
    }
}

struct PasscodeKeyView: View {
    var face: UIImage?
    var action: () -> ()
    
    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                Circle()
                    .fill(Color(UIColor(red: 1, green: 1, blue: 1, alpha: 0.12)))
                if face == nil {
                    Image(systemName: "plus")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Image(uiImage: face!)
                        .resizable()
                        .frame(width: 70, height: 70)
                }
            }
            .frame(width: 80, height: 80)
        }
    }
}



struct PasscodeEditorView_Previews: PreviewProvider {
    static var previews: some View {
        PasscodeEditorView()
    }
}
