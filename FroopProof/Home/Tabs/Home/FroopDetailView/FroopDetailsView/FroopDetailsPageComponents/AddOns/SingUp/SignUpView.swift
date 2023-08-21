//
//  SignUpView.swift
//  FroopProof
//
//  Created by David Reed on 6/23/23.
//

import SwiftUI

struct SignUpView: View, TaskAddon {
    var systemImageName: String { return "list.clipboard.fill" }
    var description: String { return "SignUp" }
    @Binding var taskOn: Bool
    
    func action() {
        taskOn = true
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
                .foregroundColor( .black)
                .font(.system(size: 14))
                .fontWeight(.light)
        }
        .onTapGesture { action()
            taskOn = true
        }
        .padding(.trailing, 20)
    }
}

