//
//  CarrierNameChangerView.swift
//  TrollTools
//
//  Created by exerhythm on 13.11.2022.
//

import SwiftUI

struct CarrierNameChangerView: View {
    @State var str: String = ""
    @State private var carrierOffsetX: CGFloat = .zero
    @State private var carrierOffsetY: CGFloat = .zero
    
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
                                    carrierOffsetX = -geometry.size.width/15
                                    carrierOffsetY = -geometry.size.height/2 + (168/1294) * geometry.size.height
                                }
                                return .clear
                            })
                        TextField("carrier", text: $str)
                            .offset(x: carrierOffsetX, y: carrierOffsetY)
                            .frame(width: 125, height: 40, alignment: .center)
                            .multilineTextAlignment(.leading)
                    }
                }
                .frame(maxWidth: proxy.size.width * 0.9)
                .padding()
                
                Button("Apply") {
                    do {
                        try CarrierNameManager.change(to: str)
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
