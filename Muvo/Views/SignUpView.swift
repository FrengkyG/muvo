//
//  SignUpView.swift
//  Muvo
//
//  Created by Frengky Gunawan on 12/06/25.
//
import SwiftUI

struct SignUpView: View {
    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var onboardingViewModel = OnboardingViewModel()
    @State private var username: String = ""
    
    var body: some View {
        GeometryReader{ geometry in
            ZStack(alignment: .top) {
                
                VStack(spacing:0) {
                    NavigationToolbar()
                    
                    ZStack(alignment: .top) {
                        SignUpCardSection(username: $username, geometry: geometry, userViewModel: userViewModel, OnboardingViewModel: onboardingViewModel)
                            .frame(maxHeight: .infinity, alignment: .bottom)
                        
                        
                        Image("orangeMascot")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 320)
                        
                    }
                    .frame(maxHeight: .infinity)
                }
                
            }
            .ignoresSafeArea(edges: .top)
            .navigationBarBackButtonHidden(true)
        }
    }
}


#Preview {
    SignUpView()
}

struct NavigationToolbar: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
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
                .foregroundColor(.primColor)
            Spacer()
            
        }
        .padding(.horizontal)
        .padding(.top, 50)
        .padding(.bottom, 20)
    }
}

struct SignUpCardSection: View {
    @Binding var username: String
    let geometry: GeometryProxy
    @ObservedObject var userViewModel: UserViewModel
    @ObservedObject var OnboardingViewModel: OnboardingViewModel
    @State private var navigateToHome = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            RoundedCornersShape(corners: [.topLeft, .topRight], radius: 40)
                .fill(Color.primColor ?? Color.blue)
                .ignoresSafeArea(edges: .bottom)
                .frame(height: geometry.size.height * 0.65)
            
            VStack(alignment: .center, spacing: 16) {
                
                Text("Kenalan dulu, yuk!")
                    .foregroundColor(.white)
                    .font(.custom("ApercuPro-Bold", size: 28))
                    .padding(.top, geometry.size.height * 0.4)
                
                
                VStack(alignment: .center, spacing: 4) {
                    Text("Biar makin akrab pas jalan,")
                        .foregroundColor(.white)
                        .font(.custom("ApercuPro", size: 17))
                    
                    Text("mau dipanggil apa?")
                        .foregroundColor(.white)
                        .font(.custom("ApercuPro", size: 17))
                }
                
                TextField(
                    "Username kamu",
                    text: $username
                )
                .padding(.horizontal, 21)
                .padding(.vertical, 13)
                .background(Color.bgButtonColor)
                .font(.custom("ApercuPro", size: 15))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.clear, lineWidth: 1)
                )
                .disableAutocorrection(true)
                .padding(.top, 24)
                
                Spacer()
                
                Button(action: {
                    navigateToHome = true
                    userViewModel.saveUsername(username)
                    OnboardingViewModel.markOnboardingAsCompleted()
                }) {
                    Text("Lanjutkan")
                        .font(.custom("ApercuPro-Bold", size: 18))
                        .foregroundColor(Color.blue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.white)
                        .cornerRadius(28)
                }
                .navigationDestination(isPresented: $navigateToHome) {
                    HomeView()
                }
                
                
            }
            .padding(.horizontal, 24)
            .padding(.top, 48)
        }
    }
}
