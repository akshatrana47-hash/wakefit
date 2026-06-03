//
//  SplashView.swift
//  WakeFit
//
//  Animated splash screen shown on app launch
//  Matches Stitch design with "SYSTEM ONLINE" indicator
//

import SwiftUI

struct SplashView: View {

    // MARK: - Design Tokens

    private let primaryBackground = Color(hex: "051424")
    private let primaryAccent = Color(hex: "46f1cf")
    private let textSecondary = Color(hex: "bacac4")

    // MARK: - Animation State

    @State private var dotOpacity: Double = 0.3
    @State private var textOpacity: Double = 0.0

    var body: some View {
        ZStack {
            // Background - deep navy fills entire screen
            primaryBackground
                .ignoresSafeArea()

            // Bottom status indicator
            VStack {
                Spacer()

                HStack(spacing: 12) {
                    // Pulsing teal dot
                    Circle()
                        .fill(primaryAccent)
                        .frame(width: 8, height: 8)
                        .opacity(dotOpacity)

                    // "SYSTEM ONLINE" text
                    Text("SYSTEM ONLINE")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(textSecondary)
                        .tracking(0.15 * 13)
                        .opacity(textOpacity)
                }
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            // Animate dot pulsing
            withAnimation(
                .easeInOut(duration: 1.0)
                .repeatForever(autoreverses: true)
            ) {
                dotOpacity = 1.0
            }

            // Fade in text after short delay
            withAnimation(.easeIn(duration: 0.5).delay(0.3)) {
                textOpacity = 1.0
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SplashView()
}
