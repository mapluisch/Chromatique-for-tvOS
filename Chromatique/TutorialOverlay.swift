//
//  TutorialOverlay.swift
//  Chromatique
//
//  Created by Martin Pluisch on 24.05.24.
//

import SwiftUI

struct TutorialOverlay: View {
    @Binding var showTutorial: Bool
    @State private var currentIndex: Int = 0
    @State private var timer: Timer?
    
    private let colors: [Color] = [.black, .red, .green, .blue, .yellow, .orange, .purple]
    
    var body: some View {
        ZStack {
            if currentIndex < colors.count {
                colors[currentIndex]
                    .edgesIgnoringSafeArea(.all)
            } else {
                GradientView()
                    .edgesIgnoringSafeArea(.all)
            }

            VStack {
                Text("Welcome to Chromatique!")
                    .font(.title)
                    .padding()
                
                Text("Click on the touchpad / center of the clickpad to open up the menu.")
                    .padding(.top, 8)
                    
                Text("Swipe left / right and click again to select a background.")
                    .padding(.top, 8)
                    
                Text("Swipe all the way to the left and click to toggle 'Now Playing' info.")
                    .padding(.top, 8)
                    
                HStack {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Image(systemName: "music.note")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.white)
                        )

                    ForEach(colors.indices, id: \.self) { index in
                        Circle()
                            .fill(colors[index])
                            .frame(width: 50, height: 50)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: currentIndex == index ? 4 : 0)
                                    .animation(.easeInOut(duration: 0.2), value: currentIndex == index)
                            )
                    }
                    
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Image("gradient")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: currentIndex == colors.count ? 4 : 0)
                                .animation(.easeInOut(duration: 0.2), value: currentIndex == colors.count)
                        )
                }
                .padding()
                
                Button(action: {
                    withAnimation {
                        showTutorial = false
                        stopTimer()
                    }
                }) {
                    Text("Got it")
                        .foregroundColor(.black)
                        .cornerRadius(20)
                }
                .padding()
            }
            .padding()
            .background(Color.black.opacity(0.8))
            .cornerRadius(35)
            .onAppear {
                startTimer()
            }
            .onDisappear {
                stopTimer()
            }
        }
    }
    
    func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            withAnimation {
                currentIndex = (currentIndex + 1) % (colors.count + 1)
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
}
