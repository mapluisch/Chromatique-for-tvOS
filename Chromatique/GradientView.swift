//
//  GradientView.swift
//  Chromatique
//
//  Created by Martin Pluisch on 20.05.24.
//

import SwiftUI

struct GradientView: View {
    @State private var gradientCenter1 = UnitPoint.center
    @State private var gradientCenter2 = UnitPoint.center
    @State private var gradientCenter3 = UnitPoint.center
    @State private var isAnimating = false

    @State private var colors1: [Color] = []
    @State private var colors2: [Color] = []
    @State private var colors3: [Color] = []
    let duration: Double = 20

    private let baseColors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple]

    var body: some View {
        ZStack {
            RadialGradient(gradient: Gradient(colors: colors1), center: gradientCenter1, startRadius: 0, endRadius: 2000)
                .edgesIgnoringSafeArea(.all)
                .blendMode(.screen)
                .onAppear {
                    initializeColors()
                    initializeRandomPositions()
                    startAnimating()
                    startColorReset()
                }
                .onDisappear {
                    isAnimating = false
                }

            RadialGradient(gradient: Gradient(colors: colors2), center: gradientCenter2, startRadius: 0, endRadius: 3000)
                .edgesIgnoringSafeArea(.all)
                .blendMode(.multiply)

            RadialGradient(gradient: Gradient(colors: colors3), center: gradientCenter3, startRadius: 0, endRadius: 4000)
                .edgesIgnoringSafeArea(.all)
                .blendMode(.softLight)
        }
    }

    private func initializeColors() {
        colors1 = baseColors.shuffled()
        colors2 = baseColors.shuffled()
        colors3 = baseColors.shuffled()
    }

    private func startAnimating() {
        isAnimating = true
        animateGradient1()
        animateGradient2()
        animateGradient3()
    }

    private func animateGradient1() {
        guard isAnimating else { return }

        withAnimation(Animation.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
            gradientCenter1 = randomUnitPoint()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            if self.isAnimating {
                self.animateGradient1()
            }
        }
    }

    private func animateGradient2() {
        guard isAnimating else { return }

        withAnimation(Animation.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
            gradientCenter2 = randomUnitPoint()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            if self.isAnimating {
                self.animateGradient2()
            }
        }
    }

    private func animateGradient3() {
        guard isAnimating else { return }

        withAnimation(Animation.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
            gradientCenter3 = randomUnitPoint()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            if self.isAnimating {
                self.animateGradient3()
            }
        }
    }
    
    private func initializeRandomPositions() {
        gradientCenter1 = randomUnitPoint()
        gradientCenter2 = randomUnitPoint()
        gradientCenter3 = randomUnitPoint()
    }

    private func randomUnitPoint() -> UnitPoint {
        let randomX = Double.random(in: 0...1)
        let randomY = Double.random(in: 0...1)
        return UnitPoint(x: randomX, y: randomY)
    }

    private func startColorReset() {
        Timer.scheduledTimer(withTimeInterval: duration, repeats: true) { _ in
            withAnimation(Animation.easeInOut(duration: duration*0.7)) {
                self.initializeColors()
            }
        }
    }
}

extension Color {
    static func random() -> Color {
        return Color(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1))
    }

    func interpolate(to color: Color, fraction: Double) -> Color {
        let fromComponents = self.components()
        let toComponents = color.components()

        let interpolatedRed = fromComponents.red + (toComponents.red - fromComponents.red) * fraction
        let interpolatedGreen = fromComponents.green + (toComponents.green - fromComponents.green) * fraction
        let interpolatedBlue = fromComponents.blue + (toComponents.blue - fromComponents.blue) * fraction

        return Color(red: interpolatedRed, green: interpolatedGreen, blue: interpolatedBlue)
    }

    func components() -> (red: Double, green: Double, blue: Double) {
        let components = UIColor(self).cgColor.components!
        return (red: Double(components[0]), green: Double(components[1]), blue: Double(components[2]))
    }
}

struct GradientView_Previews: PreviewProvider {
    static var previews: some View {
        GradientView()
    }
}
