//
//  DetailsView.swift
//  FroopProof
//
//  Created by David Reed on 6/23/23.
//

import SwiftUI

struct DetailsView: View, TaskAddon {
    var systemImageName: String { return "info.square.fill" }
    var description: String { return "Details" }

    func action() {
        // Open URL or other action
    }
    
    var body: some View {
        VStack {
            Image(systemName: systemImageName)
                .font(.system(size: 35))
                .foregroundColor(.black)
                .opacity(0.7)
                .fontWeight(.thin)
                .frame(maxWidth: 50, maxHeight: 40)
            Text(description)
                .foregroundColor(.black)
                .font(.system(size: 14))
                .fontWeight(.light)
        }
        .onTapGesture { action() }
        .padding(.trailing, 20)
    }
    
    func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        UIApplication.shared.open(url)
    }
    
}
