//
//  CarrierNameChangerView.swift
//  TrollTools
//
//  Created by exerhythm on 13.11.2022.
//

import SwiftUI

struct CarrierNameChangerView: View {
    @State var str: String = ""
    
    var body: some View {
        TextField("Custom carrier text", text: $str)
            .padding()
        Button("Apply") {
            do {
                try CarrierNameManager.change(to: str)
            } catch {
                UIApplication.shared.alert(body: error.localizedDescription)
            }
        }
    }
}

struct CarrierNameChangerView_Previews: PreviewProvider {
    static var previews: some View {
        CarrierNameChangerView()
    }
}
