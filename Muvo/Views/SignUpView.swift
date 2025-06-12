//
//  SignUpView.swift
//  Muvo
//
//  Created by Frengky Gunawan on 12/06/25.
//
import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                // MARK: Header
                HStack(alignment: .center) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.primColor)
                            .font(.system(size: 28, weight: .bold))
                    }
                    
                    Spacer()
                    
                    Text("Selamat Datang!")
                        .font(.custom("ApercuPro-Bold", size: 28))
                        .foregroundColor(.blue)
                    Spacer()
                    
                }
                .padding(.horizontal)
                .padding(.top, 50)
                .padding(.bottom, 20)
                
                Text("Hello, World!")
                    .padding()
                
                Spacer()
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden(true)
    }
}


#Preview {
    SignUpView()
}
