//
//  FixedColorView.swift
//  Chromatique
//
//  Created by Martin Pluisch on 20.05.24.
//

import SwiftUI

struct FixedColorView: View {
    @State private var currentColor: Color = .blue
    @State private var showColorPicker: Bool = false
    @FocusState private var isButtonFocused: Bool

    var body: some View {
        ZStack {
            currentColor
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    showColorPicker.toggle()
                }
            
            VStack {
                Spacer()
                
                Button("Hello") {
                    print("pressed hello")
                }
                .focused($isButtonFocused)
                .onAppear {
                    isButtonFocused = true
                }

                Spacer()
            }

            if showColorPicker {
                ColorPickerView(currentColor: $currentColor, showColorPicker: $showColorPicker)
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
            }
        }
    }
}

struct ColorPickerView: View {
    @Binding var currentColor: Color
    @Binding var showColorPicker: Bool
    
    private let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink, .gray]

    var body: some View {
        VStack {
            Spacer()
            BlurView()
                .frame(height: 200)
                .overlay(
                    HStack {
                        ForEach(colors, id: \.self) { color in
                            Button(action: {
                                currentColor = color
                                showColorPicker = false
                            }) {
                                Circle()
                                    .fill(color)
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Circle()
                                            .stroke(color == currentColor ? Color.white : Color.clear, lineWidth: 4)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding()
                        }
                    }
                )
                .cornerRadius(20)
                .padding()
        }
    }
}

struct BlurView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
