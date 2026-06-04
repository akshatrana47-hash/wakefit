//
//  SplashView.swift
//  WakeFit
//
//  Animated splash screen shown on app launch
//

import SwiftUI

struct SplashView: View {
    @State private var logoOpacity: Double = 0
    @State private var logoScale: CGFloat = 0.8
    @State private var systemOnlineOpacity: Double = 0
    var onComplete: () -> Void

    var body: some View {
        ZStack {
            AppColors.bgBase
                .ignoresSafeArea(.all)

            VStack(spacing: 24) {
                Spacer()

                // WakeFit logo
                Text("WakeFit")
                    .font(.system(size: 56, weight: .bold))
                    .foregroundStyle(AppColors.accentTeal)
                    .opacity(logoOpacity)
                    .scaleEffect(logoScale)

                // System online indicator
                HStack(spacing: 8) {
                    Circle()
                        .fill(AppColors.accentTeal)
                        .frame(width: 8, height: 8)
                    Text("SYSTEM ONLINE")
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundStyle(AppColors.accentTeal)
                        .tracking(2)
                }
                .opacity(systemOnlineOpacity)

                Spacer()
            }
        }
        .onAppear {
            // Step 1: Animate logo in
            withAnimation(.easeOut(duration: 0.8)) {
                logoOpacity = 1.0
                logoScale = 1.0
            }
            // Step 2: Show SYSTEM ONLINE after logo
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.easeIn(duration: 0.4)) {
                    systemOnlineOpacity = 1.0
                }
            }
            // Step 3: Navigate after 2.5 seconds total
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                onComplete()
            }
        }
    }
}

#Preview {
    SplashView {
        print("Splash complete")
    }
}
