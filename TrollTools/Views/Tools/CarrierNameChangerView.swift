//
//  CarrierNameChangerView.swift
//  TrollTools
//
//  Created by exerhythm on 13.11.2022.
//

import SwiftUI

struct CarrierNameChangerView: View {
    @State var str: String = (try? CarrierNameManager.getCarrierName()) ?? ""
    @State private var carrierBoxSize: [CGFloat] = [.zero, .zero]
    @State private var carrierOffset: [CGFloat] = [.zero, .zero]
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                Group {
                    ZStack(alignment: .center) {
                        Image("13cc")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .background(GeometryReader { (geometry) -> Color in
                                DispatchQueue.main.async {
                                    // set the carrier textbox size
                                    carrierBoxSize[0] = geometry.size.width/3
                                    carrierBoxSize[1] = geometry.size.height/25
                                    
                                    // set the carrier textbox offset
                                    carrierOffset[0] = -geometry.size.width/2 + (135/640)*geometry.size.width + carrierBoxSize[0]/2
                                    carrierOffset[1] = -geometry.size.height/2 + (142/1294) * geometry.size.height + carrierBoxSize[1]/2
                                }
                                return .clear
                            })
                        TextField("carrier", text: $str)
                            .offset(x: carrierOffset[0], y: carrierOffset[1])
                            .frame(width: carrierBoxSize[0], height: carrierBoxSize[1], alignment: .center)
                            .multilineTextAlignment(.leading)
                    }
                }
                .frame(maxWidth: proxy.size.width * 0.9)
                .padding()
                
                Button("Apply") {
                    do {
                        try CarrierNameManager.change(to: str)
                        UIApplication.shared.alert(title: "Success!", body: "Please reboot your device for the changes to take effect.")
                    } catch {
                        UIApplication.shared.alert(body: error.localizedDescription)
                    }
                }
                .padding(.bottom)
            }
            .ignoresSafeArea(.keyboard)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Carrier Changer")
    }
}

struct CarrierNameChangerView_Previews: PreviewProvider {
    static var previews: some View {
        CarrierNameChangerView()
    }
}
