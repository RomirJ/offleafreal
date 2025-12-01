//
//  LeafLogoView.swift
//  Offleaf
//
//  Created by Romir Jain on 10/10/25.
//

import SwiftUI

struct LeafLogoView: View {
    var size: CGFloat = 120
    
    var body: some View {
        Image("LeafLogo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
    }
}

struct LeafLogoView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
        Color.black
            .ignoresSafeArea()
        LeafLogoView()
    }
}
}