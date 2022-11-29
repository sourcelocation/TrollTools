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
    @State private var canChange = false // needed to make sure it does not reset the size on startup
    @State private var changingFaceN = 0
    @State private var isBig = false
    @State private var customSize : [String] = ["152", "152"]
    @State private var sizeButtonState = KeySizeState.small
    @State private var isImporting = false
    @State private var isExporting = false
    
    @State private var ipadView: Bool = (UIDevice.current.userInterfaceIdiom == .pad)
    
    let fm = FileManager.default
    
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
                    HStack {
                        Button(action: {
                            do {
                                var archiveURL: URL? = try PasscodeKeyFaceManager.exportFaceTheme()
                                // show share menu
                                let avc = UIActivityViewController(activityItems: [archiveURL!], applicationActivities: nil)
                                UIApplication.shared.windows.first?.rootViewController?.present(avc, animated: true)
                            } catch {
                                UIApplication.shared.alert(body: "An error occured while exporting key face.")
                            }
                        }) {
                            Image(systemName: "square.and.arrow.up")
                        }
                        .scaleEffect(1.75)
                        .padding(.trailing, 20)
                        
                        Button(action: {
                            isImporting = true
                        }) {
                            Image(systemName: "square.and.arrow.down")
                        }
                        .scaleEffect(1.75)
                    }
                    .offset(x: 120, y: -75)
                    
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
                            HStack(spacing: 22) {
                                ForEach((0...2), id: \.self) { x in
                                    PasscodeKeyView(face: faces[y * 3 + x + 1], action: { showPicker(y * 3 + x + 1) }, ipadView: ipadView)
                                }
                            }
                        }
                        PasscodeKeyView(face: faces[0], action: { showPicker(0) }, ipadView: ipadView)
                    }
                    .padding(.top, 16)
                }
                .offset(x: 0, y: -35)
                VStack {
                    Spacer()
                    if sizeButtonState == KeySizeState.custom {
                        HStack {
                            TextField("X", text: $customSize[0])
                                .foregroundColor(.white)
                                .multilineTextAlignment(.trailing)
                                .padding(.horizontal, 5)
                                .font(.system(size: 25))
                                .minimumScaleFactor(0.5)
                                .frame(width: 100, height: 40)
                                .textFieldStyle(PlainTextFieldStyle())
                            Text("x")
                                .foregroundColor(.white)
                                .font(.title2)
                                .padding(5)
                            TextField("Y", text: $customSize[1])
                                .foregroundColor(.white)
                                .padding(.horizontal, 5)
                                .font(.system(size: 25))
                                .minimumScaleFactor(0.5)
                                .frame(width: 100, height: 40)
                                .textFieldStyle(PlainTextFieldStyle())
                        }
                        .padding(.bottom, 70)
                    }
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Button("Reset faces") {
                            do {
                                try PasscodeKeyFaceManager.reset()
                                respring()
                            } catch {
                                UIApplication.shared.alert(body:"An error occured. \(error)")
                            }
                        }
                        Spacer()
                        Button(sizeButtonState.rawValue) {
                            if sizeButtonState == KeySizeState.small {
                                sizeButtonState = KeySizeState.big
                            } else if sizeButtonState == KeySizeState.big {
                                sizeButtonState = KeySizeState.custom
                            } else {
                                sizeButtonState = KeySizeState.small
                            }
                        }
                        Spacer()
                        Button("Remove all") {
                            do {
                                try PasscodeKeyFaceManager.removeAllFaces()
                                faces = try PasscodeKeyFaceManager.getFaces()
                            } catch {
                                UIApplication.shared.alert(body:"An error occured. \(error)")
                            }
                        }
                    }
                    .foregroundColor(.white)
                    .padding(32)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .fileImporter(isPresented: $isImporting,
                      allowedContentTypes: [
                        //.folder
                        UTType(filenameExtension: "passthm") ?? .zip
                      ],
                      allowsMultipleSelection: false
        ) { result in
            guard let url = try? result.get().first else { UIApplication.shared.alert(body: "Couldn't get url of file. Did you select it?"); return }
            canChange = false
            do {
                // try appying the themes
                try PasscodeKeyFaceManager.setFacesFromTheme(url, keySize: sizeButtonState, customX: CGFloat(Int(customSize[0]) ?? 152), customY: CGFloat(Int(customSize[1]) ?? 152))
                faces = try PasscodeKeyFaceManager.getFaces()
            } catch { UIApplication.shared.alert(body: error.localizedDescription) }
        }
        .onAppear {
            do {
                faces = try PasscodeKeyFaceManager.getFaces()
                
                if let faces = UserDefaults.standard.array(forKey: "changedFaces") as? [Bool] {
                    changedFaces = faces
                }
            } catch {
                UIApplication.shared.alert(body: "An error occured. \(error)")
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePickerView(image: $faces[changingFaceN])
        }
        .onChange(of: faces[changingFaceN] ?? UIImage()) { newValue in
            print(newValue)
            if canChange {
                // reset the size if too big or small
                if (Int(customSize[0]) ?? 152 > 500) {
                    customSize[0] = "500"
                } else if (Int(customSize[0]) ?? 152 < 50) {
                    customSize[0] = "50"
                }
                
                if (Int(customSize[1]) ?? 152 > 500) {
                    customSize[1] = "500"
                } else if (Int(customSize[1]) ?? 152 < 50) {
                    customSize[1] = "50"
                }
                canChange = false
                do {
                    try PasscodeKeyFaceManager.setFace(newValue, for: changingFaceN, keySize: sizeButtonState, customX: Int(customSize[0]) ?? 152, customY: Int(customSize[1]) ?? 152)
                    faces[changingFaceN] = try PasscodeKeyFaceManager.getFace(for: changingFaceN)
                    canChange = false
                } catch {
                    UIApplication.shared.alert(body: "An error occured while changing key face. \(error)")
                }
            }
        }
    }
    func showPicker(_ n: Int) {
        changingFaceN = n
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                if !canChange {
                    canChange = true
                }
                showingImagePicker = status == .authorized
            }
        }
    }
}

struct PasscodeKeyView: View {
    var face: UIImage?
    var action: () -> ()
    var ipadView: Bool
    
    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                Circle()
                    .fill(Color(UIColor(red: 1, green: 1, blue: 1, alpha: 0.12)))
                    .frame(width: 70, height: 70) // background circle
                Circle()
                    .fill(Color(UIColor(red: 1, green: 1, blue: 1, alpha: 0))) // hidden circle for image
                if face == nil {
                    Image(systemName: "plus")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    if ipadView {
                        // scale correctly for ipad
                        Image(uiImage: face!)
                            .resizable()
                            .frame(width: CGFloat(Float(face!.size.width)/2), height: CGFloat(Float(face!.size.height)/2))
                    } else {
                        // normal (for phones)
                        Image(uiImage: face!)
                            .resizable()
                            .frame(width: CGFloat(Float(face!.size.width)/3), height: CGFloat(Float(face!.size.height)/3))
                    }
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
